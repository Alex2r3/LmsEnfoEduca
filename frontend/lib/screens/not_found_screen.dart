import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 100, color: AppTheme.primaryOrange),
              const SizedBox(height: 24),
              const Text(
                '404',
                style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
              ),
              const Text(
                'Página no encontrada',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lo sentimos, la página que buscas no existe o todavía está en desarrollo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('VOLVER ATRÁS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
