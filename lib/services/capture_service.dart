import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../database/database.dart';
import '../database/captures_table.dart';

class CaptureService {
  final TimboDatabase _db;

  CaptureService(this._db);

  Future<Capture> processAndSave({
    required String rawInput,
    String? type,
    double? amount,
    String? category,
    DateTime? scheduledAt,
    bool isOnline = false,
  }) async {
    if (isOnline && type == null) {
      try {
        final result = await _processWithAi(rawInput);
        return _saveFromAiResult(rawInput, result);
      } catch (_) {
        return _saveDirect(rawInput, 'note');
      }
    }

    return _saveDirect(
      rawInput,
      type ?? 'note',
      amount: amount,
      category: category,
      scheduledAt: scheduledAt,
    );
  }

  Future<Map<String, dynamic>> _processWithAi(String rawInput) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final token = await user.getIdToken();
    final response = await http.post(
      Uri.parse(
        'https://processcapture-${FirebaseAuth.instance.app.options.projectId}.cloudfunctions.net/processCapture',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'rawInput': rawInput}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('AI processing failed');
  }

  Future<Capture> _saveFromAiResult(String rawInput, Map<String, dynamic> result) async {
    final capture = CapturesCompanion(
      type: Value(result['type'] as String? ?? 'note'),
      rawInput: Value(rawInput),
      content: Value(result['content'] as String? ?? rawInput),
      amount: Value((result['amount'] as num?)?.toDouble()),
      category: Value(result['category'] as String?),
      scheduledAt: result['scheduledAt'] != null
          ? Value(DateTime.parse(result['scheduledAt'] as String))
          : const Value(null),
      isSynced: const Value(true),
      isAiProcessed: const Value(true),
      createdAt: Value(DateTime.now()),
    );
    final id = await _db.insertCapture(capture);
    return (await _db.getCapture(id))!;
  }

  Future<Capture> _saveDirect(
    String rawInput,
    String type, {
    double? amount,
    String? category,
    DateTime? scheduledAt,
    bool isSynced = false,
  }) async {
    final capture = CapturesCompanion(
      type: Value(type),
      rawInput: Value(rawInput),
      content: Value(rawInput),
      amount: Value(amount),
      category: Value(category),
      scheduledAt: Value(scheduledAt),
      isCompleted: const Value(false),
      isSynced: Value(isSynced),
      isAiProcessed: const Value(false),
      createdAt: Value(DateTime.now()),
    );
    final id = await _db.insertCapture(capture);
    return (await _db.getCapture(id))!;
  }

  Future<List<Capture>> processPendingCaptures() async {
    final unsynced = await _db.getUnsyncedCaptures();
    final processed = <Capture>[];
    for (final capture in unsynced) {
      try {
        final result = await _processWithAi(capture.rawInput);
        final updated = CapturesCompanion(
          id: Value(capture.id),
          type: Value(result['type'] as String? ?? capture.type),
          content: Value(result['content'] as String? ?? capture.content),
          amount: Value((result['amount'] as num?)?.toDouble() ?? capture.amount),
          category: Value(result['category'] as String? ?? capture.category),
          scheduledAt: result['scheduledAt'] != null
              ? Value(DateTime.parse(result['scheduledAt'] as String))
              : Value(capture.scheduledAt),
          isSynced: const Value(true),
          isAiProcessed: const Value(true),
          createdAt: Value(capture.createdAt),
        );
        await _db.updateCapture(updated);
        final updatedCapture = await _db.getCapture(capture.id);
        if (updatedCapture != null) processed.add(updatedCapture);
      } catch (_) {}
    }
    return processed;
  }
}
