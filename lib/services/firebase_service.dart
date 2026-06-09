import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import '../models/note_model.dart';
import '../models/expense_model.dart';
import '../models/reminder_model.dart';
import '../models/quick_capture_model.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService _instance = FirebaseService._();
  static FirebaseService get instance => _instance;

  static bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FirebaseAuth get _authRef {
    if (!_isAvailable) throw Exception('Firebase not initialized');
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }
  FirebaseFirestore get _firestoreRef {
    if (!_isAvailable) throw Exception('Firebase not initialized');
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  static Future<void> init() async {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        await GoogleSignIn.instance.initialize();
        _isAvailable = true;
      } catch (_) {
        _isAvailable = false;
      }
  }

  // --- AUTH ---

  Future<UserCredential?> signUpWithEmail(
      String email, String password, String name) async {
    final cred = await _authRef.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user == null) return cred;
    await cred.user!.updateDisplayName(name);
    await _createUserDocument(cred.user!.uid, name, email);
    return cred;
  }

  Future<UserCredential?> signInWithEmail(
      String email, String password) async {
    return await _authRef.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    late final GoogleSignInAccount googleUser;
    try {
      googleUser = await GoogleSignIn.instance.authenticate();
    } catch (_) {
      return null;
    }
    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final cred = await _authRef.signInWithCredential(credential);
    final uid = cred.user?.uid;
    if (cred.additionalUserInfo?.isNewUser ?? false) {
      if (uid != null) {
        await _createUserDocument(
          uid,
          cred.user!.displayName ?? 'User',
          cred.user!.email ?? '',
        );
      }
    }
    return cred;
  }

  Future<void> signOut() async {
    await _authRef.signOut();
    await GoogleSignIn.instance.signOut();
  }

  User? get currentUser => _isAvailable ? _authRef.currentUser : null;

  bool get isLoggedIn => _isAvailable && _authRef.currentUser != null;

  Stream<User?> get authStateChanges => _authRef.authStateChanges();

  Future<void> resetPassword(String email) async {
    await _authRef.sendPasswordResetEmail(email: email);
  }

  // --- USER DOCUMENT ---

  Future<void> _createUserDocument(
      String uid, String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final shakeEnabled = prefs.getBool('shake_to_capture_enabled') ?? false;
    await _firestoreRef.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'shakeToCapture': shakeEnabled,
      'isPremium': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> checkPremiumStatus(String userId) async {
    final doc = await _firestoreRef.collection('users').doc(userId).get();
    return doc.data()?['isPremium'] as bool? ?? false;
  }

  Future<void> setPremiumStatus(String userId, bool isPremium) async {
    await _firestoreRef.collection('users').doc(userId).update({
      'isPremium': isPremium,
    });
  }

  // --- LAST SYNC TIME ---

  Future<void> updateLastSyncTime(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_sync_time_$userId', DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastSyncTime(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('last_sync_time_$userId');
    return value != null ? DateTime.tryParse(value) : null;
  }

  // --- CLOUD SYNC (Premium) ---

  Future<void> syncNotesToCloud(List<NoteModel> notes) async {
    final userId = _authRef.currentUser?.uid;
    if (userId == null) return;
    final batch = _firestoreRef.batch();
    final notesRef = _firestoreRef.collection('users').doc(userId).collection('notes');
    for (final note in notes) {
      final docRef = notesRef.doc(note.id);
      batch.set(docRef, note.toJson());
    }
    await batch.commit();
  }

  Future<void> syncExpensesToCloud(List<ExpenseModel> expenses) async {
    final userId = _authRef.currentUser?.uid;
    if (userId == null) return;
    final batch = _firestoreRef.batch();
    final ref = _firestoreRef.collection('users').doc(userId).collection('expenses');
    for (final expense in expenses) {
      final docRef = ref.doc(expense.id);
      batch.set(docRef, expense.toJson());
    }
    await batch.commit();
  }

  Future<void> syncRemindersToCloud(List<ReminderModel> reminders) async {
    final userId = _authRef.currentUser?.uid;
    if (userId == null) return;
    final batch = _firestoreRef.batch();
    final ref = _firestoreRef.collection('users').doc(userId).collection('reminders');
    for (final reminder in reminders) {
      final docRef = ref.doc(reminder.id);
      batch.set(docRef, reminder.toJson());
    }
    await batch.commit();
  }

  Future<void> fullSync(String userId, {
    required List<NoteModel> notes,
    required List<ExpenseModel> expenses,
    required List<ReminderModel> reminders,
    required List<QuickCaptureModel> captures,
  }) async {
    final batch = _firestoreRef.batch();

    final notesRef = _firestoreRef.collection('users').doc(userId).collection('notes');
    for (final note in notes) {
      batch.set(notesRef.doc(note.id), note.toJson());
    }

    final expensesRef = _firestoreRef.collection('users').doc(userId).collection('expenses');
    for (final expense in expenses) {
      batch.set(expensesRef.doc(expense.id), expense.toJson());
    }

    final remindersRef = _firestoreRef.collection('users').doc(userId).collection('reminders');
    for (final reminder in reminders) {
      batch.set(remindersRef.doc(reminder.id), reminder.toJson());
    }

    final capturesRef = _firestoreRef.collection('users').doc(userId).collection('captures');
    for (final capture in captures) {
      batch.set(capturesRef.doc(capture.id), capture.toJson());
    }

    await batch.commit();
    await updateLastSyncTime(userId);
  }

  Future<void> incrementalSync(String userId, DateTime lastSyncTime, {
    required List<NoteModel> notes,
    required List<ExpenseModel> expenses,
    required List<ReminderModel> reminders,
    required List<QuickCaptureModel> captures,
  }) async {
    final batch = _firestoreRef.batch();

    for (final note in notes.where((n) => n.updatedAt.isAfter(lastSyncTime))) {
      batch.set(_firestoreRef.collection('users').doc(userId).collection('notes').doc(note.id), note.toJson());
    }
    for (final expense in expenses.where((e) => e.updatedAt.isAfter(lastSyncTime))) {
      batch.set(_firestoreRef.collection('users').doc(userId).collection('expenses').doc(expense.id), expense.toJson());
    }
    for (final reminder in reminders.where((r) => r.updatedAt.isAfter(lastSyncTime))) {
      batch.set(_firestoreRef.collection('users').doc(userId).collection('reminders').doc(reminder.id), reminder.toJson());
    }
    for (final capture in captures.where((c) => c.updatedAt.isAfter(lastSyncTime))) {
      batch.set(_firestoreRef.collection('users').doc(userId).collection('captures').doc(capture.id), capture.toJson());
    }

    await batch.commit();
    await updateLastSyncTime(userId);
  }

  Future<SyncCloudData> downloadFromCloud(String userId) async {
    final notesSnap = await _firestoreRef.collection('users').doc(userId).collection('notes').get();
    final notes = notesSnap.docs.map((d) => NoteModel.fromJson(d.data())).toList();

    final expensesSnap = await _firestoreRef.collection('users').doc(userId).collection('expenses').get();
    final expenses = expensesSnap.docs.map((d) => ExpenseModel.fromJson(d.data())).toList();

    final remindersSnap = await _firestoreRef.collection('users').doc(userId).collection('reminders').get();
    final reminders = remindersSnap.docs.map((d) => ReminderModel.fromJson(d.data())).toList();

    final capturesSnap = await _firestoreRef.collection('users').doc(userId).collection('captures').get();
    final captures = capturesSnap.docs.map((d) => QuickCaptureModel.fromJson(d.data())).toList();

    return SyncCloudData(notes: notes, expenses: expenses, reminders: reminders, captures: captures);
  }

  Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  Stream<bool> get onConnectivityChanged {
    return Connectivity().onConnectivityChanged.map((result) => result.any((r) => r != ConnectivityResult.none));
  }

  Future<void> deleteNote(String userId, String noteId) async {
    await _firestoreRef.collection('users').doc(userId).collection('notes').doc(noteId).delete();
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    await _firestoreRef.collection('users').doc(userId).collection('expenses').doc(expenseId).delete();
  }

  Future<void> deleteReminder(String userId, String reminderId) async {
    await _firestoreRef.collection('users').doc(userId).collection('reminders').doc(reminderId).delete();
  }

  Future<void> deleteCapture(String userId, String captureId) async {
    await _firestoreRef.collection('users').doc(userId).collection('captures').doc(captureId).delete();
  }

  Future<void> enableEmailVerification() async {
    await _authRef.currentUser?.sendEmailVerification();
  }

  Future<void> waitlistSignup(String email) async {
    final existing = await _firestoreRef
        .collection('waitlist')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;
    await _firestoreRef.collection('waitlist').add({
      'email': email,
      'signedUpAt': FieldValue.serverTimestamp(),
    });
  }
}

class SyncCloudData {
  final List<NoteModel> notes;
  final List<ExpenseModel> expenses;
  final List<ReminderModel> reminders;
  final List<QuickCaptureModel> captures;

  const SyncCloudData({
    required this.notes,
    required this.expenses,
    required this.reminders,
    required this.captures,
  });
}
