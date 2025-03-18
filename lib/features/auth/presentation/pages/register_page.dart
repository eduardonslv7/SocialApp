import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rede_social/features/auth/presentation/components/my_button.dart';
import 'package:rede_social/features/auth/presentation/components/my_text_field.dart';
import 'package:rede_social/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:rede_social/responsive/constrained_scaffold.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // controllers
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // lógica para o botão de registrar
  void register() {
    // busca nome, email e senhas
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    // auth cubit
    final authCubit = context.read<AuthCubit>();

    // verifica se os campos nome, email & senhas não estão vazios
    if (name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      // confirma se as senhas combinam
      if (password == confirmPassword) {
        authCubit.register(name, email, password);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'A senha e a confirmação de senha não coincidem. Por favor, verifique e tente novamente')));
      }
      // login
      authCubit.login(email, password);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, complete todos os campos')));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_open_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 50),
                Text(
                  "Vamos criar uma conta para você",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 50),

                // campo para o nome
                MyTextField(
                  controller: nameController,
                  hintText: 'Nome',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // campo para o email
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // campo para a senha
                MyTextField(
                  controller: passwordController,
                  hintText: 'Senha',
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                // campo para confirmar a senha
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirme a sua senha',
                  obscureText: true,
                ),
                const SizedBox(height: 25),

                // botão de registrar
                MyButton(
                    onTap: () {
                      register();
                    },
                    text: 'Registrar'),

                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Já possui uma conta? ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        'Entre agora',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
