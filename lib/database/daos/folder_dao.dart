import 'package:drift/drift.dart';
import '../tables/folders_table.dart';
import '../database.dart';

part 'folder_dao.g.dart';

@DriftAccessor(tables: [Folders])
class FolderDao extends DatabaseAccessor<TimboDatabase> with _$FolderDaoMixin {
  FolderDao(super.db);

  Stream<List<Folder>> watchAllFolders() {
    return (select(folders)
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)])
    ).watch();
  }

  Future<Folder?> getFolderByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    return (select(folders)
      ..where((t) => t.date.equals(start))
    ).getSingleOrNull();
  }

  Future<int> insertFolder(FoldersCompanion folder) => into(folders).insert(folder);

  Future<Folder> getOrCreateTodayFolder() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final existing = await getFolderByDate(today);
    if (existing != null) return existing;
    await insertFolder(FoldersCompanion(
      title: Value(_formatTitle(now)),
      date: Value(today),
      createdAt: Value(now),
    ));
    final folder = await getFolderByDate(today);
    if (folder == null) {
      throw Exception('Failed to create today\'s folder');
    }
    return folder;
  }

  Future<List<Folder>> searchFolders(String query) {
    return (select(folders)
      ..where((t) => t.title.like('%$query%'))
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)])
    ).get();
  }

  String _formatTitle(DateTime dt) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }
}
