import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/block.dart';
import '../repositories/block_repository.dart';
import 'providers.dart';

final blockRepositoryProvider = Provider<BlockRepository>((ref) {
  return BlockRepository(ref.watch(databaseProvider));
});

final blocksProvider = StreamProvider.family<List<BlockModel>, int>((ref, timboId) {
  return ref.watch(blockRepositoryProvider).watchBlocks(timboId);
});
