import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../domain/chat_message.dart';
import '../domain/chat_repository.dart';

class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  CollectionReference _messages(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('messages');

  @override
  Stream<List<ChatMessage>> watchMessages(String groupId, {int limit = 50}) {
    return _messages(groupId)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList()
            .reversed
            .toList());
  }

  @override
  Future<void> sendMessage(String groupId, ChatMessage message) async {
    final docRef = _messages(groupId).doc();
    await docRef.set({
      ...message.toFirestore(),
      'message_id': docRef.id,
      'created_at': FieldValue.serverTimestamp(),
      'delivered': true,
    });
  }

  @override
  Future<void> addReaction(
      String groupId, String messageId, String emoji, String uid) async {
    await _messages(groupId).doc(messageId).update({
      'reactions.$emoji': FieldValue.arrayUnion([uid]),
    });
  }

  @override
  Future<void> removeReaction(
      String groupId, String messageId, String emoji, String uid) async {
    await _messages(groupId).doc(messageId).update({
      'reactions.$emoji': FieldValue.arrayRemove([uid]),
    });
  }

  @override
  Future<void> pinMessage(String groupId, String messageId) async {
    final count = await getPinnedMessageCount(groupId);
    if (count >= 10) {
      throw Exception('Cannot pin more than 10 messages in a group.');
    }
    await _messages(groupId).doc(messageId).update({'is_pinned': true});
  }

  @override
  Future<void> unpinMessage(String groupId, String messageId) async {
    await _messages(groupId).doc(messageId).update({'is_pinned': false});
  }

  @override
  Stream<List<ChatMessage>> watchPinnedMessages(String groupId) {
    return _messages(groupId)
        .where('is_pinned', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList());
  }

  @override
  Future<int> getPinnedMessageCount(String groupId) async {
    final snap = await _messages(groupId)
        .where('is_pinned', isEqualTo: true)
        .count()
        .get();
    return snap.count ?? 0;
  }

  @override
  Future<String> uploadAttachment(
      String groupId, File file, AttachmentType type) async {
    final fileSize = await file.length();
    if (fileSize > 100 * 1024 * 1024) {
      throw Exception('Attachment must be 100 MB or less.');
    }
    final ext = file.path.split('.').last;
    final fileName = '${_uuid.v4()}.$ext';
    final ref = _storage.ref('groups/$groupId/chat/$fileName');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }
}
