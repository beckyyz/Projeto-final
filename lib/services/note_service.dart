import '../models/note.dart';
import 'storage_service.dart';

class NoteService {
  static const String _notesKey = 'notes';

  // CREATE - Criar nova anotação
  static Future<String> createNote({
    required String tripId,
    required String title,
    required String content,
    List<String>? tags,
    String? imagePath,
  }) async {
    try {
      final noteId = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();

      final note = Note(
        id: noteId,
        tripId: tripId,
        title: title,
        content: content,
        createdAt: now,
        updatedAt: now,
        tags: tags ?? [],
        imagePath: imagePath,
      );

      final notes = await getAllNotes();
      notes.add(note);
      await _saveNotes(notes);

      return noteId;
    } catch (e) {
      throw Exception('Erro ao criar anotação: $e');
    }
  }

  // READ - Obter todas as anotações
  static Future<List<Note>> getAllNotes() async {
    try {
      final List<Map<String, dynamic>> notesData = await StorageService.getList(
        _notesKey,
      );

      return notesData.map((data) => Note.fromMap(data)).toList();
    } catch (e) {
      return [];
    }
  }

  // READ - Obter anotação por ID
  static Future<Note?> getNoteById(String noteId) async {
    try {
      final notes = await getAllNotes();
      return notes.firstWhere(
        (note) => note.id == noteId,
        orElse: () => throw Exception('Anotação não encontrada'),
      );
    } catch (e) {
      return null;
    }
  }

  // READ - Obter anotações por viagem
  static Future<List<Note>> getNotesByTripId(String tripId) async {
    try {
      final notes = await getAllNotes();
      return notes.where((note) => note.tripId == tripId).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      throw Exception('Erro ao obter anotações da viagem: $e');
    }
  }

  // READ - Obter anotações recentes
  static Future<List<Note>> getRecentNotes({int limit = 10}) async {
    try {
      final notes = await getAllNotes();
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return notes.take(limit).toList();
    } catch (e) {
      throw Exception('Erro ao obter anotações recentes: $e');
    }
  }

  // READ - Buscar anotações por texto
  static Future<List<Note>> searchNotes(String query) async {
    try {
      final notes = await getAllNotes();
      final lowercaseQuery = query.toLowerCase();

      return notes
          .where(
            (note) =>
                note.title.toLowerCase().contains(lowercaseQuery) ||
                note.content.toLowerCase().contains(lowercaseQuery) ||
                note.tags.any(
                  (tag) => tag.toLowerCase().contains(lowercaseQuery),
                ),
          )
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      throw Exception('Erro na busca: $e');
    }
  }

  // READ - Obter anotações por tag
  static Future<List<Note>> getNotesByTag(String tag) async {
    try {
      final notes = await getAllNotes();
      return notes
          .where(
            (note) =>
                note.tags.any((t) => t.toLowerCase() == tag.toLowerCase()),
          )
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      throw Exception('Erro ao obter anotações por tag: $e');
    }
  }

