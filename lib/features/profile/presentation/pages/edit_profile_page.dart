import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rede_social/features/auth/presentation/components/my_text_field.dart';
import 'package:rede_social/features/profile/domain/entities/profile_user.dart';
import 'package:rede_social/features/profile/presentation/cubits/profile_states.dart';
import 'package:rede_social/responsive/constrained_scaffold.dart';

import '../cubits/profile_cubit.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // obter imagem mobile
  PlatformFile? imagePickedFile;

  // obter imagem web
  Uint8List? webImage;

  final bioTextController = TextEditingController();

  // escolher imagem
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;

        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  // função de atualizar alterações do perfil
  void updateProfile() async {
    final profileCubit = context.read<ProfileCubit>();

    // prepara imagens
    final String uid = widget.user.uid;
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;
    final String? newBio =
        bioTextController.text.isNotEmpty ? bioTextController.text : null;

    // atualiza o perfil apenas se realmente tiver algo para atualizar
    if (imagePickedFile != null || newBio != null) {
      profileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        imageMobilePath: imageMobilePath,
        imageWebBytes: imageWebBytes,
      );
      // nada para atualizar
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(builder: (context, state) {
      // carregando perfil
      if (state is ProfileLoading) {
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator(), Text('Atualizando..')],
            ),
          ),
        );
      } else {
        return buildEditPage();
      }
    }, listener: (context, state) {
      if (state is ProfileLoaded) {
        Navigator.pop(context);
      }
    });
  }

  Widget buildEditPage() {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          // botão de salvar alterações
          IconButton(onPressed: updateProfile, icon: const Icon(Icons.check)),
        ],
      ),
      body: Column(
        children: [
          // foto de perfil
          Center(
            child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.hardEdge,
                child:
                    // exibir imagem selecionada mobile
                    (!kIsWeb && imagePickedFile != null)
                        ? Image.file(
                            File(imagePickedFile!.path!),
                            fit: BoxFit.cover,
                          )
                        :
                        // exibir imagem selecionada web
                        (kIsWeb && webImage != null)
                            ? Image.memory(
                                webImage!,
                                fit: BoxFit.cover,
                              )
                            :

                            // nenhuma imagem selecionada => exibir imagem já existente
                            CachedNetworkImage(
                                imageUrl: widget.user.profileImageUrl,

                                // carregando
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),

                                // erros
                                errorWidget: (context, url, error) => Icon(
                                  Icons.person,
                                  size: 72,
                                  color: Theme.of(context).colorScheme.primary,
                                ),

                                // carregado
                                imageBuilder: (context, imageProvider) => Image(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              )),
          ),
          const SizedBox(height: 25),

          // botão selecionar imagem
          Center(
            child: MaterialButton(
              onPressed: pickImage,
              color: Colors.blue,
              child: const Text('Selecionar imagem'),
            ),
          ),

          const SizedBox(height: 25),

          // bio
          const Text('Bio'),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: MyTextField(
                controller: bioTextController,
                hintText: widget.user.bio,
                obscureText: false),
          )
        ],
      ),
    );
  }
}
