import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  StorageService();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadFile({
    required String path,
    required Uint8List bytes,
    String? fileName,
  }) async {
    final ref = _storage.ref('$path/${fileName ?? _uuid.v4()}');
    final uploadTask = ref.putData(bytes);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}
