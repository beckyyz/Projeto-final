import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../models/note.dart';
import '../models/photo.dart';
import '../services/user_data_service.dart';
import 'photo_view_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Note> _notes = [];
  List<Photo> _photos = [];
  bool _isLoading = true;

  // Controladores para anotações
  final TextEditingController _noteTitle = TextEditingController();
  final TextEditingController _noteContent = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTripData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteTitle.dispose();
    _noteContent.dispose();
    _tagController.dispose();
    super.dispose();
  }

  // Carregar dados da viagem
  Future<void> _loadTripData() async {
    setState(() => _isLoading = true);
    
    try {
      final notes = await UserDataService.getCurrentUserTripNotes(widget.trip.id);
      final photos = await UserDataService.getCurrentUserTripPhotos(widget.trip.id);
      
      setState(() {
        _notes = notes;
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage('Erro ao carregar dados: $e');
    }
  }

  // ==================== MÉTODOS PARA ANOTAÇÕES ====================

  // Criar nova anotação
  Future<void> _createNote() async {
    if (_noteTitle.text.trim().isEmpty || _noteContent.text.trim().isEmpty) {
      _showErrorMessage('Por favor, preencha título e conteúdo');
      return;
    }

    try {
      await UserDataService.createNoteForCurrentUser(
        tripId: widget.trip.id,
        title: _noteTitle.text.trim(),
        content: _noteContent.text.trim(),
        tags: _selectedTags,
      );

      _showSuccessMessage('Anotação criada com sucesso!');
      Navigator.of(context).pop();
      _loadTripData();
    } catch (e) {
      _showErrorMessage('Erro ao criar anotação: $e');
    }
  }

  // Editar anotação
  Future<void> _editNote(Note note) async {
    _noteTitle.text = note.title;
    _noteContent.text = note.content;
    _selectedTags = List.from(note.tags);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _buildNoteFormModal(
        title: 'Editar Anotação',
        onSave: () async {
          try {
            final updatedNote = note.copyWith(
              title: _noteTitle.text.trim(),
              content: _noteContent.text.trim(),
              tags: _selectedTags,
              updatedAt: DateTime.now(),
            );

            await UserDataService.updateCurrentUserNote(updatedNote);
            _showSuccessMessage('Anotação atualizada com sucesso!');
            Navigator.of(context).pop();
            _loadTripData();
          } catch (e) {
            _showErrorMessage('Erro ao atualizar anotação: $e');
          }
        },
      ),
    );
  }

  // Deletar anotação
  Future<void> _deleteNote(Note note) async {
    final confirmed = await _showConfirmationDialog(
      'Deletar Anotação',
      'Tem certeza que deseja deletar "${note.title}"?',
    );

    if (confirmed) {
      try {
        await UserDataService.deleteCurrentUserNote(note.id);
        _showSuccessMessage('Anotação deletada com sucesso!');
        _loadTripData();
      } catch (e) {
        _showErrorMessage('Erro ao deletar anotação: $e');
      }
    }
  }

  // Adicionar nova anotação
  void _addNewNote() {
    _noteTitle.clear();
    _noteContent.clear();
    _selectedTags.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _buildNoteFormModal(
        title: 'Nova Anotação',
        onSave: _createNote,
      ),
    );
  }

  // ==================== MÉTODOS PARA FOTOS ====================

  // Criar nova foto (placeholder - seria integrado com ImagePicker)
  Future<void> _addPhoto() async {
    try {
      // Simular adição de foto
      await UserDataService.createPhotoForCurrentUser(
        tripId: widget.trip.id,
        path: '/storage/photos/photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        caption: 'Nova foto da viagem',
        takenAt: DateTime.now(),
      );

      _showSuccessMessage('Foto adicionada com sucesso!');
      _loadTripData();
    } catch (e) {
      _showErrorMessage('Erro ao adicionar foto: $e');
    }
  }

  // Editar legenda da foto
  Future<void> _editPhotoCaption(Photo photo) async {
    final controller = TextEditingController(text: photo.caption ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Legenda'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Legenda da foto',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final updatedPhoto = photo.copyWith(caption: controller.text.trim());
                await UserDataService.updateCurrentUserPhoto(updatedPhoto);
                _showSuccessMessage('Legenda atualizada!');
                Navigator.of(context).pop();
                _loadTripData();
              } catch (e) {
                _showErrorMessage('Erro ao atualizar legenda: $e');
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // Deletar foto
  Future<void> _deletePhoto(Photo photo) async {
    final confirmed = await _showConfirmationDialog(
      'Deletar Foto',
      'Tem certeza que deseja deletar esta foto?',
    );

    if (confirmed) {
      try {
        await UserDataService.deleteCurrentUserPhoto(photo.id);
        _showSuccessMessage('Foto deletada com sucesso!');
        _loadTripData();
      } catch (e) {
        _showErrorMessage('Erro ao deletar foto: $e');
      }
    }
  }

  // ==================== MÉTODOS AUXILIARES ====================

  // Mostrar dialog de confirmação
  Future<bool> _showConfirmationDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    ) ?? false;
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

  // ==================== WIDGETS ====================

  Widget _buildNoteFormModal({
    required String title,
    required VoidCallback onSave,
  }) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _noteTitle,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _noteContent,
                  decoration: const InputDecoration(
                    labelText: 'Conteúdo',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 10),
                
                // Tags
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        decoration: const InputDecoration(
                          labelText: 'Nova tag',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_tagController.text.trim().isNotEmpty) {
                          setModalState(() {
                            _selectedTags.add(_tagController.text.trim());
                            _tagController.clear();
                          });
                        }
                      },
                      child: const Text('Adicionar'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Tags selecionadas
                if (_selectedTags.isNotEmpty) ...[
                  const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    children: _selectedTags.map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () {
                        setModalState(() {
                          _selectedTags.remove(tag);
                        });
                      },
                    )).toList(),
                  ),
                ],
                
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Salvar'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f4f8),
      body: CustomScrollView(
        slivers: [
          // App Bar com imagem
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.trip.title),
              background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: widget.trip.imagePath.startsWith('assets')
                        ? AssetImage(widget.trip.imagePath)
                        : NetworkImage(widget.trip.imagePath) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Conteúdo principal
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Informações da viagem
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            widget.trip.destination,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.trip.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.trip.date.day}/${widget.trip.date.month}/${widget.trip.date.year}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Tabs
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.note),
                            const SizedBox(width: 8),
                            Text('Anotações (${_notes.length})'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.photo),
                            const SizedBox(width: 8),
                            Text('Fotos (${_photos.length})'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Conteúdo das tabs
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNotesTab(),
                      _buildPhotosTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _addNewNote();
          } else {
            _addPhoto();
          }
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: Icon(_tabController.index == 0 ? Icons.note_add : Icons.add_a_photo),
      ),
    );
  }

  Widget _buildNotesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_add, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhuma anotação ainda'),
            Text('Adicione suas memórias desta viagem!'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(note.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (note.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: note.tags.map((tag) => Chip(
                      label: Text(tag),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editNote(note);
                } else if (value == 'delete') {
                  _deleteNote(note);
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
          ),
        );
      },
    );
  }

  Widget _buildPhotosTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_photos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhuma foto ainda'),
            Text('Capture momentos especiais desta viagem!'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoViewScreen(photoPath: photo.path),
              ),
            );
          },
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Editar legenda'),
                    onTap: () {
                      Navigator.pop(context);
                      _editPhotoCaption(photo);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Excluir foto'),
                    onTap: () {
                      Navigator.pop(context);
                      _deletePhoto(photo);
                    },
                  ),
                ],
              ),
            );
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                    ),
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
}
