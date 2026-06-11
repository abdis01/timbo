import 'dart:async';
import 'package:drift/drift.dart';
import '../database/database.dart' hide Folder, Timbo, Block, ChatMessage;
import '../database/daos/timbo_dao.dart';
import '../domain/timbo.dart';

class TimboRepository {
  final TimboDatabase _db;
  late final TimboDao _timboDao;

  TimboRepository(this._db) {
    _timboDao = _db.timboDao;
  }

  Stream<List<TimboModel>> watchTimbosByFolder(int folderId) {
    return _timboDao.watchTimbosByFolder(folderId).map(
      (list) => list.map((d) => TimboModel(
        id: d.id,
        folderId: d.folderId,
        title: d.title,
        createdAt: d.createdAt,
        updatedAt: d.updatedAt,
        reminderSet: d.reminderSet,
        reminderTimestamp: d.reminderTimestamp,
        reminderLabel: d.reminderLabel,
      )).toList(),
    );
  }

  Stream<TimboModel?> watchTimbo(int id) {
    return _timboDao.watchTimbo(id).map((d) => d != null ? TimboModel(
      id: d.id,
      folderId: d.folderId,
      title: d.title,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
      reminderSet: d.reminderSet,
      reminderTimestamp: d.reminderTimestamp,
      reminderLabel: d.reminderLabel,
    ) : null);
  }

  Future<int> createTimbo({required int folderId, String? title}) {
    final now = DateTime.now();
    return _timboDao.insertTimbo(TimbosCompanion(
      folderId: Value(folderId),
      title: Value(title),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  Future<void> updateTimboTitle(int id, String title) {
    return _timboDao.updateTimbo(TimbosCompanion(
      id: Value(id),
      title: Value(title),
    ));
  }

  Future<void> deleteTimbo(int id) async {
    await _timboDao.deleteTimbo(id);
  }

  Future<void> setReminder(int id, int timestamp, String label) {
    return _timboDao.updateTimbo(TimbosCompanion(
      id: Value(id),
      reminderSet: const Value(true),
      reminderTimestamp: Value(timestamp),
      reminderLabel: Value(label),
    ));
  }

  Future<void> clearReminder(int id) {
    return _timboDao.updateTimbo(TimbosCompanion(
      id: Value(id),
      reminderSet: const Value(false),
      reminderTimestamp: const Value(null),
      reminderLabel: const Value(null),
    ));
  }

  Future<List<TimboModel>> searchTimbos(String query) async {
    final data = await _timboDao.searchTimbos(query);
    return data.map((d) => TimboModel(
      id: d.id, folderId: d.folderId, title: d.title,
      createdAt: d.createdAt, updatedAt: d.updatedAt,
      reminderSet: d.reminderSet,
      reminderTimestamp: d.reminderTimestamp,
      reminderLabel: d.reminderLabel,
    )).toList();
  }

  Future<List<TimboModel>> getRecentTimbos(int limit) async {
    final data = await _timboDao.getRecentTimbos(limit);
    return data.map((d) => TimboModel(
      id: d.id,
      folderId: d.folderId,
      title: d.title,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
      reminderSet: d.reminderSet,
      reminderTimestamp: d.reminderTimestamp,
      reminderLabel: d.reminderLabel,
    )).toList();
  }
}
