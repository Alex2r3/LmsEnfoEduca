import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class SettingsDetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isAura;

  const SettingsDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.isAura = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: isAura ? AppTheme.auraGradient : null,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 150,
              pinned: true,
              backgroundColor: isAura ? Colors.transparent : AppTheme.primaryBlue,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black26, Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isAura ? Colors.white.withOpacity(0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isAura ? Colors.white10 : Colors.grey.shade100),
                        boxShadow: isAura ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
                      ),
                      child: Column(
                        children: [
                          Icon(icon, size: 64, color: isAura ? Colors.white : AppTheme.primaryBlue),
                          const SizedBox(height: 24),
                          Text(
                            description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: isAura ? Colors.white70 : Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('ENTENDIDO'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
