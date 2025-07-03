import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/user_data_service.dart';
import '../services/notification_service.dart';

/// Widget customizado para exibir cartões de viagem
class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const TripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem da viagem
            _buildTripImage(),

            // Conteúdo do card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTripHeader(context),
                  const SizedBox(height: 8),
                  _buildTripDestination(),
                  const SizedBox(height: 8),
                  _buildTripDescription(),
                  const SizedBox(height: 12),
                  _buildTripFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: trip.imagePath.startsWith('assets')
                ? AssetImage(trip.imagePath)
                : NetworkImage(trip.imagePath) as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            trip.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (showActions)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit' && onEdit != null) {
                onEdit!();
              } else if (value == 'delete' && onDelete != null) {
                onDelete!();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTripDestination() {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.blue, size: 16),
        const SizedBox(width: 4),
        Text(
          trip.destination,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTripDescription() {
    return Text(
      trip.description,
      style: const TextStyle(color: Colors.grey),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTripFooter() {
    return Row(
      children: [
        const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
        const SizedBox(width: 4),
        Text(
          '${trip.date.day}/${trip.date.month}/${trip.date.year}',
          style: const TextStyle(color: Colors.grey),
        ),
        const Spacer(),
        const Icon(Icons.photo_camera, color: Colors.grey, size: 16),
        const SizedBox(width: 4),
        Text(
          '${trip.photos.length} fotos',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

/// Widget compacto para exibir viagem em lista
class TripListTile extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TripListTile({
    super.key,
    required this.trip,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: trip.imagePath.startsWith('assets')
              ? AssetImage(trip.imagePath)
              : NetworkImage(trip.imagePath) as ImageProvider,
        ),
        title: Text(trip.title),
        subtitle: Text(trip.destination),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${trip.date.day}/${trip.date.month}'),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit' && onEdit != null) {
                    onEdit!();
                  } else if (value == 'delete' && onDelete != null) {
                    onDelete!();
                  }
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir'),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Widget para exibir estatísticas de viagem
class TripStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const TripStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
