import 'dart:io';
import 'chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> watchMessages(String groupId, {int limit = 50});
  Future<void> sendMessage(String groupId, ChatMessage message);
  Future<void> addReaction(String groupId, String messageId, String emoji, String uid);
  Future<void> removeReaction(String groupId, String messageId, String emoji, String uid);
  Future<void> pinMessage(String groupId, String messageId);
  Future<void> unpinMessage(String groupId, String messageId);
  Stream<List<ChatMessage>> watchPinnedMessages(String groupId);
  Future<String> uploadAttachment(String groupId, File file, AttachmentType type);
  Future<int> getPinnedMessageCount(String groupId);
}
