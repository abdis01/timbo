import 'package:drift/drift.dart';

class Captures extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();
  TextColumn get rawInput => text()();
  TextColumn get content => text()();
  RealColumn get amount => real().nullable()();
  TextColumn get category => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get audioPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isAiProcessed => boolean().withDefault(const Constant(false))();
}
