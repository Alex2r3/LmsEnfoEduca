import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/main_navigation.dart';
import '../screens/course/courses_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/error_screen.dart';

class AppRouter {
  static GoRouter router(AuthProvider authProvider) => GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const ErrorScreen(),
    refreshListenable: authProvider,
    redirect: (context, state) {
      if (authProvider.isInitializing) return null;

      final isLoggingIn = state.matchedLocation == '/login';
      final isError = state.matchedLocation == '/error';

      // 1. If not authenticated, force login (unless already logging in)
      if (!authProvider.isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      // 2. If authenticated but on login page, go home
      if (isLoggingIn) {
        return '/';
      }

      // 3. Optional: Role-based sub-route protection
      // Example: if (state.matchedLocation.startsWith('/admin') && authProvider.user?.role != 'admin') return '/error';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/error',
        builder: (context, state) => const ErrorScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainNavigation(),
        routes: [
          GoRoute(
            path: 'courses',
            builder: (context, state) => const CoursesScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
