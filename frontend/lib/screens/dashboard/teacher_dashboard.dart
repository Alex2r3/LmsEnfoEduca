import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_model.dart';
import '../../config/app_theme.dart';
import '../../services/onboarding_service.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _actionsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchDashboardData();
    });
  }

  void _showOnboarding() {
    OnboardingService.showSpotlight(
      context: context,
      targets: OnboardingService.getTeacherTargets(_statsKey, _actionsKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final themeProvider = context.watch<ThemeProvider>();
    final isAura = themeProvider.currentMode == CustomThemeMode.aura;
    final courseProvider = context.watch<CourseProvider>();
    final data = courseProvider.dashboardData;

    if (courseProvider.isLoading && data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Container(
        decoration: isAura ? AppTheme.auraGradient : null,
        child: RefreshIndicator(
          onRefresh: () => context.read<CourseProvider>().fetchDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernHeader(user!, isAura),
                const SizedBox(height: 32),
                _buildStatsGrid(data, isAura),
                const SizedBox(height: 32),
                _buildSectionLabel('ACCIONES RÁPIDAS ⚡', isAura),
                const SizedBox(height: 16),
                Container(key: _actionsKey, child: _buildQuickActions(isAura)),
                const SizedBox(height: 32),
                _buildSectionLabel('GESTIÓN DE CURSOS 📚', isAura),
                const SizedBox(height: 16),
                _buildCoursesList(courseProvider.courses, isAura),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(User user, bool isAura) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panel Docente 🏫',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isAura ? Colors.white : Colors.black87),
            ),
            Text(
              'Bienvenido, Prof. ${user.lastName}',
              style: TextStyle(color: isAura ? Colors.white70 : Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        IconButton(
          onPressed: _showOnboarding,
          icon: Icon(Icons.help_outline, color: isAura ? Colors.white : Colors.black54),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text, bool isAura) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isAura ? Colors.white70 : Colors.grey.shade700, letterSpacing: 1.2),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> data, bool isAura) {
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;
      return GridView.count(
        key: _statsKey,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: constraints.maxWidth > 900 ? 2.2 : 1.8, // Increased height
        children: [
          _buildStatCard('Cursos', '${data['totalCourses'] ?? 0}', Icons.book_rounded, AppTheme.primaryGreen, isAura),
          _buildStatCard('Alumnos', '${data['totalStudents'] ?? 0}', Icons.people_rounded, AppTheme.primaryBlue, isAura),
          _buildStatCard('Pendientes', '${data['pendingGrading'] ?? 0}', Icons.assignment_rounded, AppTheme.primaryOrange, isAura),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isAura) {
    return Container(
      decoration: BoxDecoration(
        gradient: isAura 
          ? LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : LinearGradient(
              colors: [color.withOpacity(0.08), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isAura ? color.withOpacity(0.2) : color.withOpacity(0.1), width: 1.5),
        boxShadow: isAura ? [] : [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.w900, 
                color: isAura ? Colors.white : Colors.black87,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w600, 
                color: isAura ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isAura) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isAura ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isAura ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(Icons.add_task_rounded, 'Tarea', AppTheme.primaryOrange, isAura),
          _buildActionItem(Icons.how_to_reg_rounded, 'Asistencia', AppTheme.primaryGreen, isAura),
          _buildActionItem(Icons.campaign_rounded, 'Anuncio', AppTheme.primaryPurple, isAura),
          _buildActionItem(Icons.analytics_rounded, 'Reportes', AppTheme.primaryBlue, isAura),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color, bool isAura) {
    return InkWell(
      onTap: () => _handleAction(label),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isAura ? Colors.white : color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAura ? Colors.white70 : Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  void _handleAction(String label) {
    if (label == 'Tarea') {
      final courses = context.read<CourseProvider>().courses;
      final isAura = context.read<ThemeProvider>().currentMode == CustomThemeMode.aura;
      showDialog(
        context: context,
        builder: (context) => _CreateTaskDialog(courses: courses, isAura: isAura),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: Text('Esta es una funcionalidad para: $label. \nPróximamente podrás gestionar todos los detalles desde aquí.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CERRAR')),
        ],
      ),
    );
  }

  Widget _buildCoursesList(List courses, bool isAura) {
    if (courses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.book_outlined, size: 48, color: isAura ? Colors.white24 : Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('No tienes cursos asignados', style: TextStyle(color: isAura ? Colors.white38 : Colors.grey)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final courseColor = Color(int.parse(course.color.replaceFirst('#', '0xFF')));
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isAura ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isAura ? Colors.white10 : Colors.grey.shade100),
          ),
          child: ListTile(
            leading: Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(color: courseColor, borderRadius: BorderRadius.circular(2)),
            ),
            title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('${course.code} • ${course.students.length} alumnos', style: const TextStyle(fontSize: 11)),
            trailing: Icon(Icons.arrow_forward_ios, size: 14, color: isAura ? Colors.white24 : Colors.grey),
            onTap: () {},
          ),
        );
      },
    );
  }
}

class _CreateTaskDialog extends StatefulWidget {
  final List courses;
  final bool isAura;
  const _CreateTaskDialog({required this.courses, required this.isAura});
  @override
  State<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<_CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String? _courseId;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  final String _type = 'tarea';
  final int _maxGrade = 20;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Tarea'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
                onSaved: (v) => _title = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descripción'),
                onSaved: (v) => _description = v ?? '',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Curso'),
                value: _courseId,
                items: widget.courses.map<DropdownMenuItem<String>>((c) {
                  return DropdownMenuItem<String>(
                    value: c.id,
                    child: Text(c.name),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _courseId = v),
                validator: (v) => v == null ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha de entrega'),
                subtitle: Text('${_dueDate.day}/${_dueDate.month}/${_dueDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) setState(() => _dueDate = d);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
        ElevatedButton(
          onPressed: _isLoading ? null : () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              setState(() => _isLoading = true);
              try {
                await context.read<CourseProvider>().createTask({
                  'title': _title,
                  'description': _description,
                  'courseId': _courseId,
                  'dueDate': _dueDate.toIso8601String(),
                  'type': _type,
                  'maxGrade': _maxGrade,
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarea creada exitosamente')));
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            }
          },
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('CREAR'),
        ),
      ],
    );
  }
}
