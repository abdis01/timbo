import 'package:drift/drift.dart';
import 'folders_table.dart';

class Timbos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get folderId => integer().references(Folders, #id)();
  TextColumn get title => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get reminderTimestamp => integer().nullable()();
  TextColumn get reminderLabel => text().nullable()();
  BoolColumn get reminderSet => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
