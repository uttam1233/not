import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models.dart';

class IsarDb {
  IsarDb._();
  static final IsarDb instance = IsarDb._();

  late final Isar isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [NotebookSchema, NoteSchema],
      directory: dir.path,
    );
  }
}
