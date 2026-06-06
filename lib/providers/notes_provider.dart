import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import '../services/hive_service.dart';

class NotesProvider extends ChangeNotifier {
  List<NoteModel> _notes = [];
  List<NoteModel> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<NoteModel> get notes => List.unmodifiable(_notes);
  List<NoteModel> get pinnedNotes =>
      _notes.where((n) => n.isPinned).toList();
  List<NoteModel> get searchResults => List.unmodifiable(_searchResults);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    _notes = HiveService.instance.getAllNotes();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(NoteModel note) async {
    await HiveService.instance.saveNote(note);
    _notes.insert(0, note);
    notifyListeners();
  }

  Future<void> updateNote(NoteModel note) async {
    await HiveService.instance.saveNote(note);
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    }
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await HiveService.instance.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<void> togglePin(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].isPinned = !_notes[index].isPinned;
      _notes[index].updatedAt = DateTime.now();
      await HiveService.instance.saveNote(_notes[index]);
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _searchResults = HiveService.instance.searchNotes(query);
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }
}
