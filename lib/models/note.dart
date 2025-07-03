class Note {
  final String id;
  final String tripId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String? imagePath;

  Note({
    required this.id,
    required this.tripId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.imagePath,
  });

  // Converter para Map (para armazenamento)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'tags': tags,
      'imagePath': imagePath,
    };
  }

  // Criar a partir de Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      tripId: map['tripId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      tags: List<String>.from(map['tags'] ?? []),
      imagePath: map['imagePath'],
    );
  }

  // Copiar com modificações
  Note copyWith({
    String? id,
    String? tripId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? imagePath,
  }) {
    return Note(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  // Atualizar timestamp de modificação
  Note updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  @override
  String toString() {
    return 'Note(id: $id, tripId: $tripId, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, tags: $tags, imagePath: $imagePath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
