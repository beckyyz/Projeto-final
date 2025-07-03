import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/theme_manager.dart';

/// Widget para exibir cards de configurações
class SettingsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const SettingsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        tileColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Widget para exibir a página de configurações
class SettingsPage extends StatelessWidget {
  final VoidCallback onManageNotifications;
  final VoidCallback onChangePassword;
  final VoidCallback onShowAboutApp;

  const SettingsPage({
    super.key,
    required this.onManageNotifications,
    required this.onChangePassword,
    required this.onShowAboutApp,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDark = themeManager.isDarkMode;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        // Card para alternar entre tema claro e escuro
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('Tema do Aplicativo'),
            subtitle: Text(isDark ? 'Tema Escuro' : 'Tema Claro'),
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                themeManager.toggleTheme();
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            tileColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SettingsCard(
          title: 'Notificações',
          subtitle: 'Configurar alertas e lembretes',
          icon: Icons.notifications,
          onTap: onManageNotifications,
        ),
        SettingsCard(
          title: 'Alterar Senha',
          subtitle: 'Gerenciar sua senha de acesso',
          icon: Icons.lock,
          onTap: onChangePassword,
        ),
        SettingsCard(
          title: 'Sobre',
          subtitle: 'Informações sobre o aplicativo',
          icon: Icons.info,
          onTap: onShowAboutApp,
        ),
      ],
    );
  }
}

/// Widget para exibir cards de ajuda
class HelpCard extends StatelessWidget {
  final String question;
  final String answer;

  const HelpCard({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(answer, style: TextStyle(color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }
}

/// Widget para exibir a página de ajuda
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SizedBox(height: 20),
        HelpCard(
          question: 'Como adicionar uma viagem?',
          answer:
              'Clique no botão "Nova Viagem" na página de viagens e preencha os dados.',
        ),
        HelpCard(
          question: 'Como adicionar fotos?',
          answer:
              'Entre nos detalhes da viagem e use a aba "Fotos" para adicionar imagens.',
        ),
        HelpCard(
          question: 'Como gerenciar notificações?',
          answer:
              'Use o ícone de sino no topo da tela ou vá em Configurações > Notificações.',
        ),
        HelpCard(
          question: 'Precisa de mais ajuda?',
          answer: 'Entre em contato conosco pelo email: suporte@tripdiario.com',
        ),
      ],
    );
  }
}
