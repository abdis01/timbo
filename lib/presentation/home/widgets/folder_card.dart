import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';
import '../../../core/widgets/sketch_container.dart';
import '../../../domain/folder.dart';
import '../../../domain/timbo.dart';
import '../../../providers/timbos_provider.dart';

class FolderCard extends ConsumerWidget {
  final FolderModel folder;

  const FolderCard({super.key, required this.folder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timbosAsync = ref.watch(timbosByFolderProvider(folder.id));

    return SketchContainer(
      onTap: () => context.push('/folder/${folder.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(folder.title.split(',')[0], style: TimboTypography.folderTitle),
          const SizedBox(height: 2),
          Text(
            DateFormat('MMMM d, yyyy').format(folder.date),
            style: TimboTypography.caption,
          ),
          const SizedBox(height: 8),
          timbosAsync.when(
            data: (timbos) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${timbos.length} Timbo${timbos.length != 1 ? 's' : ''}', style: TimboTypography.caption),
                if (timbos.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: timbos.take(2).map((t) => _PreviewChip(timbo: t)).toList(),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Text('Empty — tap to add', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: TimboColors.inkFaint)),
                ],
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 4),
              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.5)),
            ),
            error: (_, __) => const Text('Couldn\'t load', style: TextStyle(fontSize: 12, color: TimboColors.inkFaint)),
          ),
        ],
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  final TimboModel timbo;

  const _PreviewChip({required this.timbo});

  @override
  Widget build(BuildContext context) {
    final label = timbo.title ?? 'Untitled';
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: TimboColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label.length > 12 ? '${label.substring(0, 12)}...' : label,
          style: GoogleFonts.caveat(fontSize: 12, color: TimboColors.ink),
        ),
      ),
    );
  }
}
