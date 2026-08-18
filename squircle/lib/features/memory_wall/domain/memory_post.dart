import 'package:cloud_firestore/cloud_firestore.dart';

enum MediaType { photo, video }

class MemoryPost {
  final String postId;
  final String authorUid;
  final String authorDisplayName;
  final String mediaUrl;
  final MediaType mediaType;
  final String? caption;
  final Map<String, List<String>> reactions;
  final DateTime createdAt;

  const MemoryPost({
    required this.postId,
    required this.authorUid,
    required this.authorDisplayName,
    required this.mediaUrl,
    required this.mediaType,
    this.caption,
    this.reactions = const {},
    required this.createdAt,
  });

  factory MemoryPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawReactions = data['reactions'] as Map<String, dynamic>? ?? {};
    final reactions = rawReactions.map(
      (emoji, uids) => MapEntry(emoji, List<String>.from(uids as List)),
    );
    return MemoryPost(
      postId: doc.id,
      authorUid: data['author_uid'] as String? ?? '',
      authorDisplayName: data['author_display_name'] as String? ?? '',
      mediaUrl: data['media_url'] as String? ?? '',
      mediaType: data['media_type'] == 'video' ? MediaType.video : MediaType.photo,
      caption: data['caption'] as String?,
      reactions: reactions,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'post_id': postId,
      'author_uid': authorUid,
      'author_display_name': authorDisplayName,
      'media_url': mediaUrl,
      'media_type': mediaType.name,
      'caption': caption,
      'reactions': reactions,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
