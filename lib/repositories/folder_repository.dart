import 'dart:async';
import '../database/database.dart' hide Folder, Timbo, Block, ChatMessage;
import '../database/daos/folder_dao.dart';
import '../domain/folder.dart';

class FolderRepository {
  final TimboDatabase _db;
  late final FolderDao _dao;

  FolderRepository(this._db) {
    _dao = _db.folderDao;
  }

  Stream<List<FolderModel>> watchAllFolders() {
    return _dao.watchAllFolders().map(
      (list) => list.map((d) => FolderModel(
        id: d.id,
        title: d.title,
        date: d.date,
        createdAt: d.createdAt,
      )).toList(),
    );
  }

  Future<FolderModel> getOrCreateTodayFolder() async {
    final data = await _dao.getOrCreateTodayFolder();
    return FolderModel(
      id: data.id,
      title: data.title,
      date: data.date,
      createdAt: data.createdAt,
    );
  }

  Future<int> insertFolder(FoldersCompanion folder) => _dao.insertFolder(folder);

  Future<List<FolderModel>> searchFolders(String query) async {
    final data = await _dao.searchFolders(query);
    return data.map((d) => FolderModel(
      id: d.id, title: d.title, date: d.date, createdAt: d.createdAt,
    )).toList();
  }
}
