class RecentFile {
  final String path;
  final String name;
  final DateTime lastOpened;
  final int lastPage;

  RecentFile({
    required this.path,
    required this.name,
    required this.lastOpened,
    required this.lastPage,
  });

  Map<String, dynamic> toJson() => {
        'path': path,
        'name': name,
        'lastOpened': lastOpened.toIso8601String(),
        'lastPage': lastPage,
      };

  factory RecentFile.fromJson(Map<String, dynamic> json) => RecentFile(
        path: json['path'] as String,
        name: json['name'] as String,
        lastOpened: DateTime.parse(json['lastOpened'] as String),
        lastPage: json['lastPage'] as int,
      );
}
