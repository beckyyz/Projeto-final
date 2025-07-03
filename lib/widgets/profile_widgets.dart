import 'package:diario_viagem/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/user.dart';

/// Widget para exibir a foto de perfil do usuário com botão para alterar
class ProfileAvatar extends StatelessWidget {
  final User? user;
  final double radius;
  final VoidCallback onTap;

  const ProfileAvatar({
    super.key,
    required this.user,
    this.radius = 60,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.blue,
          backgroundImage: user?.profileImagePath != null
              ? FileImage(File(user!.profileImagePath!))
              : null,
          child: user?.profileImagePath == null
              ? Icon(Icons.person, size: radius * 1.3, color: Colors.white)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              onPressed: onTap,
            ),
          ),
        ),
      ],
    );
  }
}

/// Card para informações do usuário
class UserInfoCard extends StatelessWidget {
  final String title;
  final String value;

  const UserInfoCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: const Color(0xFFA6A6A6))),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card para ações do usuário
class UserActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const UserActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: TextStyle(color: const Color(0xFFA6A6A6))),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        tileColor: const Color.fromARGB(255, 226, 226, 226),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
