import 'package:drift/drift.dart';
import '../tables/blocks_table.dart';
import '../database.dart';

part 'block_dao.g.dart';

@DriftAccessor(tables: [Blocks])
class BlockDao extends DatabaseAccessor<TimboDatabase> with _$BlockDaoMixin {
  BlockDao(super.db);

  Stream<List<Block>> watchBlocksByTimbo(int timboId) {
    return (select(blocks)
      ..where((t) => t.timboId.equals(timboId))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder, mode: OrderingMode.asc)])
    ).watch();
  }

  Future<int> insertBlock(BlocksCompanion block) => into(blocks).insert(block);

  Future<void> updateBlock(BlocksCompanion block) async {
    final id = block.id.value;
    await (update(blocks)..where((t) => t.id.equals(id))).write(block);
  }

  Future<void> deleteBlock(int id) {
    return (delete(blocks)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateSortOrder(int id, int newOrder) {
    return (update(blocks)..where((t) => t.id.equals(id)))
      .write(BlocksCompanion(sortOrder: Value(newOrder)));
  }

  Future<int> getMaxSortOrder(int timboId) async {
    final results = await (select(blocks)
      ..where((t) => t.timboId.equals(timboId))
      ..orderBy([(t) => OrderingTerm(expression: t.sortOrder, mode: OrderingMode.desc)])
      ..limit(1)
    ).get();
    if (results.isEmpty) return 0;
    return results.first.sortOrder;
  }

  Future<List<Block>> searchBlocks(String query) {
    final q = '%$query%';
    return (select(blocks)
      ..where((t) => t.textContent.like(q) | t.checklistJson.like(q))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
    ).get();
  }
}
