import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/notification_service.dart';
import '../services/user_data_service.dart';

/// Classe para gerenciar formulários de viagem e ações relacionadas
class TripFormManager {
  /// Cria um modal para formulário de viagem (criar/editar)
  static Widget buildTripFormModal({
    required BuildContext context,
    required String title,
    required VoidCallback onSave,
    required TextEditingController titleController,
    required TextEditingController destinationController,
    required TextEditingController descriptionController,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Título da Viagem',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: destinationController,
            decoration: const InputDecoration(
              labelText: 'Destino',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Mostra o modal para criar nova viagem
  static void showTripFormModal({
    required BuildContext context,
    required String title,
    required VoidCallback onSave,
    required TextEditingController titleController,
    required TextEditingController destinationController,
    required TextEditingController descriptionController,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => buildTripFormModal(
        context: context,
        title: title,
        onSave: onSave,
        titleController: titleController,
        destinationController: destinationController,
        descriptionController: descriptionController,
      ),
    );
  }

  /// Cria uma nova viagem
  static Future<void> createTrip({
    required BuildContext context,
    required TextEditingController titleController,
    required TextEditingController destinationController,
    required TextEditingController descriptionController,
    required Function(String) onError,
    required Function(String) onSuccess,
    required VoidCallback onComplete,
  }) async {
    if (titleController.text.trim().isEmpty ||
        destinationController.text.trim().isEmpty) {
      onError('Por favor, preencha o título e destino');
      return;
    }

    try {
      await UserDataService.createTripForCurrentUser(
        title: titleController.text.trim(),
        destination: destinationController.text.trim(),
        description: descriptionController.text.trim(),
        date: DateTime.now(),
      );

      // Notificar sobre criação de viagem
      NotificationService.notifyTripChange(
        titleController.text.trim(),
        'Criação',
      );

      onSuccess('Viagem criada com sucesso!');
      Navigator.of(context).pop();
      clearForm(
        titleController: titleController,
        destinationController: destinationController,
        descriptionController: descriptionController,
      );
      onComplete();
    } catch (e) {
      onError('Erro ao criar viagem: $e');
    }
  }

  /// Edita uma viagem existente
  static Future<void> editTrip({
    required BuildContext context,
    required Trip trip,
    required TextEditingController titleController,
    required TextEditingController destinationController,
    required TextEditingController descriptionController,
    required Function(String) onError,
    required Function(String) onSuccess,
    required VoidCallback onComplete,
  }) async {
    titleController.text = trip.title;
    destinationController.text = trip.destination;
    descriptionController.text = trip.description;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => buildTripFormModal(
        context: context,
        title: 'Editar Viagem',
        onSave: () async {
          try {
            final updatedTrip = trip.copyWith(
              title: titleController.text.trim(),
              destination: destinationController.text.trim(),
              description: descriptionController.text.trim(),
            );

            await UserDataService.updateCurrentUserTrip(updatedTrip);

            // Notificar sobre edição de viagem
            NotificationService.notifyTripChange(trip.title, 'Edição');

            onSuccess('Viagem atualizada com sucesso!');
            Navigator.of(context).pop();
            clearForm(
              titleController: titleController,
              destinationController: destinationController,
              descriptionController: descriptionController,
            );
            onComplete();
          } catch (e) {
            onError('Erro ao atualizar viagem: $e');
          }
        },
        titleController: titleController,
        destinationController: destinationController,
        descriptionController: descriptionController,
      ),
    );
  }

  /// Excluir uma viagem
  static Future<void> deleteTrip({
    required BuildContext context,
    required Trip trip,
    required Function(String, String) confirmationDialog,
    required Function(String) onError,
    required Function(String) onSuccess,
    required VoidCallback onComplete,
  }) async {
    final confirmed = await confirmationDialog(
      'Excluir Viagem',
      'Tem certeza que deseja excluir "${trip.title}"? Esta ação não pode ser desfeita.',
    );

    if (confirmed == true) {
      try {
        await UserDataService.deleteCurrentUserTrip(trip.id);

        // Notificar sobre exclusão de viagem
        NotificationService.notifyTripChange(trip.title, 'Exclusão');

        onSuccess('Viagem excluída com sucesso!');
        onComplete();
      } catch (e) {
        onError('Erro ao excluir viagem: $e');
      }
    }
  }

  /// Limpa os campos do formulário
  static void clearForm({
    required TextEditingController titleController,
    required TextEditingController destinationController,
    required TextEditingController descriptionController,
  }) {
    titleController.clear();
    destinationController.clear();
    descriptionController.clear();
  }
}
