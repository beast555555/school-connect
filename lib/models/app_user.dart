class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String className;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.className,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      className: map['className'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'className': className,
    };
  }
}