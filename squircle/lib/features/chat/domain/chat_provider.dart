import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firestore_chat_repository.dart';
import 'chat_message.dart';
import 'chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return FirestoreChatRepository(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
});

final messagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, groupId) {
  return ref.watch(chatRepositoryProvider).watchMessages(groupId);
});

final pinnedMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, groupId) {
  return ref.watch(chatRepositoryProvider).watchPinnedMessages(groupId);
});
