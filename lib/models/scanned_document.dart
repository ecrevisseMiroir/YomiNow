class ScannedDocument {
  const ScannedDocument({
    required this.id,
    required this.title,
    required this.path,
    required this.createdAt,
    this.hasText = false,
  });

  final String id;
  final String title;
  final String path;
  final DateTime createdAt;
  final bool hasText;

  ScannedDocument copyWith({bool? hasText}) => ScannedDocument(
    id: id,
    title: title,
    path: path,
    createdAt: createdAt,
    hasText: hasText ?? this.hasText,
  );
}
