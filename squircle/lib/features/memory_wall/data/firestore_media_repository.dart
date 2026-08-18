import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';
import '../domain/media_repository.dart';
import '../domain/memory_post.dart';

class FirestoreMediaRepository implements MediaRepository {
  FirestoreMediaRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  CollectionReference _posts(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('memory_posts');

  @override
  Stream<List<MemoryPost>> watchMemoryWall(String groupId) {
    return _posts(groupId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => MemoryPost.fromFirestore(doc)).toList());
  }

  @override
  Future<void> createMemoryPost(String groupId, MemoryPost post) async {
    final docRef = _posts(groupId).doc();
    await docRef.set({
      ...post.toFirestore(),
      'post_id': docRef.id,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteMemoryPost(
      String groupId, String postId, String requesterUid, String adminUid) async {
    final doc = await _posts(groupId).doc(postId).get();
    if (!doc.exists) throw Exception('Post not found.');
    final data = doc.data() as Map<String, dynamic>;
    if (data['author_uid'] != requesterUid && requesterUid != adminUid) {
      throw Exception('You can only delete your own posts.');
    }
    await _posts(groupId).doc(postId).delete();
  }

  @override
  Future<void> addReaction(
      String groupId, String postId, String emoji, String uid) async {
    await _posts(groupId).doc(postId).update({
      'reactions.$emoji': FieldValue.arrayUnion([uid]),
    });
  }

  @override
  Future<String> uploadMedia(
      String groupId, File file, MediaType type) async {
    final fileSize = await file.length();
    final mimeType = lookupMimeType(file.path) ?? '';

    if (type == MediaType.photo) {
      const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
      const maxSize = 20 * 1024 * 1024; // 20 MB
      if (!allowedMimes.contains(mimeType)) {
        throw Exception('Photo must be JPEG, PNG, or WebP.');
      }
      if (fileSize > maxSize) throw Exception('Photo must be 20 MB or less.');
    } else {
      const allowedMimes = ['video/mp4', 'video/quicktime'];
      const maxSize = 500 * 1024 * 1024; // 500 MB
      if (!allowedMimes.contains(mimeType)) {
        throw Exception('Video must be MP4 or MOV.');
      }
      if (fileSize > maxSize) throw Exception('Video must be 500 MB or less.');
    }

    final ext = file.path.split('.').last;
    final fileName = '${_uuid.v4()}.$ext';
    final ref = _storage.ref('groups/$groupId/media/$fileName');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  @override
  Future<void> downloadMedia(String url, String localPath) async {
    final ref = _storage.refFromURL(url);
    await ref.writeToFile(File(localPath));
  }
}
