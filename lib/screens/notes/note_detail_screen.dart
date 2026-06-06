import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/theme.dart';
import '../../models/note_model.dart';
import '../../providers/notes_provider.dart';
// TODO: Add export notes to PDF feature

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  NoteModel? _note;
  bool _hasUnsavedChanges = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final noteId = ModalRoute.of(context)?.settings.arguments as String?;
    if (noteId != null && _note == null) {
      final provider = context.read<NotesProvider>();
      final note = provider.notes.where((n) => n.id == noteId).firstOrNull;
      if (note != null) {
        _note = note;
        _titleController = TextEditingController(text: note.title);
        _contentController = TextEditingController(text: note.content);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  Future<void> _save() async {
    if (_note == null) return;
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) return;

    try {
      final updated = _note!.copyWith(
        title: title,
        content: content,
        updatedAt: DateTime.now(),
      );
      await context.read<NotesProvider>().updateNote(updated);
      setState(() {
        _note = updated;
        _hasUnsavedChanges = false;
      });
      HapticFeedback.lightImpact();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't save. Please try again.")),
        );
      }
    }
  }

  Future<void> _saveAndPop() async {
    if (_hasUnsavedChanges) {
      await _save();
    }
    if (mounted) Navigator.pop(context);
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('Do you want to save before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == true) {
      await _save();
      return true;
    }
    return result == false;
  }

  Future<void> _togglePin() async {
    if (_note == null) return;
    try {
      await context.read<NotesProvider>().togglePin(_note!.id);
      setState(() => _note!.isPinned = !_note!.isPinned);
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  Future<void> _delete() async {
    if (_note == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(
                color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await context.read<NotesProvider>().deleteNote(_note!.id);
        HapticFeedback.mediumImpact();
        if (mounted) Navigator.pop(context);
      } catch (_) {}
    }
  }

  void _share() {
    if (_note == null) return;
    final text = '${_note!.title}\n\n${_note!.content}';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    if (_note == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Note not found')),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textPrimary = cs.onSurface;
    final textSecondary = cs.onSurfaceVariant;
    final primary = cs.primary;
    final cardColor = context.cardColor;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: Text(
            DateFormat('MMM d, yyyy').format(_note!.updatedAt),
            style: GoogleFonts.inter(fontSize: 14, color: textSecondary),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
            onPressed: _saveAndPop,
          ),
          actions: [
            IconButton(
              icon: Icon(
                _note!.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: _note!.isPinned ? primary : textSecondary,
              ),
              onPressed: _togglePin,
            ),
            IconButton(
              icon: Icon(Icons.share_outlined, color: textSecondary),
              onPressed: _share,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: textSecondary),
              onPressed: _delete,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                style: GoogleFonts.sora(
                  fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: GoogleFonts.sora(
                    fontSize: 24, fontWeight: FontWeight.w700,
                    color: textSecondary.withValues(alpha: 0.3),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: false,
                ),
                maxLines: null,
                onChanged: (_) { _markChanged(); _save(); },
              ),
              const SizedBox(height: 4),
              Text(
                'Last edited ${DateFormat('MMM d, yyyy – h:mm a').format(_note!.updatedAt)}',
                style: GoogleFonts.inter(fontSize: 12, color: textSecondary.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_note!.mediaPaths.isNotEmpty) ...[
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _note!.mediaPaths.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final path = _note!.mediaPaths[i];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Image.file(File(path), width: 180, fit: BoxFit.cover),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              if (_note!.voiceNotePath != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.mic_rounded, color: primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Voice Note',
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary)),
                            Text('Tap to play',
                                style: GoogleFonts.inter(fontSize: 11, color: textSecondary)),
                          ],
                        ),
                      ),
                      Icon(Icons.play_circle_outline_rounded, color: primary, size: 28),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              TextField(
                controller: _contentController,
                style: GoogleFonts.inter(fontSize: 16, height: 1.6, color: textPrimary),
                decoration: InputDecoration(
                  hintText: 'Start writing...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 16, color: textSecondary.withValues(alpha: 0.3),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: false,
                ),
                maxLines: null,
                onChanged: (_) { _markChanged(); _save(); },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
