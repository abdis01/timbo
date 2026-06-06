import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/note_model.dart';
import '../../providers/notes_provider.dart';
import '../../widgets/note_card.dart';
import '../../widgets/bottom_nav.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isSearching = false;
  bool _isLoading = true;
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotes();
    });
  }

  Future<void> _loadNotes() async {
    try {
      await context.read<NotesProvider>().loadNotes();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't load notes. Please try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<NotesProvider>().clearSearch();
        _focusNode.unfocus();
      } else {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: _isSearching
          ? _buildSearchBar(cs)
          : _buildAppBar(cs),
      bottomNavigationBar: AppBottomNav(activeRoute: AppRoutes.notes),
      body: _isLoading
          ? _shimmerList(cs)
          : Consumer<NotesProvider>(
              builder: (context, provider, _) {
                final notes = _isSearching ? provider.searchResults : provider.notes;
                final pinned = provider.pinnedNotes;

                if (notes.isEmpty && pinned.isEmpty) {
                  return _buildEmptyState(cs);
                }

                return CustomScrollView(
                  slivers: [
                    if (pinned.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _buildPinnedHeader(cs),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            itemCount: pinned.length,
                            itemBuilder: (_, i) => SizedBox(
                              width: 180,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: NoteCard(
                                  note: pinned[i],
                                  onTap: () => _openNote(pinned[i]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (pinned.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm,
                          ),
                          child: Text(
                            'All Notes',
                            style: GoogleFonts.sora(
                              fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface,
                            ),
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final note = notes[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                child: Slidable(
                                  endActionPane: ActionPane(
                                    motion: const BehindMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (_) {
                                          HapticFeedback.lightImpact();
                                          provider.togglePin(note.id);
                                        },
                                        backgroundColor: context.warningColor,
                                        foregroundColor: Colors.white,
                                        icon: note.isPinned
                                            ? Icons.push_pin_outlined
                                            : Icons.push_pin_rounded,
                                        label: note.isPinned ? 'Unpin' : 'Pin',
                                        borderRadius: BorderRadius.circular(AppRadius.sm),
                                      ),
                                      SlidableAction(
                                        onPressed: (_) => _confirmDelete(note, provider),
                                        backgroundColor: context.dangerColor,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete_outline_rounded,
                                        label: 'Delete',
                                        borderRadius: BorderRadius.circular(AppRadius.sm),
                                      ),
                                    ],
                                  ),
                                  child: NoteCard(note: note, onTap: () => _openNote(note)),
                                ),
                              ),
                            );
                          },
                          childCount: notes.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 96)),
                  ],
                );
              },
            ),
    );
  }

  Widget _shimmerList(ColorScheme cs) {
    return Shimmer.fromColors(
      baseColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
      highlightColor: cs.surfaceContainerHighest.withValues(alpha: 0.2),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme cs) {
    return AppBar(
      title: Text(
        'Notes',
        style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w600, color: cs.onSurface),
      ),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: Icon(Icons.search_rounded, color: cs.onSurface),
          onPressed: _toggleSearch,
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSearchBar(ColorScheme cs) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        style: GoogleFonts.inter(fontSize: 16, color: cs.onSurface),
        decoration: InputDecoration(
          hintText: 'Search notes...',
          hintStyle: GoogleFonts.inter(color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          fillColor: Colors.transparent,
          filled: false,
        ),
        onChanged: (q) => context.read<NotesProvider>().search(q),
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: Icon(Icons.clear_rounded, color: cs.onSurfaceVariant),
            onPressed: () {
              _searchController.clear();
              context.read<NotesProvider>().clearSearch();
              _focusNode.requestFocus();
            },
          ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: cs.onSurface),
          onPressed: _toggleSearch,
        ),
      ],
    );
  }

  Widget _buildPinnedHeader(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.push_pin_rounded, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            'Pinned',
            style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.edit_note_rounded, size: 40, color: cs.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your story starts here',
              style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Tap '+' to capture your first thought.",
              style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('Create Note', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void _openNote(NoteModel note) {
    Navigator.pushNamed(context, AppRoutes.noteDetail, arguments: note.id);
  }

  void _confirmDelete(NoteModel note, NotesProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Note?', style: GoogleFonts.sora(fontWeight: FontWeight.w600)),
        content: Text('Are you sure?', style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              provider.deleteNote(note.id);
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
            },
            child: Text('Delete', style: GoogleFonts.inter(color: context.dangerColor)),
          ),
        ],
      ),
    );
  }
}
