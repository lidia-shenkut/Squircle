import 'dart:io';
import 'memory_post.dart';

abstract class MediaRepository {
  Stream<List<MemoryPost>> watchMemoryWall(String groupId);
  Future<void> createMemoryPost(String groupId, MemoryPost post);
  Future<void> deleteMemoryPost(String groupId, String postId, String requesterUid, String adminUid);
  Future<void> addReaction(String groupId, String postId, String emoji, String uid);
  Future<String> uploadMedia(String groupId, File file, MediaType type);
  Future<void> downloadMedia(String url, String localPath);
}
