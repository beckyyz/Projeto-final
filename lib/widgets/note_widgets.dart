import 'package:flutter/material.dart';
import '../models/note.dart';

/// Widget para exibir cartão de anotação
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNoteHeader(context),
              const SizedBox(height: 8),
              _buildNoteContent(),
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildNoteTags(),
              ],
              const SizedBox(height: 8),
              _buildNoteFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            note.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildNoteContent() {
    return Text(
      note.content,
      style: const TextStyle(fontSize: 14),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildNoteTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: note.tags
          .map(
            (tag) => Chip(
              label: Text(tag, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.blue.withOpacity(0.1),
              labelStyle: const TextStyle(color: Colors.blue),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          )
          .toList(),
    );
  }

  Widget _buildNoteFooter() {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          _formatDate(note.updatedAt),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const Spacer(),
        if (note.imagePath != null)
          const Icon(Icons.image, size: 14, color: Colors.grey),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min atrás';
    } else {
      return 'Agora';
    }
  }
}

/// Widget compacto para lista de anotações
class NoteListTile extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const NoteListTile({
    super.key,
    required this.note,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.note, color: Colors.white),
        ),
        title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (note.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  note.tags.join(', '),
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${note.updatedAt.day}/${note.updatedAt.month}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
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
        isThreeLine: note.tags.isNotEmpty,
      ),
    );
  }
}

/// Widget para adicionar/editar tags
class TagEditor extends StatefulWidget {
  final List<String> initialTags;
  final Function(List<String>) onTagsChanged;
  final String hint;

  const TagEditor({
    super.key,
    required this.initialTags,
    required this.onTagsChanged,
    this.hint = 'Adicionar tag',
  });

  @override
  State<TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  final TextEditingController _tagController = TextEditingController();
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
      widget.onTagsChanged(_tags);
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  labelText: widget.hint,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addTag,
                  ),
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          const Text('Tags:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _tags
                .map(
                  (tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.blue),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

/// Widget para exibir estatísticas de anotações
class NoteStatsWidget extends StatelessWidget {
  final int totalNotes;
  final int notesThisMonth;
  final List<String> topTags;

  const NoteStatsWidget({
    super.key,
    required this.totalNotes,
    required this.notesThisMonth,
    required this.topTags,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.note, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Estatísticas de Anotações',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    totalNotes.toString(),
                    Icons.note_alt,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Este mês',
                    notesThisMonth.toString(),
                    Icons.calendar_today,
                    Colors.green,
                  ),
                ),
              ],
            ),
            if (topTags.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Tags mais usadas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: topTags
                    .take(5)
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        labelStyle: const TextStyle(color: Colors.orange),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
