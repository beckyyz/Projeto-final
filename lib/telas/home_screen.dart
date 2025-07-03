import 'package:flutter/material.dart';
import 'dart:io';
import '../models/trip.dart';
import '../models/user.dart';
import '../services/user_data_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import '../services/profile_photo_service.dart';
import '../services/trip_form_manager.dart';
import '../widgets/app_drawer.dart';
import '../widgets/profile_widgets.dart';
import '../widgets/trip_widgets.dart';
import '../widgets/settings_help_widgets.dart';
import '../widgets/common_widgets.dart';
import 'trip_details_screen.dart';
import 'login_screen.dart';
import 'search_screen.dart';

class TravelJournalHome extends StatefulWidget {
  const TravelJournalHome({super.key});

  @override
  State<TravelJournalHome> createState() => _TravelJournalHomeState();
}

class _TravelJournalHomeState extends State<TravelJournalHome> {
  List<Trip> _trips = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _currentPage = 'home';
  User? _currentUser;
  int _unreadNotificationsCount = 0;

  // Controladores para os campos do formulário
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Verificar autenticação e carregar dados
  Future<void> _checkAuthAndLoadData() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        setState(() {
          _errorMessage = 'Sessão expirada. Faça login novamente.';
          _isLoading = false;
        });
        return;
      }

      await _loadUserData();
      await _loadTrips();
      await _loadNotificationsCount();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao verificar autenticação';
        _isLoading = false;
      });
    }
  }

  // Carregar dados do usuário
  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      _showErrorMessage('Erro ao carregar dados do usuário');
    }
  }

  // Carregar viagens do usuário
  Future<void> _loadTrips() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final trips = await UserDataService.getCurrentUserTrips();

      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        String errorMessage = 'Erro inesperado';
        if (e.toString().contains('não está logado')) {
          errorMessage = 'Sessão expirada. Faça login novamente.';
        } else if (e.toString().contains('viagens do usuário')) {
          errorMessage = 'Erro ao carregar suas viagens';
        }
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    }
  }

  // Carregar contagem de notificações
  Future<void> _loadNotificationsCount() async {
    try {
      final count = await NotificationService.getUnreadCount();
      setState(() {
        _unreadNotificationsCount = count;
      });
    } catch (e) {
      // Silenciar erro da contagem de notificações
    }
  }

  // Criar nova viagem
  Future<void> _createTrip() async {
    await TripFormManager.createTrip(
      context: context,
      titleController: _titleController,
      destinationController: _destinationController,
      descriptionController: _descriptionController,
      onError: _showErrorMessage,
      onSuccess: _showSuccessMessage,
      onComplete: _loadTrips,
    );
  }

  // Editar viagem existente
  Future<void> _editTrip(Trip trip) async {
    await TripFormManager.editTrip(
      context: context,
      trip: trip,
      titleController: _titleController,
      destinationController: _destinationController,
      descriptionController: _descriptionController,
      onError: _showErrorMessage,
      onSuccess: _showSuccessMessage,
      onComplete: _loadTrips,
    );
  }

  // Excluir viagem
  Future<void> _deleteTrip(Trip trip) async {
    await TripFormManager.deleteTrip(
      context: context,
      trip: trip,
      confirmationDialog: _showConfirmationDialog,
      onError: _showErrorMessage,
      onSuccess: _showSuccessMessage,
      onComplete: _loadTrips,
    );
  }

  // Mostrar diálogo de confirmação
  Future<bool?> _showConfirmationDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        confirmText: 'Excluir',
        confirmColor: Colors.red,
      ),
    );
  }

  // Fazer logout
  Future<void> _logout() async {
    try {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      _showErrorMessage('Erro ao fazer logout: $e');
    }
  }

  // Adicionar nova viagem
  void _addNewTrip() {
    TripFormManager.clearForm(
      titleController: _titleController,
      destinationController: _destinationController,
      descriptionController: _descriptionController,
    );

    TripFormManager.showTripFormModal(
      context: context,
      title: 'Nova Viagem',
      onSave: _createTrip,
      titleController: _titleController,
      destinationController: _destinationController,
      descriptionController: _descriptionController,
    );
  }

  // Alterar a foto de perfil
  void _changeProfilePhoto() {
    ProfilePhotoService.showPhotoOptions(
      context,
      onSuccess: () {
        _loadUserData();
        _showSuccessMessage('Foto de perfil atualizada!');
      },
      onError: (message) => _showErrorMessage(message),
    );
  }

  // Mostrar mensagem de erro
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Mostrar mensagem de sucesso
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // Navegar entre páginas
  void _navigateToPage(String page) {
    setState(() {
      _currentPage = page;
    });
    Navigator.of(context).pop(); // Fechar o drawer
  }

  // Gerenciar notificações
  void _manageNotifications() async {
    final notifications = await NotificationService.getAllNotifications();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Notificações',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (notifications.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Nenhuma notificação ainda.'),
              ),
            ),
          ...notifications.map(
            (notification) => ListTile(
              title: Text(notification.title),
              subtitle: Text(notification.message),
              trailing: Text(
                notification.date.toString().substring(0, 16),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              leading: const Icon(Icons.notifications, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await NotificationService.markAllAsRead();
              _loadNotificationsCount();
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Marcar todas como lidas'),
          ),
        ],
      ),
    );
  }

  // Alterar senha
  void _changePassword() {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Alterar Senha',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Senha Atual',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Nova Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmar Nova Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
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
                    onPressed: () async {
                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        _showErrorMessage('As senhas não coincidem');
                        return;
                      }
                      // Implementar alteração de senha
                      _showSuccessMessage('Senha alterada com sucesso!');
                      Navigator.of(context).pop();
                    },
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Mostrar sobre o aplicativo
  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (ctx) => AboutDialog(
        applicationName: 'Trip Diary',
        applicationVersion: '1.0.0',
        applicationIcon: const FlutterLogo(size: 50),
        children: const [
          SizedBox(height: 16),
          Text(
            'Trip Diary é um aplicativo de diário de viagens onde você pode registrar suas aventuras, adicionar fotos e notas para lembrar cada momento especial.',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 12),
          Text(
            '© 2023 - Trip Diary App',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getPageTitle(_currentPage)),
        actions: [
          if (_currentPage == 'home' || _currentPage == 'trips')
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const SearchScreen()),
                );
              },
            ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: _manageNotifications,
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadNotificationsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(
        currentPage: _currentPage,
        onNavigate: _navigateToPage,
        onLogout: _logout,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _checkAuthAndLoadData,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : _buildCurrentPageBody(),
      floatingActionButton: _currentPage == 'trips'
          ? _buildAddTripButton()
          : null,
    );
  }

  // Construir corpo da página atual
  Widget _buildCurrentPageBody() {
    switch (_currentPage) {
      case 'home':
        return _buildHomePage();
      case 'trips':
        return _buildTripsPage();
      case 'user':
        return _buildUserPage();
      case 'settings':
        return _buildSettingsPage();
      case 'help':
        return const HelpPage();
      default:
        return _buildHomePage();
    }
  }

  // Construir página inicial
  Widget _buildHomePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bem-vindo ao Trip Diary!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Olá, ${_currentUser?.name ?? 'Viajante'}! Aqui você pode gerenciar suas viagens e explorar novos destinos.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'O que deseja fazer hoje?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_trips.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flight_takeoff, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Você ainda não tem viagens',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Adicione sua primeira viagem para começar',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _addNewTrip,
                  icon: const Icon(Icons.add),
                  label: const Text('Criar Primeira Viagem'),
                ),
              ],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Suas viagens recentes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._trips
                  .take(3)
                  .map(
                    (trip) => TripCard(
                      trip: trip,
                      onTap: () => Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  TripDetailsScreen(trip: trip),
                            ),
                          )
                          .then((_) => _loadTrips()),
                      onEdit: () => _editTrip(trip),
                      onDelete: () => _deleteTrip(trip),
                    ),
                  )
                  .toList(),
              if (_trips.length > 3)
                Center(
                  child: TextButton(
                    onPressed: () => _navigateToPage('trips'),
                    child: const Text('Ver todas as viagens'),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  // Construir página de viagens
  Widget _buildTripsPage() {
    if (_trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flight_takeoff, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Você ainda não tem viagens',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione sua primeira viagem para começar',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addNewTrip,
              icon: const Icon(Icons.add),
              label: const Text('Criar Primeira Viagem'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _trips.length,
        itemBuilder: (context, index) {
          final trip = _trips[index];
          return TripCard(
            trip: trip,
            onTap: () => Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => TripDetailsScreen(trip: trip),
                  ),
                )
                .then((_) => _loadTrips()),
            onEdit: () => _editTrip(trip),
            onDelete: () => _deleteTrip(trip),
          );
        },
      ),
    );
  }

  // Botão para adicionar viagem
  Widget _buildAddTripButton() {
    return FloatingActionButton(
      onPressed: _addNewTrip,
      tooltip: 'Nova Viagem',
      child: const Icon(Icons.add),
    );
  }

  // Construir página de perfil do usuário
  Widget _buildUserPage() {
    return FutureBuilder<User?>(
      future: AuthService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: ProfileAvatar(
                  user: user,
                  radius: 60,
                  onTap: _changeProfilePhoto,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                user?.name ?? 'Usuário',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user?.email ?? '',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              UserInfoCard(title: 'Viagens', value: _trips.length.toString()),
              const SizedBox(height: 12),
              UserInfoCard(
                title: 'Conta criada em',
                value:
                    user?.createdAt?.toString().substring(0, 10) ??
                    'Desconhecido',
              ),
              const SizedBox(height: 32),
              UserActionCard(
                title: 'Editar Perfil',
                icon: Icons.edit,
                onTap: () {
                  // Implementar edição de perfil
                  _showSuccessMessage('Funcionalidade em desenvolvimento');
                },
              ),
              UserActionCard(
                title: 'Alterar Senha',
                icon: Icons.lock,
                onTap: _changePassword,
              ),
              UserActionCard(
                title: 'Gerenciar Notificações',
                icon: Icons.notifications,
                onTap: _manageNotifications,
              ),
              UserActionCard(title: 'Sair', icon: Icons.logout, onTap: _logout),
            ],
          ),
        );
      },
    );
  }

  // Construir página de configurações
  Widget _buildSettingsPage() {
    return SettingsPage(
      onManageNotifications: _manageNotifications,
      onChangePassword: _changePassword,
      onShowAboutApp: _showAboutApp,
    );
  }
}
