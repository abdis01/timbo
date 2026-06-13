import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/sketch_container.dart';
import '../../core/widgets/offline_banner.dart';
import '../../providers/timbos_provider.dart';
import '../../providers/folders_provider.dart';
import '../../providers/blocks_provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../domain/timbo.dart';

class FolderDetailScreen extends ConsumerWidget {
  final int folderId;

  const FolderDetailScreen({super.key, required this.folderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timbos = ref.watch(timbosByFolderProvider(folderId));
    final folder = ref.watch(foldersProvider).valueOrNull?.where((f) => f.id == folderId).firstOrNull;

    return Scaffold(
      backgroundColor: TimboColors.appBackground,
      appBar: AppBar(
        backgroundColor: TimboColors.appBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: TimboColors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          folder?.title ?? 'Folder',
          style: TimboTypography.folderTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: timbos.when(
              data: (list) => list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.note_add_outlined, size: 64, color: TimboColors.inkFaint),
                          const SizedBox(height: 16),
                          Text(
                            'This folder is empty',
                            style: TimboTypography.body.copyWith(color: TimboColors.ink, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap + to create your first Timbo',
                            style: TimboTypography.body.copyWith(color: TimboColors.inkFaint, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TimboPreviewCard(timbo: list[i]),
                  ),
                ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Error loading Timbos')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TimboColors.ink,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final timboId = await ref.read(timboRepositoryProvider).createTimbo(folderId: folderId);
          if (context.mounted) {
            context.push('/timbo/$timboId');
          }
        },
      ),
    );
  }
}

class _TimboPreviewCard extends ConsumerWidget {
  final TimboModel timbo;

  const _TimboPreviewCard({required this.timbo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync = ref.watch(blocksProvider(timbo.id));
    final timeStr = _formatTime(timbo.createdAt);

    return SketchContainer(
      onTap: () => context.push('/timbo/${timbo.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  timbo.title ?? 'Untitled',
                  style: TimboTypography.timboTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(timeStr, style: TimboTypography.caption),
            ],
          ),
          const SizedBox(height: 4),
          blocksAsync.when(
            data: (blocks) {
              final firstText = blocks.where((b) => b.typeString == 'text').firstOrNull;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (firstText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        firstText.textContent ?? '',
                        style: GoogleFonts.inter(fontSize: 14, color: TimboColors.inkLight),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (blocks.isNotEmpty)
                    Row(
                      children: blocks.map((b) {
                        final icon = _iconForType(b.typeString);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(icon, size: 14, color: TimboColors.inkLight),
                        );
                      }).toList(),
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 4),
              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.5)),
            ),
            error: (_, __) => const Text('Couldn\'t load preview', style: TextStyle(fontSize: 12, color: TimboColors.inkFaint)),
          ),
          if (timbo.reminderSet) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: TimboColors.ink,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.alarm, color: Colors.white, size: 10),
                  const SizedBox(width: 3),
                  Text(
                    timbo.reminderLabel ?? _formatTime(DateTime.fromMillisecondsSinceEpoch(timbo.reminderTimestamp ?? 0)),
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $ampm';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'image': return Icons.image_outlined;
      case 'voice': return Icons.mic_outlined;
      case 'checklist': return Icons.checklist_outlined;
      default: return Icons.text_fields;
    }
  }
}
