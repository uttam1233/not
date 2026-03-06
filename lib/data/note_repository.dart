import 'package:isar_community/isar.dart';

import 'isar_db.dart';
import 'models.dart';

class NoteRepository {
  final Isar _isar = IsarDb.instance.isar;

  // --- Notebooks ---
  Stream<List<Notebook>> watchNotebooks() {
    return _isar.notebooks.where().sortByName().watch(fireImmediately: true);
  }

  Future<int> addNotebook(String name, {int colorValue = 0xFF3B82F6}) async {
    final nb = Notebook()
      ..name = name
      ..colorValue = colorValue
      ..createdAt = DateTime.now();

    return _isar.writeTxn(() async => _isar.notebooks.put(nb));
  }

  // --- Notes ---
  Stream<List<Note>> watchNotes(int notebookId, {String? query}) {
    final q = (query ?? '').trim();

    final base = _isar.notes.filter().notebookIdEqualTo(notebookId);
    final filtered = q.isEmpty
        ? base
        : base.group((qq) => qq
            .titleContains(q, caseSensitive: false)
            .or()
            .plainTextContains(q, caseSensitive: false));

    return filtered
        .sortByPinnedDesc()
        .thenByUpdatedAtDesc()
        .watch(fireImmediately: true);
  }

  Future<int> createNote(int notebookId) async {
    final note = Note()
      ..notebookId = notebookId
      ..title = 'New Note'
      ..deltaJson = '[]'
      ..plainText = ''
      ..pinned = false
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    return _isar.writeTxn(() async => _isar.notes.put(note));
  }

  Future<Note?> getNote(int id) => _isar.notes.get(id);

  Future<void> togglePin(int id) async {
    await _isar.writeTxn(() async {
      final n = await _isar.notes.get(id);
      if (n == null) return;
      n.pinned = !n.pinned;
      n.updatedAt = DateTime.now();
      await _isar.notes.put(n);
    });
  }

  Future<void> deleteNote(int id) async {
    await _isar.writeTxn(() async => _isar.notes.delete(id));
  }

  Future<void> updateNote(
    int id, {
    String? title,
    String? deltaJson,
    String? plainText,
  }) async {
    await _isar.writeTxn(() async {
      final n = await _isar.notes.get(id);
      if (n == null) return;
      if (title != null) n.title = title;
      if (deltaJson != null) n.deltaJson = deltaJson;
      if (plainText != null) n.plainText = plainText;
      n.updatedAt = DateTime.now();
      await _isar.notes.put(n);
    });
  }
}
