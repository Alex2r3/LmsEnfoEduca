import 'user_model.dart';

class Course {
  final String id;
  final String name;
  final String description;
  final String code;
  final String color;
  final String icon;
  final User? teacher;
  final List<User> students;
  final Map<String, dynamic> schedule;
  final String category;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.code,
    required this.color,
    required this.icon,
    this.teacher,
    this.students = const [],
    this.schedule = const {},
    required this.category,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      code: json['code'] ?? '',
      color: json['color'] ?? '#4A90D9',
      icon: json['icon'] ?? 'book',
      teacher: json['teacher'] != null ? User.fromJson(json['teacher']) : null,
      students: json['students'] != null
          ? (json['students'] as List).map((s) => User.fromJson(s)).toList()
          : [],
      schedule: json['schedule'] ?? {},
      category: json['category'] ?? 'Otro',
    );
  }
}
