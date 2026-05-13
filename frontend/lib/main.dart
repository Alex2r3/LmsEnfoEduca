import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation.dart';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'config/router.dart';

void main() {
  usePathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // We initialize the router once to avoid resets on rebuilds
    final authProvider = context.read<AuthProvider>();
    _router = AppRouter.router(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return MaterialApp.router(
      title: 'EnfoEduca',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      routerConfig: _router,
    );
  }
}
