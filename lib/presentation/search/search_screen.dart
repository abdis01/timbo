import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/painters/sketch_border_painter.dart';
import '../../domain/block.dart';
import '../../domain/timbo.dart';
import '../../domain/folder.dart';
import '../../providers/blocks_provider.dart';
import '../../providers/timbos_provider.dart';
import '../../providers/folders_provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<_SearchResult> _results = [];
  bool _searched = false;
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _search(String query) async {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() { _results = []; _searched = false; _isSearching = false; });
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final q = query.trim();
      final blockRepo = ref.read(blockRepositoryProvider);
      final timboRepo = ref.read(timboRepositoryProvider);
      final folderRepo = ref.read(folderRepositoryProvider);

      final blockResults = await blockRepo.searchBlocks(q);
      final timboResults = await timboRepo.searchTimbos(q);
      final folderResults = await folderRepo.searchFolders(q);

      final Map<int, _SearchResult> resultMap = {};

      for (final b in blockResults) {
        resultMap.putIfAbsent(b.timboId, () => _SearchResult(timboId: b.timboId, matchingBlocks: [], matchedFolder: null));
        resultMap[b.timboId]!.matchingBlocks.add(b);
      }

      for (final t in timboResults) {
        resultMap.putIfAbsent(t.id, () => _SearchResult(timboId: t.id, matchingBlocks: [], matchedFolder: null));
        resultMap[t.id]!.matchedTimbo = t;
      }

      for (final f in folderResults) {
        resultMap.putIfAbsent(-f.id, () => _SearchResult(timboId: -f.id, matchingBlocks: [], matchedFolder: f));
      }

      final results = resultMap.values.toList();
      if (mounted) setState(() { _results = results; _searched = true; _isSearching = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TimboColors.appBackground,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: TimboColors.appBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: TimboColors.appBackground,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TimboColors.ink),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            border: UnderlineInputBorder(borderSide: BorderSide(color: TimboColors.border)),
            hintText: 'Search Timbos, folders, notes...',
            hintStyle: TimboTypography.body.copyWith(color: TimboColors.inkFaint),
          ),
          style: TimboTypography.body,
          onChanged: _search,
        ),
      ),
      body: SafeArea(
        top: false,
        child: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _results.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _results.length,
              itemBuilder: (_, i) => _SearchResultCard(result: _results[i]),
            )
          : _searched
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomPaint(
                        size: const Size(60, 60),
                        painter: _SearchEmptyPainter(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No matches found',
                        style: TimboTypography.body.copyWith(color: TimboColors.ink, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try a different search term',
                        style: TimboTypography.body.copyWith(color: TimboColors.inkFaint, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomPaint(
                        size: const Size(60, 60),
                        painter: _SearchEmptyPainter(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Search your notes',
                        style: TimboTypography.body.copyWith(color: TimboColors.ink, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type to search Timbos, folders, and notes',
                        style: TimboTypography.body.copyWith(color: TimboColors.inkFaint, fontSize: 13),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}

class _SearchResult {
  final int timboId;
  final List<BlockModel> matchingBlocks;
  TimboModel? matchedTimbo;
  FolderModel? matchedFolder;

  _SearchResult({
    required this.timboId,
    required this.matchingBlocks,
    this.matchedFolder,
  }) : matchedTimbo = null;
}

class _SearchResultCard extends ConsumerWidget {
  final _SearchResult result;
  const _SearchResultCard({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (result.matchedFolder != null) {
      final folder = result.matchedFolder!;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () => context.push('/folder/${folder.id}'),
          child: CustomPaint(
            painter: SketchBorderPainter(),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: TimboColors.surface, borderRadius: BorderRadius.circular(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.folder_outlined, size: 16, color: TimboColors.inkLight),
                      const SizedBox(width: 6),
                      Text(
                        folder.title.split(',').first, 
                        style: TimboTypography.timboTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Folder match', style: TimboTypography.body.copyWith(color: TimboColors.inkFaint, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final timboAsync = ref.watch(timboProvider(result.timboId));
    final timbo = result.matchedTimbo ?? timboAsync.valueOrNull;
    if (timbo == null) return const SizedBox.shrink();

    final snippet = result.matchingBlocks.isNotEmpty
        ? result.matchingBlocks.first.textContent ?? ''
        : timbo.title ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push('/timbo/${timbo.id}'),
        child: CustomPaint(
          painter: SketchBorderPainter(),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: TimboColors.surface, borderRadius: BorderRadius.circular(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_stories_rounded, size: 16, color: TimboColors.inkLight),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        timbo.title ?? 'Untitled',
                        style: TimboTypography.timboTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (snippet.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    snippet,
                    style: TimboTypography.body.copyWith(color: TimboColors.inkLight),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (result.matchingBlocks.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${result.matchingBlocks.length} matching blocks', style: TextStyle(fontSize: 11, color: TimboColors.inkFaint)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchEmptyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TimboColors.inkFaint.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawCircle(Offset(cx - 8, cy - 8), 16, paint);
    canvas.drawLine(Offset(cx - 2, cy - 2), Offset(cx + 12, cy + 12), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
