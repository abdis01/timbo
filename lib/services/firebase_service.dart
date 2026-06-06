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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (_) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyDFDY80vwhwGqewuAJZQJk88uHLrEVsm1M',
          appId: '1:676323736878:android:4e3f10aadbb2e92a0dcebf',
          messagingSenderId: '676323736878',
          projectId: 'timbo-4fad8',
          storageBucket: 'timbo-4fad8.firebasestorage.app',
        ),
      );
    }
  }

  // --- AUTH ---

  Future<UserCredential?> signUpWithEmail(
      String email, String password, String name) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(name);
    await _createUserDocument(cred.user!.uid, name, email);
    return cred;
  }

  Future<UserCredential?> signInWithEmail(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    if (cred.additionalUserInfo?.isNewUser ?? false) {
      await _createUserDocument(
        cred.user!.uid,
        cred.user!.displayName ?? 'User',
        cred.user!.email ?? '',
      );
    }
    return cred;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // --- USER DOCUMENT ---

  Future<void> _createUserDocument(
      String uid, String name, String email) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'isPremium': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> checkPremiumStatus(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['isPremium'] as bool? ?? false;
  }

  Future<void> setPremiumStatus(String userId, bool isPremium) async {
    await _firestore.collection('users').doc(userId).update({
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
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    final batch = _firestore.batch();
    final notesRef = _firestore.collection('users').doc(userId).collection('notes');
    for (final note in notes) {
      final docRef = notesRef.doc(note.id);
      batch.set(docRef, note.toJson());
    }
    await batch.commit();
  }

  Future<void> syncExpensesToCloud(List<ExpenseModel> expenses) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    final batch = _firestore.batch();
    final ref = _firestore.collection('users').doc(userId).collection('expenses');
    for (final expense in expenses) {
      final docRef = ref.doc(expense.id);
      batch.set(docRef, expense.toJson());
    }
    await batch.commit();
  }

  Future<void> syncRemindersToCloud(List<ReminderModel> reminders) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    final batch = _firestore.batch();
    final ref = _firestore.collection('users').doc(userId).collection('reminders');
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
    final batch = _firestore.batch();

    final notesRef = _firestore.collection('users').doc(userId).collection('notes');
    for (final note in notes) {
      batch.set(notesRef.doc(note.id), note.toJson());
    }

    final expensesRef = _firestore.collection('users').doc(userId).collection('expenses');
    for (final expense in expenses) {
      batch.set(expensesRef.doc(expense.id), expense.toJson());
    }

    final remindersRef = _firestore.collection('users').doc(userId).collection('reminders');
    for (final reminder in reminders) {
      batch.set(remindersRef.doc(reminder.id), reminder.toJson());
    }

    final capturesRef = _firestore.collection('users').doc(userId).collection('captures');
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
    final batch = _firestore.batch();

    for (final note in notes.where((n) => n.updatedAt.isAfter(lastSyncTime))) {
      batch.set(_firestore.collection('users').doc(userId).collection('notes').doc(note.id), note.toJson());
    }
    for (final expense in expenses.where((e) => e.updatedAt.isAfter(lastSyncTime))) {
      batch.set(_firestore.collection('users').doc(userId).collection('expenses').doc(expense.id), expense.toJson());
    }
    for (final reminder in reminders.where((r) => r.updatedAt.isAfter(lastSyncTime))) {
      batch.set(_firestore.collection('users').doc(userId).collection('reminders').doc(reminder.id), reminder.toJson());
    }
    for (final capture in captures.where((c) => c.updatedAt.isAfter(lastSyncTime))) {
      batch.set(_firestore.collection('users').doc(userId).collection('captures').doc(capture.id), capture.toJson());
    }

    await batch.commit();
    await updateLastSyncTime(userId);
  }

  Future<SyncCloudData> downloadFromCloud(String userId) async {
    final notesSnap = await _firestore.collection('users').doc(userId).collection('notes').get();
    final notes = notesSnap.docs.map((d) => NoteModel.fromJson(d.data())).toList();

    final expensesSnap = await _firestore.collection('users').doc(userId).collection('expenses').get();
    final expenses = expensesSnap.docs.map((d) => ExpenseModel.fromJson(d.data())).toList();

    final remindersSnap = await _firestore.collection('users').doc(userId).collection('reminders').get();
    final reminders = remindersSnap.docs.map((d) => ReminderModel.fromJson(d.data())).toList();

    final capturesSnap = await _firestore.collection('users').doc(userId).collection('captures').get();
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

  Future<void> enableEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> waitlistSignup(String email) async {
    await _firestore.collection('waitlist').add({
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
