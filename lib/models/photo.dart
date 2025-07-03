class Photo {
  final String id;
  final String tripId;
  final String path;
  final String? caption;
  final DateTime takenAt;
  final DateTime uploadedAt;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final int? fileSize;
  final Map<String, dynamic>? metadata;

  Photo({
    required this.id,
    required this.tripId,
    required this.path,
    this.caption,
    required this.takenAt,
    required this.uploadedAt,
    this.latitude,
    this.longitude,
    this.locationName,
    this.fileSize,
    this.metadata,
  });

  // Converter para Map (para armazenamento)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'path': path,
      'caption': caption,
      'takenAt': takenAt.millisecondsSinceEpoch,
      'uploadedAt': uploadedAt.millisecondsSinceEpoch,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'fileSize': fileSize,
      'metadata': metadata,
    };
  }

  // Criar a partir de Map
  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'] ?? '',
      tripId: map['tripId'] ?? '',
      path: map['path'] ?? '',
      caption: map['caption'],
      takenAt: DateTime.fromMillisecondsSinceEpoch(map['takenAt'] ?? 0),
      uploadedAt: DateTime.fromMillisecondsSinceEpoch(map['uploadedAt'] ?? 0),
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      locationName: map['locationName'],
      fileSize: map['fileSize'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  // Copiar com modificações
  Photo copyWith({
    String? id,
    String? tripId,
    String? path,
    String? caption,
    DateTime? takenAt,
    DateTime? uploadedAt,
    double? latitude,
    double? longitude,
    String? locationName,
    int? fileSize,
    Map<String, dynamic>? metadata,
  }) {
    return Photo(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      path: path ?? this.path,
      caption: caption ?? this.caption,
      takenAt: takenAt ?? this.takenAt,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      fileSize: fileSize ?? this.fileSize,
      metadata: metadata ?? this.metadata,
    );
  }

  // Verificar se tem localização
  bool get hasLocation => latitude != null && longitude != null;

  // Obter nome do arquivo
  String get fileName => path.split('/').last;

  // Obter extensão do arquivo
  String get fileExtension => fileName.split('.').last.toLowerCase();

  // Verificar se é uma imagem válida
  bool get isValidImage {
    const validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return validExtensions.contains(fileExtension);
  }

  @override
  String toString() {
    return 'Photo(id: $id, tripId: $tripId, path: $path, caption: $caption, takenAt: $takenAt, uploadedAt: $uploadedAt, latitude: $latitude, longitude: $longitude, locationName: $locationName, fileSize: $fileSize)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Photo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
