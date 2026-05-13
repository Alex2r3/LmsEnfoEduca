import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../config/app_theme.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.name),
        backgroundColor: Color(int.parse(course.color.replaceFirst('#', '0xFF'))),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseHeader(context),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Información del Curso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(course.description),
                  const SizedBox(height: 24),
                  const Text('Profesor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(course.teacher?.fullName ?? 'Sin profesor'),
                    subtitle: Text(course.teacher?.email ?? ''),
                  ),
                  const SizedBox(height: 24),
                  const Text('Horario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
                      title: Text(course.schedule['day'] ?? 'No definido'),
                      subtitle: Text('${course.schedule['startTime']} - ${course.schedule['endTime']}'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseHeader(BuildContext context) {
    final color = Color(int.parse(course.color.replaceFirst('#', '0xFF')));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calculate, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            course.code,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
          Text(
            course.category,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
