// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_dao.dart';

// ignore_for_file: type=lint
mixin _$BlockDaoMixin on DatabaseAccessor<TimboDatabase> {
  $FoldersTable get folders => attachedDatabase.folders;
  $TimbosTable get timbos => attachedDatabase.timbos;
  $BlocksTable get blocks => attachedDatabase.blocks;
  BlockDaoManager get managers => BlockDaoManager(this);
}

class BlockDaoManager {
  final _$BlockDaoMixin _db;
  BlockDaoManager(this._db);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db.attachedDatabase, _db.folders);
  $$TimbosTableTableManager get timbos =>
      $$TimbosTableTableManager(_db.attachedDatabase, _db.timbos);
  $$BlocksTableTableManager get blocks =>
      $$BlocksTableTableManager(_db.attachedDatabase, _db.blocks);
}
