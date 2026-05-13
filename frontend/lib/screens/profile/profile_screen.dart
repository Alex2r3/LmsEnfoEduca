import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_model.dart';
import '../../config/app_theme.dart';
import 'settings_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final themeProvider = context.watch<ThemeProvider>();
    final isAura = themeProvider.currentMode == CustomThemeMode.aura;

    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      body: Container(
        decoration: isAura ? AppTheme.auraGradient : null,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: isAura ? Colors.transparent : null,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isAura) Container(decoration: AppTheme.auraGradient) else Container(color: AppTheme.primaryBlue),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: isAura ? Colors.white10 : Colors.white24,
                          child: user.avatar.isNotEmpty 
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CachedNetworkImage(
                                  imageUrl: user.avatar,
                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Text(user.firstName[0], style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              )
                            : Text(user.firstName[0], style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(user.fullName, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isAura ? Colors.white : Colors.black87)),
                    Text(user.email, style: TextStyle(color: isAura ? Colors.white70 : Colors.grey)),
                    const SizedBox(height: 12),
                    Chip(
                      label: Text(user.role.toUpperCase()),
                      backgroundColor: AppTheme.getRoleColor(user.role).withOpacity(0.2),
                      side: BorderSide.none,
                    ),
                    const SizedBox(height: 32),
                    if (user.role == 'alumno') _buildInfoCard(context, user, isAura),
                    const SizedBox(height: 24),
                    _buildSettingsSection(context, themeProvider, isAura),
                    const SizedBox(height: 32),
                    _buildLogoutButton(context, auth),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, User user, bool isAura) {
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
          _buildInfoItem(Icons.stars_rounded, '${user.points}', 'PUNTOS', Colors.amber),
          _buildInfoItem(Icons.trending_up_rounded, '${user.level}', 'NIVEL', Colors.blue),
          _buildInfoItem(Icons.emoji_events_rounded, '${user.badges.length}', 'LOGROS', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, ThemeProvider themeProvider, bool isAura) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PREFERENCIAS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        _buildThemeSelector(themeProvider, isAura),
        const SizedBox(height: 24),
        const Text('CUENTA Y AYUDA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        _buildSettingsTile(
          Icons.notifications_active_outlined, 
          'Notificaciones', 
          isAura, 
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsDetailScreen(
            title: 'Notificaciones',
            description: 'Tus alertas académicas están sincronizadas. Recibirás avisos sobre nuevas tareas, calificaciones y anuncios en tiempo real.',
            icon: Icons.notifications_active_outlined,
            isAura: isAura,
          )))
        ),
        _buildSettingsTile(
          Icons.lock_reset_rounded, 
          'Seguridad y Privacidad', 
          isAura, 
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsDetailScreen(
            title: 'Seguridad',
            description: 'Para cambiar tu contraseña o gestionar la seguridad de tu cuenta, contacta con el administrador del centro educativo o usa el flujo de recuperación de contraseña.',
            icon: Icons.lock_reset_rounded,
            isAura: isAura,
          )))
        ),
        _buildSettingsTile(
          Icons.support_agent_rounded, 
          'Soporte y Ayuda', 
          isAura, 
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsDetailScreen(
            title: 'Soporte Técnico',
            description: 'Si tienes problemas con la plataforma, nuestro equipo de soporte está disponible. Correo: soporte@enfoeduca.com',
            icon: Icons.support_agent_rounded,
            isAura: isAura,
          )))
        ),
        _buildSettingsTile(
          Icons.info_outline_rounded, 
          'Acerca de EnfoEduca', 
          isAura, 
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsDetailScreen(
            title: 'Acerca de',
            description: 'EnfoEduca v2.0 - Microservicios & Aura Design. Desarrollado para transformar la experiencia educativa con tecnología moderna.',
            icon: Icons.info_outline_rounded,
            isAura: isAura,
          )))
        ),
      ],
    );
  }

  Widget _buildThemeSelector(ThemeProvider themeProvider, bool isAura) {
    return Row(
      children: [
        _buildThemeOption(themeProvider, CustomThemeMode.light, Icons.light_mode, 'Claro'),
        const SizedBox(width: 8),
        _buildThemeOption(themeProvider, CustomThemeMode.dark, Icons.dark_mode, 'Oscuro'),
        const SizedBox(width: 8),
        _buildThemeOption(themeProvider, CustomThemeMode.aura, Icons.auto_awesome, 'Aura'),
      ],
    );
  }

  Widget _buildThemeOption(ThemeProvider theme, CustomThemeMode mode, IconData icon, String label) {
    final isSelected = theme.currentMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => theme.setTheme(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, bool isAura, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: isAura ? Colors.white10 : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: isAura ? Colors.white70 : Colors.black87, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context, auth),
        icon: const Icon(Icons.logout),
        label: const Text('CERRAR SESIÓN'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.1),
          foregroundColor: Colors.red,
          elevation: 0,
        ),
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

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar Sesión?'),
        content: const Text('Tus progresos han sido guardados.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(onPressed: () => auth.logout(), child: const Text('SÍ, SALIR')),
        ],
      ),
    );
  }
}
