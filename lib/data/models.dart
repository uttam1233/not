import 'package:isar_community/isar.dart';

part 'models.g.dart';

@collection
class Notebook {
  Id id = Isar.autoIncrement;

  @Index(caseSensitive: false)
  late String name;

  int colorValue = 0xFF3B82F6;
  DateTime createdAt = DateTime.now();
}

@collection
class Note {
  Id id = Isar.autoIncrement;

  int notebookId = 0;

  @Index(caseSensitive: false)
  String title = 'Untitled';

  /// Quill Delta JSON string
  String deltaJson = '[]';

  /// Plain text for quick search
  @Index(caseSensitive: false)
  String plainText = '';

  bool pinned = false;

  DateTime createdAt = DateTime.now();

  @Index()
  DateTime updatedAt = DateTime.now();
}
