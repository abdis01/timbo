import 'package:drift/drift.dart';
import 'timbos_table.dart';

class Blocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get timboId => integer().references(Timbos, #id)();
  TextColumn get type => text()();
  IntColumn get sortOrder => integer()();
  TextColumn get textContent => text().nullable()();
  TextColumn get filePath => text().nullable()();
  TextColumn get checklistJson => text().nullable()();
  TextColumn get drawingData => text().nullable()();
  TextColumn get fontFamily => text().nullable()();
  RealColumn get positionX => real().nullable()();
  RealColumn get positionY => real().nullable()();
  RealColumn get blockWidth => real().nullable()();
  RealColumn get blockHeight => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
