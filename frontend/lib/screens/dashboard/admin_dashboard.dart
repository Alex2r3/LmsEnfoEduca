import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_model.dart';
import '../../config/app_theme.dart';
import '../../services/onboarding_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
      targets: OnboardingService.getAdminTargets(_statsKey, _actionsKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final themeProvider = context.watch<ThemeProvider>();
    final isAura = themeProvider.currentMode == CustomThemeMode.aura;
    final data = context.watch<CourseProvider>().dashboardData;

    return Scaffold(
      body: AppTheme.meshBackground(
        isAura: isAura,
        child: SingleChildScrollView(
          key: const PageStorageKey('admin_dashboard_scroll'),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernHeader(user!, isAura),
              const SizedBox(height: 40),
              _buildAdminStats(data, isAura),
              const SizedBox(height: 40),
              _buildSectionLabel('GESTIÓN DE USUARIOS 👥', isAura),
              const SizedBox(height: 20),
              _buildUserManagementGrid(isAura),
              const SizedBox(height: 40),
              _buildSectionLabel('ADMINISTRAR CURSOS 📚', isAura),
              const SizedBox(height: 20),
              _buildCourseManager(isAura),
              const SizedBox(height: 40),
              _buildSectionLabel('ACTIVIDAD RECIENTE 🕒', isAura),
              const SizedBox(height: 20),
              _buildRecentActivities(isAura),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserDialog(context),
        label: const Text('NUEVA CUENTA'),
        icon: const Icon(Icons.person_add_alt_1),
        backgroundColor: isAura ? Colors.white : AppTheme.primaryPurple,
        foregroundColor: isAura ? AppTheme.auraStart : Colors.white,
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
              'Panel Admin 🛡️',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isAura ? Colors.white : Colors.black87),
            ),
            Text(
              'Bienvenido, ${user.firstName}',
              style: TextStyle(color: isAura ? Colors.white70 : Colors.grey.shade600),
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

  Widget _buildAdminStats(Map<String, dynamic> data, bool isAura) {
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
      return GridView.count(
        key: _statsKey,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: constraints.maxWidth > 900 ? 1.5 : 1.7,
        children: [
          _buildStatCard('Alumnos', '${data['totalStudents'] ?? 0}', Icons.school_rounded, AppTheme.studentColor, 'alumno', isAura),
          _buildStatCard('Profesores', '${data['totalTeachers'] ?? 0}', Icons.person_rounded, AppTheme.teacherColor, 'profesor', isAura),
          _buildStatCard('Padres', '${data['totalParents'] ?? 0}', Icons.family_restroom_rounded, AppTheme.parentColor, 'padre', isAura),
          _buildStatCard('Cursos', '${data['totalCourses'] ?? 0}', Icons.book_rounded, Colors.orange, null, isAura),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String? role, bool isAura) {
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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isAura ? color.withOpacity(0.2) : color.withOpacity(0.1), width: 1.5),
        boxShadow: isAura ? [] : [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: InkWell(
        onTap: role != null ? () => _showUserList(context, role, title, isAura) : null,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  if (role != null)
                    Icon(Icons.arrow_outward_rounded, color: color.withOpacity(0.4), size: 16),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 26, 
                  fontWeight: FontWeight.w900, 
                  color: isAura ? Colors.white : Colors.black87,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13, 
                  fontWeight: FontWeight.w600, 
                  color: isAura ? Colors.white70 : Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserList(BuildContext context, String role, String title, bool isAura) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isAura ? const Color(0xFF1E1E3F) : Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lista de $title',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isAura ? Colors.white : Colors.black87),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: isAura ? Colors.white70 : Colors.black54),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                  Divider(color: isAura ? Colors.white10 : Colors.grey.shade200),
                  Flexible(
                    child: FutureBuilder<List<User>>(
                      future: context.read<UserProvider>().getUsersByRole(role),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        final users = snapshot.data ?? [];
                        if (users.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text('No hay $title registrados', style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
                                child: Text(user.firstName[0], style: const TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(
                                '${user.firstName} ${user.lastName}',
                                style: TextStyle(color: isAura ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                user.email,
                                style: TextStyle(color: isAura ? Colors.white54 : Colors.grey),
                              ),
                              trailing: Icon(Icons.edit_outlined, size: 16, color: isAura ? Colors.white24 : Colors.grey),
                              onTap: () => _showUserDetail(context, user, isAura, onChanged: () {
                                setDialogState(() {});
                              }),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  void _showUserDetail(BuildContext context, User user, bool isAura, {VoidCallback? onChanged}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isAura ? const Color(0xFF1E1E3F) : Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
                child: Text(user.firstName[0], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple)),
              ),
              const SizedBox(height: 24),
              Text('${user.firstName} ${user.lastName}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(user.email, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.badge, 'Rol', user.role.toUpperCase()),
              _buildDetailRow(Icons.star, 'Nivel', '${user.level}'),
              _buildDetailRow(Icons.auto_awesome, 'Puntos', '${user.points} XP'),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CERRAR'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeleteUser(context, user, onChanged: onChanged);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Icon(Icons.delete_outline, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditUserDialog(context, user, isAura, onChanged: onChanged);
                      },
                      child: const Text('EDITAR'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, User user, {VoidCallback? onChanged}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Desactivar Usuario? ⚠️'),
        content: Text('¿Está seguro de que desea desactivar la cuenta de ${user.firstName} ${user.lastName}? El usuario ya no podrá iniciar sesión.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final success = await context.read<UserProvider>().deleteUser(user.id);
                if (success && mounted) {
                  Navigator.pop(context); // Close confirm
                  context.read<CourseProvider>().fetchDashboardData(); // Refresh stats
                  if (onChanged != null) onChanged();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuario desactivado correctamente 🗑️'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al desactivar: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DESACTIVAR'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, User user, bool isAura, {VoidCallback? onChanged}) {
    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Usuario ✏️'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Apellido')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () => _confirmUpdate(context, user, {
              'firstName': firstNameController.text,
              'lastName': lastNameController.text,
              'email': emailController.text,
            }, onChanged: onChanged),
            child: const Text('GUARDAR CAMBIOS'),
          ),
        ],
      ),
    );
  }

  void _confirmUpdate(BuildContext context, User user, Map<String, String> data, {VoidCallback? onChanged}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Confirmar cambios?'),
        content: const Text('Se actualizarán los datos del usuario en el sistema.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              try {
                final success = await context.read<UserProvider>().updateUser(user.id, data);
                if (success && mounted) {
                  Navigator.pop(context); // Close confirm
                  Navigator.pop(context); // Close edit
                  if (onChanged != null) onChanged();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Usuario actualizado con éxito! ✅'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagementGrid(bool isAura) {
    final roles = [
      {'name': 'Alumnos', 'icon': Icons.school, 'color': AppTheme.studentColor, 'role': 'alumno'},
      {'name': 'Profesores', 'icon': Icons.person, 'color': AppTheme.teacherColor, 'role': 'profesor'},
      {'name': 'Padres', 'icon': Icons.family_restroom, 'color': AppTheme.parentColor, 'role': 'padre'},
      {'name': 'Admins', 'icon': Icons.admin_panel_settings, 'color': AppTheme.adminColor, 'role': 'admin'},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: roles.length,
        itemBuilder: (context, index) {
          final role = roles[index];
          final Color color = role['color'] as Color;
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () => _showUserList(context, role['role'] as String, role['name'] as String, isAura),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: color.withOpacity(0.2), width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                      child: Icon(role['icon'] as IconData, color: color, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      role['name'] as String, 
                      style: TextStyle(color: isAura ? Colors.white : color, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseManager(bool isAura) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isAura ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isAura ? Colors.white10 : Colors.grey.shade100),
        boxShadow: isAura ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gestión Académica', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Crea y administra los cursos activos en el sistema.', style: TextStyle(color: isAura ? Colors.white54 : Colors.grey)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddCourseDialog(context, isAura),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('NUEVO CURSO'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCourseDialog(BuildContext context, bool isAura) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    String selectedCategory = 'Otro';
    String? selectedTeacher;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isAura ? const Color(0xFF1E1E3F) : Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🚀 Crear Nuevo Curso', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del Curso',
                      prefixIcon: const Icon(Icons.book_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'Código (ej: MAT101)',
                      prefixIcon: const Icon(Icons.qr_code_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<User>>(
                    future: context.read<UserProvider>().getUsersByRole('profesor'),
                    builder: (context, snapshot) {
                      final teachers = snapshot.data ?? [];
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Asignar Profesor',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: teachers.map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text('${t.firstName} ${t.lastName}'),
                        )).toList(),
                        onChanged: (v) => selectedTeacher = v,
                        validator: (v) => v == null ? 'Asigna un profesor' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['Matemáticas', 'Ciencias', 'Lenguaje', 'Historia', 'Arte', 'Tecnología', 'Inglés', 'Idiomas', 'Otro']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => selectedCategory = v!,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            final success = await context.read<CourseProvider>().createCourse({
                              'name': nameController.text.trim(),
                              'code': codeController.text.trim().toUpperCase(),
                              'teacherId': selectedTeacher,
                              'category': selectedCategory,
                            });
                            if (success && mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('¡Curso creado y asignado! 📚'), backgroundColor: Colors.green),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('CREAR CURSO'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities(bool isAura) {
    return Container(
      decoration: BoxDecoration(
        color: isAura ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isAura ? Colors.white10 : Colors.grey.shade100),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => Divider(color: isAura ? Colors.white10 : Colors.grey.shade100),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: const Icon(Icons.sync_alt, color: Colors.blue, size: 16),
            ),
            title: const Text('Actividad Reciente', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            subtitle: const Text('Actualización de datos en el sistema.', style: TextStyle(fontSize: 11)),
            trailing: const Text('Hoy', style: TextStyle(fontSize: 10, color: Colors.grey)),
          );
        },
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ENTENDIDO'))],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'alumno';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nueva Cuenta 👤', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Ingresa los datos para registrar al nuevo usuario.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: firstNameController,
                          decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person_outline)),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: lastNameController,
                          decoration: const InputDecoration(labelText: 'Apellido', prefixIcon: Icon(Icons.person_outline)),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email institucional', prefixIcon: Icon(Icons.email_outlined)),
                    validator: (v) => (v == null || !v.contains('@') || v.trim().isEmpty) ? 'Email inválido' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contraseña temporal', prefixIcon: Icon(Icons.lock_outline)),
                    validator: (v) => (v == null || v.length < 8 || v.trim().isEmpty) ? 'Mínimo 8 caracteres' : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(labelText: 'Rol del sistema', prefixIcon: Icon(Icons.badge_outlined)),
                    items: ['alumno', 'profesor', 'padre']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase())))
                        .toList(),
                    onChanged: (v) => selectedRole = v!,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              final success = await context.read<UserProvider>().createUser(
                                firstName: firstNameController.text.trim(),
                                lastName: lastNameController.text.trim(),
                                email: emailController.text.trim(),
                                password: passwordController.text,
                                role: selectedRole,
                              );
                              if (success && mounted) {
                                Navigator.pop(context);
                                context.read<CourseProvider>().fetchDashboardData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('¡Cuenta creada! 🚀'), backgroundColor: Colors.green),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('CREAR CUENTA'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
