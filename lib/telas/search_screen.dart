import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../models/note.dart';
import '../models/photo.dart';
import '../services/user_data_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/trip_widgets.dart';
import '../widgets/note_widgets.dart';
import 'trip_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Trip> _searchTrips = [];
  List<Note> _searchNotes = [];
  List<Photo> _searchPhotos = [];

  bool _isSearching = false;
  bool _hasSearched = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Realizar busca
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchTrips.clear();
        _searchNotes.clear();
        _searchPhotos.clear();
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _lastQuery = query;
    });

    try {
      final results = await _searchUserData(query);

      setState(() {
        _searchTrips = results['trips'] as List<Trip>;
        _searchNotes = results['notes'] as List<Note>;
        _searchPhotos = results['photos'] as List<Photo>;
        _isSearching = false;
        _hasSearched = true;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      CustomSnackBar.showError(context, 'Erro na busca: $e');
    }
  }

  // Buscar dados do usuário
  Future<Map<String, dynamic>> _searchUserData(String query) async {
    try {
      final trips = await UserDataService.getCurrentUserTrips();
      final notes = await UserDataService.getCurrentUserNotes();
      final photos = await UserDataService.getCurrentUserPhotos();

      final lowercaseQuery = query.toLowerCase();

      // Filtrar viagens
      final filteredTrips = trips
          .where(
            (trip) =>
                trip.title.toLowerCase().contains(lowercaseQuery) ||
                trip.destination.toLowerCase().contains(lowercaseQuery) ||
                trip.description.toLowerCase().contains(lowercaseQuery),
          )
          .toList();

      // Filtrar anotações
      final filteredNotes = notes
          .where(
            (note) =>
                note.title.toLowerCase().contains(lowercaseQuery) ||
                note.content.toLowerCase().contains(lowercaseQuery) ||
                note.tags.any(
                  (tag) => tag.toLowerCase().contains(lowercaseQuery),
                ),
          )
          .toList();

      // Filtrar fotos
      final filteredPhotos = photos
          .where(
            (photo) =>
                (photo.caption?.toLowerCase().contains(lowercaseQuery) ??
                    false) ||
                (photo.locationName?.toLowerCase().contains(lowercaseQuery) ??
                    false),
          )
          .toList();

      return {
        'trips': filteredTrips,
        'notes': filteredNotes,
        'photos': filteredPhotos,
      };
    } catch (e) {
      throw Exception('Erro na busca: $e');
    }
  }

  // Deletar viagem
  Future<void> _deleteTrip(Trip trip) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Deletar Viagem',
      content:
          'Tem certeza que deseja deletar "${trip.title}"?\n\nTodas as anotações e fotos desta viagem também serão removidas.',
    );

    if (confirmed) {
      try {
        await UserDataService.deleteCurrentUserTrip(trip.id);
        CustomSnackBar.showSuccess(context, 'Viagem deletada com sucesso!');
        _performSearch(_lastQuery); // Atualizar resultados
      } catch (e) {
        CustomSnackBar.showError(context, 'Erro ao deletar viagem: $e');
      }
    }
  }

  // Deletar anotação
  Future<void> _deleteNote(Note note) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Deletar Anotação',
      content: 'Tem certeza que deseja deletar "${note.title}"?',
    );

    if (confirmed) {
      try {
        await UserDataService.deleteCurrentUserNote(note.id);
        CustomSnackBar.showSuccess(context, 'Anotação deletada com sucesso!');
        _performSearch(_lastQuery); // Atualizar resultados
      } catch (e) {
        CustomSnackBar.showError(context, 'Erro ao deletar anotação: $e');
      }
    }
  }

  // Deletar foto
  Future<void> _deletePhoto(Photo photo) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Deletar Foto',
      content: 'Tem certeza que deseja deletar esta foto?',
    );

    if (confirmed) {
      try {
        await UserDataService.deleteCurrentUserPhoto(photo.id);
        CustomSnackBar.showSuccess(context, 'Foto deletada com sucesso!');
        _performSearch(_lastQuery); // Atualizar resultados
      } catch (e) {
        CustomSnackBar.showError(context, 'Erro ao deletar foto: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f4f8),
      appBar: AppBar(
        title: const Text('Buscar'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Campo de busca
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar viagens, anotações ou fotos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {});
                    if (value.trim().isNotEmpty) {
                      // Busca com delay para evitar muitas requisições
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_searchController.text == value) {
                          _performSearch(value);
                        }
                      });
                    } else {
                      _performSearch('');
                    }
                  },
                ),
              ),

              // Tabs
              if (_hasSearched)
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(text: 'Viagens (${_searchTrips.length})'),
                    Tab(text: 'Anotações (${_searchNotes.length})'),
                    Tab(text: 'Fotos (${_searchPhotos.length})'),
                  ],
                ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const LoadingWidget(message: 'Buscando...');
    }

    if (!_hasSearched) {
      return const EmptyStateWidget(
        title: 'Comece a buscar',
        subtitle:
            'Digite algo no campo acima para encontrar suas viagens, anotações e fotos',
        icon: Icons.search,
      );
    }

    if (_searchTrips.isEmpty && _searchNotes.isEmpty && _searchPhotos.isEmpty) {
      return EmptyStateWidget(
        title: 'Nenhum resultado encontrado',
        subtitle: 'Não encontramos nada relacionado a "$_lastQuery"',
        icon: Icons.search_off,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [_buildTripsTab(), _buildNotesTab(), _buildPhotosTab()],
    );
  }

  Widget _buildTripsTab() {
    if (_searchTrips.isEmpty) {
      return const EmptyStateWidget(
        title: 'Nenhuma viagem encontrada',
        subtitle: 'Tente buscar por outros termos',
        icon: Icons.flight_takeoff,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchTrips.length,
      itemBuilder: (context, index) {
        final trip = _searchTrips[index];
        return TripCard(
          trip: trip,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailsScreen(trip: trip),
              ),
            );
          },
          onDelete: () => _deleteTrip(trip),
        );
      },
    );
  }

  Widget _buildNotesTab() {
    if (_searchNotes.isEmpty) {
      return const EmptyStateWidget(
        title: 'Nenhuma anotação encontrada',
        subtitle: 'Tente buscar por outros termos',
        icon: Icons.note,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchNotes.length,
      itemBuilder: (context, index) {
        final note = _searchNotes[index];
        return NoteCard(
          note: note,
          onDelete: () => _deleteNote(note),
          onTap: () {
            // Mostrar detalhes da anotação
            _showNoteDetails(note);
          },
        );
      },
    );
  }

  Widget _buildPhotosTab() {
    if (_searchPhotos.isEmpty) {
      return const EmptyStateWidget(
        title: 'Nenhuma foto encontrada',
        subtitle: 'Tente buscar por outros termos',
        icon: Icons.photo,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _searchPhotos.length,
      itemBuilder: (context, index) {
        final photo = _searchPhotos[index];
        return GestureDetector(
          onLongPress: () => _deletePhoto(photo),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Colors.grey),
                    child: const Icon(
                      Icons.photo,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (photo.caption != null && photo.caption!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      photo.caption!,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNoteDetails(Note note) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(note.content),
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  children: note.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
