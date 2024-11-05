class AppUser {
  final String uid;
  final String email;
  final String name;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
  });

  // transformar usuário em um json
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
    };
  }

  // transformar json em um usuário
  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'],
      email: jsonUser['email'],
      name: jsonUser['name'],
    );
  }
}
