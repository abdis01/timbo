import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/folder.dart';
import '../repositories/folder_repository.dart';
import 'providers.dart';

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepository(ref.watch(databaseProvider));
});

final foldersProvider = StreamProvider<List<FolderModel>>((ref) {
  return ref.watch(folderRepositoryProvider).watchAllFolders();
});

final todayFolderProvider = FutureProvider<FolderModel>((ref) async {
  return ref.watch(folderRepositoryProvider).getOrCreateTodayFolder();
});
