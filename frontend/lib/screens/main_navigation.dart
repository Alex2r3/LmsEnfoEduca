import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard/student_dashboard.dart';
import 'dashboard/teacher_dashboard.dart';
import 'dashboard/parent_dashboard.dart';
import 'dashboard/admin_dashboard.dart';
import 'course/courses_screen.dart';
import 'profile/profile_screen.dart';
import '../config/app_theme.dart';
import '../../providers/theme_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isAura = context.watch<ThemeProvider>().currentMode == CustomThemeMode.aura;
    
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Define dashboard based on role
    Widget getDashboard() {
      switch (user.role) {
        case 'profesor': return TeacherDashboard();
        case 'padre': return ParentDashboard();
        case 'admin': return AdminDashboard();
        default: return StudentDashboard();
      }
    }

    final List<Widget> screens = [
      getDashboard(),
      CoursesScreen(),
      const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Mis Tareas Pendientes', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      )),
      ProfileScreen(),
    ];

    final bool isDesktop = MediaQuery.of(context).size.width > 900;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              labelType: NavigationRailLabelType.all,
              backgroundColor: isAura ? const Color(0xFF1E1E3F) : AppTheme.darkCard,
              unselectedIconTheme: IconThemeData(color: isAura ? Colors.white38 : Colors.white54),
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedLabelTextStyle: TextStyle(color: isAura ? Colors.white38 : Colors.white54),
              selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Icon(Icons.school, size: 40, color: Colors.white),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Inicio')),
                NavigationRailDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: Text('Cursos')),
                NavigationRailDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: Text('Tareas')),
                NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Perfil')),
              ],
            ),
            Expanded(child: screens[_selectedIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: isAura ? const Color(0xFF1E1E3F) : null,
        indicatorColor: isAura ? Colors.white10 : null,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: 'Cursos'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Tareas'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
