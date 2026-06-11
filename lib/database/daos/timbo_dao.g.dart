// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timbo_dao.dart';

// ignore_for_file: type=lint
mixin _$TimboDaoMixin on DatabaseAccessor<TimboDatabase> {
  $FoldersTable get folders => attachedDatabase.folders;
  $TimbosTable get timbos => attachedDatabase.timbos;
  TimboDaoManager get managers => TimboDaoManager(this);
}

class TimboDaoManager {
  final _$TimboDaoMixin _db;
  TimboDaoManager(this._db);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db.attachedDatabase, _db.folders);
  $$TimbosTableTableManager get timbos =>
      $$TimbosTableTableManager(_db.attachedDatabase, _db.timbos);
}
