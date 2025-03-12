import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rede_social/features/profile/domain/entities/profile_user.dart';
import 'package:rede_social/features/profile/domain/repository/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      final userDoc =
          await firebaseFirestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();

        if (userData != null) {
          // buscar seguidores e seguidos
          final followers = List<String>.from(userData['followers'] ?? []);
          final following = List<String>.from(userData['following'] ?? []);

          return ProfileUser(
            uid: uid,
            email: userData['email'],
            name: userData['name'],
            bio: userData['bio'] ?? '',
            profileImageUrl: userData['profileImageUrl'].toString(),
            followers: followers,
            following: following,
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateProfile(ProfileUser updatedProfile) async {
    try {
      // converte o perfil atualizado em json para armazenar no firebase
      await firebaseFirestore
          .collection('users')
          .doc(updatedProfile.uid)
          .update({
        'bio': updatedProfile.bio,
        'profileImageUrl': updatedProfile.profileImageUrl,
      });
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async {
    try {
      final currentUserDoc =
          await firebaseFirestore.collection('users').doc(currentUid).get();
      final targetUserDoc =
          await firebaseFirestore.collection('users').doc(targetUid).get();

      if (currentUserDoc.exists && targetUserDoc.exists) {
        final currentUserData = currentUserDoc.data();
        final targetUserData = targetUserDoc.data();

        if (currentUserData != null && targetUserData != null) {
          final List<String> currentFollowing =
              List<String>.from(currentUserData['following'] ?? []);

          // checar se o usuário já segue o usuário de destino
          if (currentFollowing.contains(targetUid)) {
            // para de seguir
            await firebaseFirestore.collection('users').doc(currentUid).update({
              'following': FieldValue.arrayRemove([targetUid])
            });
            await firebaseFirestore.collection('users').doc(targetUid).update({
              'followers': FieldValue.arrayRemove([currentUid])
            });
          } else {
            // começa a seguir
            await firebaseFirestore.collection('users').doc(currentUid).update({
              'following': FieldValue.arrayUnion([targetUid])
            });
            await firebaseFirestore.collection('users').doc(targetUid).update({
              'followers': FieldValue.arrayUnion([currentUid])
            });
          }
        }
      }
    } catch (e) {}
  }
}
