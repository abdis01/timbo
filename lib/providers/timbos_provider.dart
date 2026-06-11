import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/timbo.dart';
import '../repositories/timbo_repository.dart';
import 'providers.dart';

final timboRepositoryProvider = Provider<TimboRepository>((ref) {
  return TimboRepository(ref.watch(databaseProvider));
});

final timbosByFolderProvider = StreamProvider.family<List<TimboModel>, int>((ref, folderId) {
  return ref.watch(timboRepositoryProvider).watchTimbosByFolder(folderId);
});

final timboProvider = StreamProvider.family<TimboModel?, int>((ref, id) {
  return ref.watch(timboRepositoryProvider).watchTimbo(id);
});
