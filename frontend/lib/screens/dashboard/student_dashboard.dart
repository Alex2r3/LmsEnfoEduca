import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_model.dart';
import '../../config/app_theme.dart';
import '../../services/onboarding_service.dart';
import '../course/courses_screen.dart';
import '../course/course_detail_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _coursesKey = GlobalKey();

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
      targets: OnboardingService.getStudentTargets(_headerKey, _statsKey, _coursesKey),
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
                _buildDynamicHeader(user!, isAura),
                const SizedBox(height: 32),
                _buildStatsGrid(data, isAura),
                const SizedBox(height: 32),
                _buildSectionTitle('Tus Logros 🏅', isAura),
                const SizedBox(height: 16),
                _buildAchievementRow(isAura),
                const SizedBox(height: 32),
                _buildSectionTitle('Próxima Tarea ⏰', isAura),
                const SizedBox(height: 16),
                _buildNextTaskCard(data['upcomingTasks']?.isNotEmpty == true ? data['upcomingTasks'][0] : null, isAura),
                const SizedBox(height: 32),
                _buildSectionHeader('Mis Cursos 📚', isAura),
                const SizedBox(height: 16),
                Container(key: _coursesKey, child: _buildCoursesGrid(courseProvider.courses, isAura)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: themeProvider.toggleTheme,
        backgroundColor: isAura ? Colors.white : AppTheme.primaryBlue,
        child: Icon(
          isAura ? Icons.auto_awesome : Icons.palette,
          color: isAura ? const Color(0xFF6A11CB) : Colors.white,
        ),
      ),
    );
  }

  Widget _buildDynamicHeader(User user, bool isAura) {
    return Row(
      key: _headerKey,
      children: [
        Hero(
          tag: 'profile-pic',
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.amber, Colors.orange]),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: isAura ? Colors.white24 : AppTheme.primaryBlue.withOpacity(0.1),
              child: Text(
                user.firstName[0],
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isAura ? Colors.white : AppTheme.primaryBlue),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Hola, ${user.firstName}! 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isAura ? Colors.white : Colors.black87,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Nivel ${user.level} • Guerrero del Aprendizaje',
                style: TextStyle(
                  fontSize: 14,
                  color: isAura ? Colors.white70 : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _showOnboarding,
          icon: Icon(Icons.help_outline, color: isAura ? Colors.white : Colors.black54),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isAura) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isAura ? Colors.white : Colors.black87)),
        TextButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CoursesScreen())),
          child: Text('Ver todo', style: TextStyle(color: isAura ? Colors.white70 : AppTheme.primaryBlue)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isAura) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isAura ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildAchievementRow(bool isAura) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildMedal('🔥', '7 días seguidos', isAura),
          _buildMedal('📚', 'Bibliotecario', isAura),
          _buildMedal('⚡', 'Velocista', isAura),
          _buildMedal('🎯', 'Precisión 100%', isAura),
        ],
      ),
    );
  }

  Widget _buildMedal(String emoji, String label, bool isAura) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isAura ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isAura ? Colors.white10 : Colors.white, width: 1.5),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isAura ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildNextTaskCard(Map<String, dynamic>? task, bool isAura) {
    if (task == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isAura ? const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]) : const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('VENCE PRONTO', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                child: const Text('¡Urgente!', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(task['title'] ?? 'Sin título', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Fecha: 12 de Mayo del 2026', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> data, bool isAura) {
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
      return GridView.count(
        key: _statsKey,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: constraints.maxWidth > 900 ? 2.5 : 1.8,
        children: [
          _buildMiniStatCard('Tareas', '${data['pendingTasks'] ?? 0}', Icons.assignment_rounded, Colors.orange, isAura),
          _buildMiniStatCard('Puntos', '${data['points'] ?? 0}', Icons.auto_awesome, Colors.amber, isAura),
          _buildMiniStatCard('Nivel', '${data['level'] ?? 1}', Icons.trending_up_rounded, Colors.green, isAura),
          _buildMiniStatCard('Cursos', '${data['totalCourses'] ?? 0}', Icons.book_rounded, Colors.blue, isAura),
        ],
      );
    });
  }

  Widget _buildMiniStatCard(String title, String value, IconData icon, Color color, bool isAura) {
    return Container(
      decoration: BoxDecoration(
        gradient: isAura 
          ? LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : LinearGradient(
              colors: [color.withOpacity(0.1), Colors.white.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isAura ? color.withOpacity(0.2) : Colors.white, width: 2),
        boxShadow: isAura ? [] : [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              value, 
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.w900, 
                color: isAura ? Colors.white : Colors.black87,
                height: 1,
              )
            ),
            const SizedBox(height: 2),
            Text(
              title, 
              style: TextStyle(
                fontSize: 11, 
                fontWeight: FontWeight.w600, 
                color: isAura ? Colors.white70 : Colors.grey.shade600,
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesGrid(List courses, bool isAura) {
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: courses.length > 4 ? 4 : courses.length, // Only show top 4 on home
        itemBuilder: (context, index) {
          final course = courses[index];
          return _buildCourseCard(course, isAura);
        },
      );
    });
  }

  Widget _buildCourseCard(course, bool isAura) {
    return Container(
      decoration: BoxDecoration(
        color: isAura ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isAura ? Colors.white10 : Colors.white, width: 2),
        boxShadow: isAura ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)),
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 10,
              width: double.infinity,
              color: Color(int.parse(course.color.replaceFirst('#', '0xFF'))),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.calculate, color: AppTheme.primaryBlue, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    course.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.code,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildUpcomingTasks(List tasks) {
    if (tasks.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('¡No tienes tareas pendientes! 🎉')),
        ),
      );
    }

    return Column(
      children: tasks.map((task) => _buildTaskItem(task)).toList(),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.assignment, color: AppTheme.primaryBlue),
          ),
          title: Text(task['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Fecha de entrega: ${task['dueDate'].toString().split('T')[0]}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ),
    );
  }
}
