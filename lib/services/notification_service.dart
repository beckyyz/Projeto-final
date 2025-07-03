import 'dart:collection';

class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
  });

  Notification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? date,
    bool? isRead,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationService {
  static bool _notificationsEnabled = true;
  static bool _photoRemindersEnabled = false;
  static final List<Notification> _notifications = [];

  // Verificar se notificações estão habilitadas
  static bool get notificationsEnabled => _notificationsEnabled;
  static bool get photoRemindersEnabled => _photoRemindersEnabled;

  // Habilitar/desabilitar notificações
  static void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
  }

  static void setPhotoRemindersEnabled(bool enabled) {
    _photoRemindersEnabled = enabled;
  }

  // Obter contagem de notificações não lidas
  static Future<int> getUnreadCount() async {
    return _notifications.where((n) => !n.isRead).length;
  }

  // Obter todas as notificações
  static Future<List<Notification>> getAllNotifications() async {
    // Retorna uma cópia imutável da lista
    return UnmodifiableListView(_notifications);
  }

  // Marcar todas como lidas
  static Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  // Enviar notificação de viagem
  static void notifyTripChange(String tripTitle, String action) {
    if (!_notificationsEnabled) return;

    final notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '$action de Viagem',
      message: '$action realizada na viagem "$tripTitle"',
      date: DateTime.now(),
    );

    _notifications.insert(0, notification);

    // Limitar o número de notificações armazenadas (opcional)
    if (_notifications.length > 50) {
      _notifications.removeLast();
    }

    print('🔔 Trip Diary: ${notification.message}');
  }

  // Enviar notificação de foto
  static void notifyPhotoChange(String tripTitle, String action) {
    if (!_notificationsEnabled) return;

    final notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '$action de Foto',
      message: '$action realizada nas fotos da viagem "$tripTitle"',
      date: DateTime.now(),
    );

    _notifications.insert(0, notification);

    print('📸 Trip Diary: ${notification.message}');
  }

  // Lembrete para adicionar fotos
  static void remindAddPhotos(String tripTitle) {
    if (!_photoRemindersEnabled) return;

    final notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Lembrete de Fotos',
      message: 'Que tal adicionar algumas fotos à viagem "$tripTitle"?',
      date: DateTime.now(),
    );

    _notifications.insert(0, notification);

    print('📷 Trip Diary: ${notification.message}');
  }
}