  // UPDATE - Atualizar anotação
  static Future<void> updateNote(Note updatedNote) async {
    try {
      final notes = await getAllNotes();
      final index = notes.indexWhere((note) => note.id == updatedNote.id);

      if (index != -1) {
        notes[index] = updatedNote.updateTimestamp();
        await _saveNotes(notes);
      } else {
        throw Exception('Anotação não encontrada');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar anotação: $e');
    }
  }

  // UPDATE - Atualizar conteúdo da anotação
  static Future<void> updateNoteContent({
    required String noteId,
    String? title,
    String? content,
    List<String>? tags,
    String? imagePath,
  }) async {
    try {
      final note = await getNoteById(noteId);
      if (note == null) {
        throw Exception('Anotação não encontrada');
      }

      final updatedNote = note.copyWith(
        title: title,
        content: content,
        tags: tags,
        imagePath: imagePath,
        updatedAt: DateTime.now(),
      );

      await updateNote(updatedNote);
    } catch (e) {
      throw Exception('Erro ao atualizar conteúdo da anotação: $e');
    }
  }

  // UPDATE - Adicionar tag à anotação
  static Future<void> addTagToNote(String noteId, String tag) async {
    try {
      final note = await getNoteById(noteId);
      if (note == null) {
        throw Exception('Anotação não encontrada');
      }

      if (!note.tags.contains(tag)) {
        final updatedTags = List<String>.from(note.tags)..add(tag);
        final updatedNote = note.copyWith(tags: updatedTags);
        await updateNote(updatedNote);
      }
    } catch (e) {
      throw Exception('Erro ao adicionar tag: $e');
    }
  }

  // UPDATE - Remover tag da anotação
  static Future<void> removeTagFromNote(String noteId, String tag) async {
    try {
      final note = await getNoteById(noteId);
      if (note == null) {
        throw Exception('Anotação não encontrada');
      }

      final updatedTags = List<String>.from(note.tags)..remove(tag);
      final updatedNote = note.copyWith(tags: updatedTags);
      await updateNote(updatedNote);
    } catch (e) {
      throw Exception('Erro ao remover tag: $e');
    }
  }

  // DELETE - Deletar anotação
  static Future<void> deleteNote(String noteId) async {
    try {
      final notes = await getAllNotes();
      notes.removeWhere((note) => note.id == noteId);
      await _saveNotes(notes);
    } catch (e) {
      throw Exception('Erro ao deletar anotação: $e');
    }
  }

  // DELETE - Deletar todas as anotações de uma viagem
  static Future<void> deleteNotesByTripId(String tripId) async {
    try {
      final notes = await getAllNotes();
      notes.removeWhere((note) => note.tripId == tripId);
      await _saveNotes(notes);
    } catch (e) {
      throw Exception('Erro ao deletar anotações da viagem: $e');
    }
  }

  // ESTATÍSTICAS - Obter estatísticas das anotações
  static Future<Map<String, dynamic>> getNotesStats() async {
    try {
      final notes = await getAllNotes();
      final tags = <String>{};

      for (final note in notes) {
        tags.addAll(note.tags);
      }

      return {
        'totalNotes': notes.length,
        'totalTags': tags.length,
        'notesThisMonth': notes.where((note) {
          final now = DateTime.now();
          return note.createdAt.year == now.year &&
              note.createdAt.month == now.month;
        }).length,
        'mostUsedTags': _getMostUsedTags(notes, limit: 5),
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }

  // UTILITÁRIO - Obter todas as tags únicas
  static Future<List<String>> getAllTags() async {
    try {
      final notes = await getAllNotes();
      final tags = <String>{};

      for (final note in notes) {
        tags.addAll(note.tags);
      }

      return tags.toList()..sort();
    } catch (e) {
      throw Exception('Erro ao obter tags: $e');
    }
  }

  // UTILITÁRIO - Duplicar anotação
  static Future<String> duplicateNote(String noteId) async {
    try {
      final note = await getNoteById(noteId);
      if (note == null) {
        throw Exception('Anotação não encontrada');
      }

      return await createNote(
        tripId: note.tripId,
        title: '${note.title} (Cópia)',
        content: note.content,
        tags: note.tags,
        imagePath: note.imagePath,
      );
    } catch (e) {
      throw Exception('Erro ao duplicar anotação: $e');
    }
  }

  // PRIVADOS - Salvar lista de anotações
  static Future<void> _saveNotes(List<Note> notes) async {
    final notesData = notes.map((note) => note.toMap()).toList();
    await StorageService.saveList(_notesKey, notesData);
  }

  // PRIVADOS - Obter tags mais usadas
  static List<Map<String, dynamic>> _getMostUsedTags(
    List<Note> notes, {
    int limit = 5,
  }) {
    final tagCount = <String, int>{};

    for (final note in notes) {
      for (final tag in note.tags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }

    final sortedTags = tagCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTags
        .take(limit)
        .map((entry) => {'tag': entry.key, 'count': entry.value})
        .toList();
  }

  // UTILITÁRIO - Gerar ID único para anotação
  static String generateNoteId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
