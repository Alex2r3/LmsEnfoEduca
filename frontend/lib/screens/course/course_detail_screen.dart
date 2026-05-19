import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../config/app_theme.dart';
import '../../providers/course_provider.dart';
import '../../providers/auth_provider.dart';

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
        actions: [
          _buildDeleteCourseButton(context),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
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
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && (user.role == 'admin' || user.role == 'profesor')) {
      return FloatingActionButton.extended(
        onPressed: () => _showEnrollDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Matricular Alumno'),
        backgroundColor: Color(int.parse(course.color.replaceFirst('#', '0xFF'))),
      );
    }
    return null;
  }

  Widget _buildDeleteCourseButton(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.role == 'admin') {
      return IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Eliminar Curso',
        onPressed: () => _confirmDeleteCourse(context),
      );
    }
    return const SizedBox.shrink();
  }

  void _confirmDeleteCourse(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar curso?'),
        content: const Text('Esta acción no se puede deshacer y el curso desaparecerá para todos los alumnos y profesores.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final provider = Provider.of<CourseProvider>(context, listen: false);
                await provider.deleteCourse(course.id);
                if (ctx.mounted) {
                  Navigator.pop(ctx); // Cierra diálogo
                  Navigator.pop(context); // Sale de detalles del curso
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Curso eliminado correctamente'), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }

  void _showEnrollDialog(BuildContext context) {
    final TextEditingController idController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Matricular Alumno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa el ID del estudiante (puedes sacarlo de la consola o la base de datos).'),
            const SizedBox(height: 16),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'ID del Estudiante',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (idController.text.isEmpty) return;
              
              try {
                final provider = Provider.of<CourseProvider>(context, listen: false);
                await provider.enrollStudent(course.id, idController.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alumno matriculado exitosamente')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
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
