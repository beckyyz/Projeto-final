import 'package:flutter/material.dart';
import 'dart:io';
import '../services/auth_service.dart';

/// Widget para criar o Drawer (menu lateral) do aplicativo
class AppDrawer extends StatelessWidget {
  final String currentPage;
  final Function(String) onNavigate;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.currentPage,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: FutureBuilder(
              future: AuthService.getCurrentUser(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Theme.of(context).cardColor,
                      backgroundImage: user?.profileImagePath != null
                          ? FileImage(File(user!.profileImagePath!))
                          : null,
                      child: user?.profileImagePath == null
                          ? Icon(
                              Icons.person,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            )
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.name ?? 'Usuário',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Trip Diary',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Seu diário de viagens',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                );
              },
            ),
          ),
          _buildNavItem('home', 'Início', Icons.home),
          _buildNavItem('user', 'Usuário', Icons.person),
          _buildNavItem('trips', 'Viagens', Icons.flight_takeoff),
          _buildNavItem('settings', 'Configurações', Icons.settings),
          _buildNavItem('help', 'Ajuda', Icons.help),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  ListTile _buildNavItem(String page, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: currentPage == page,
      onTap: () => onNavigate(page),
    );
  }
}

/// Função para obter o título apropriado baseado na página atual
String getPageTitle(String currentPage) {
  switch (currentPage) {
    case 'home':
      return 'Trip Diary';
    case 'trips':
      return 'Minhas Viagens';
    case 'user':
      return 'Perfil do Usuário';
    case 'settings':
      return 'Configurações';
    case 'help':
      return 'Ajuda';
    default:
      return 'Trip Diary';
  }
}
