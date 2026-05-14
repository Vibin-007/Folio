class Bookmark {
  final int pageNumber;
  String label;
  final DateTime createdAt;

  Bookmark({
    required this.pageNumber,
    this.label = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'pageNumber': pageNumber,
        'label': label,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        pageNumber: json['pageNumber'] as int,
        label: json['label'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
