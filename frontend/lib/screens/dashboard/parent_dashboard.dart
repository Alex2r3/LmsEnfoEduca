import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_model.dart';
import '../../config/app_theme.dart';
import '../../services/onboarding_service.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final GlobalKey _childrenKey = GlobalKey();
  final GlobalKey _notificationsKey = GlobalKey();

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
      targets: OnboardingService.getParentTargets(_childrenKey, _notificationsKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final themeProvider = context.watch<ThemeProvider>();
    final isAura = themeProvider.currentMode == CustomThemeMode.aura;
    final data = context.watch<CourseProvider>().dashboardData;
    final children = data['children'] ?? [];

    return Scaffold(
      body: AppTheme.meshBackground(
        isAura: isAura,
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
                _buildSectionLabel('PROGRESO DE TUS HIJOS 👨‍👩‍👧‍👦', isAura),
                const SizedBox(height: 16),
                if (children.isEmpty)
                  _buildEmptyChildren(isAura)
                else
                  _buildChildrenGrid(children, data, isAura),
                const SizedBox(height: 32),
                _buildSectionLabel('NOTIFICACIONES RECIENTES 🔔', isAura),
                const SizedBox(height: 16),
                Container(key: _notificationsKey, child: _buildRecentNotifications(isAura)),
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
              'Portal Familiar 🏡',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isAura ? Colors.white : Colors.black87),
            ),
            Text(
              'Sr. ${user.lastName}, bienvenido.',
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

  Widget _buildEmptyChildren(bool isAura) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isAura ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isAura ? Colors.white10 : Colors.white, width: 2),
      ),
      child: Column(
        children: [
          Icon(Icons.child_care_rounded, size: 48, color: isAura ? Colors.white24 : Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No hay cuentas vinculadas', style: TextStyle(color: isAura ? Colors.white38 : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildChildrenGrid(List children, Map<String, dynamic> data, bool isAura) {
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
      if (crossAxisCount == 1) {
        return Column(
          key: _childrenKey,
          children: children.map((child) => _buildChildProgressCard(child, data, isAura)).toList(),
        );
      }
      return GridView.builder(
        key: _childrenKey,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => _buildChildProgressCard(children[index], data, isAura),
      );
    });
  }

  Widget _buildChildProgressCard(Map<String, dynamic> child, Map<String, dynamic> data, bool isAura) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isAura ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isAura ? Colors.white10 : Colors.white, width: 2),
        boxShadow: isAura ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.2),
                    child: Text(child['firstName'][0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppTheme.primaryBlue)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${child['firstName']} ${child['lastName']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildMiniChip('Nivel ${child['level']}', Colors.amber),
                            const SizedBox(width: 8),
                            _buildMiniChip('${child['points']} XP', Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildChildStat('CURSOS', '${child['totalCourses'] ?? 0}', Icons.book_outlined, Colors.blue, isAura),
                  _buildChildStat('TAREAS', '${child['completedTasks'] ?? 0}/${(child['completedTasks'] ?? 0) + (child['pendingTasks'] ?? 0)}', Icons.assignment_outlined, Colors.orange, isAura),
                  _buildChildStat('PROM.', '18.2', Icons.auto_graph_rounded, Colors.green, isAura),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildChildStat(String label, String value, IconData icon, Color color, bool isAura) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(fontSize: 9, color: isAura ? Colors.white38 : Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildRecentNotifications(bool isAura) {
    return Container(
      decoration: BoxDecoration(
        color: isAura ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isAura ? Colors.white10 : Colors.white, width: 2),
      ),
      child: Column(
        children: [
          _buildNotificationTile('Calificación recibida', 'Matemática - Tarea #4', 'Hace 20m', Icons.grade_rounded, Colors.green, isAura),
          _buildNotificationTile('Nuevo anuncio', 'Reunión de padres mañana', 'Hace 2h', Icons.campaign_rounded, Colors.orange, isAura),
          _buildNotificationTile('Falta registrada', 'Historia - 12 Mayo', 'Ayer', Icons.event_busy_rounded, Colors.red, isAura),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {},
              child: const Text('VER TODAS LAS NOTIFICACIONES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(String title, String sub, String time, IconData icon, Color color, bool isAura) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 11)),
      trailing: Text(time, style: TextStyle(fontSize: 10, color: isAura ? Colors.white24 : Colors.grey)),
    );
  }
}
