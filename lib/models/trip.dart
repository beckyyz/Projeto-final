class Trip {
  final String id;
  final String title;
  final String destination;
  final DateTime date;
  final String description;
  final String imagePath;
  final List<String> photos; // Lista de caminhos das fotos adicionais

  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.date,
    required this.description,
    required this.imagePath,
    this.photos = const [], // Lista vazia por padrão
  });

  // Converter para Map (para armazenamento)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'imagePath': imagePath,
      'photos': photos,
    };
  }

  // Criar a partir de Map
  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      destination: map['destination'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      description: map['description'] ?? '',
      imagePath: map['imagePath'] ?? '',
      photos: List<String>.from(map['photos'] ?? []),
    );
  }

  // Copiar com modificações
  Trip copyWith({
    String? id,
    String? title,
    String? destination,
    DateTime? date,
    String? description,
    String? imagePath,
    List<String>? photos,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      date: date ?? this.date,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      photos: photos ?? this.photos,
    );
  }

  // Converter para JSON string
  String toJson() => toMap().toString();

  @override
  String toString() {
    return 'Trip(id: $id, title: $title, destination: $destination, date: $date, description: $description, imagePath: $imagePath, photos: $photos)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Trip && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
