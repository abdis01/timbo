import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaService {
  MediaService._();
  static final MediaService _instance = MediaService._();
  static MediaService get instance => _instance;

  static final ImagePicker _picker = ImagePicker();

  Future<String?> takePhoto() async {
    final ok = await requestCameraPermission();
    if (!ok) return null;
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) return null;
    return await saveMediaLocally(
        file.path, 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
  }

  Future<String?> recordVideo() async {
    final ok = await requestCameraPermission();
    if (!ok) return null;
    final file = await _picker.pickVideo(source: ImageSource.camera);
    if (file == null) return null;
    return await saveMediaLocally(
        file.path, 'video_${DateTime.now().millisecondsSinceEpoch}.mp4');
  }

  Future<String?> pickImageFromGallery() async {
    final ok = await requestStoragePermission();
    if (!ok) return null;
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    return file.path;
  }

  Future<String?> pickVideoFromGallery() async {
    final ok = await requestStoragePermission();
    if (!ok) return null;
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return null;
    return file.path;
  }

  Future<String> saveMediaLocally(String sourcePath, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${dir.path}/media');
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    final savedPath = '${mediaDir.path}/$filename';
    await File(sourcePath).copy(savedPath);
    return savedPath;
  }

  Future<void> deleteMedia(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String getFileSizeFormatted(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return '0 B';
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      }
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '0 B';
    }
  }

  bool isVideo(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'].contains(ext);
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
  }
}
