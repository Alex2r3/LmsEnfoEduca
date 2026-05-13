class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String avatar;
  final int points;
  final int level;
  final List<dynamic> badges;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.avatar = '',
    this.points = 0,
    this.level = 1,
    this.badges = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'alumno',
      avatar: json['avatar'] ?? '',
      points: json['points'] ?? 0,
      level: json['level'] ?? 1,
      badges: json['badges'] ?? [],
    );
  }

  String get fullName => '$firstName $lastName';
}
