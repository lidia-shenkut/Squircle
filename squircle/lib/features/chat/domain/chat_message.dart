import 'package:cloud_firestore/cloud_firestore.dart';

enum AttachmentType { image, video, audio }

class ChatMessage {
  final String messageId;
  final String senderUid;
  final String senderDisplayName;
  final String senderAvatarUrl;
  final String? content;
  final String? attachmentUrl;
  final AttachmentType? attachmentType;
  final Map<String, List<String>> reactions; // emoji -> [uid]
  final bool isPinned;
  final DateTime createdAt;
  final bool delivered;

  const ChatMessage({
    required this.messageId,
    required this.senderUid,
    required this.senderDisplayName,
    this.senderAvatarUrl = '',
    this.content,
    this.attachmentUrl,
    this.attachmentType,
    this.reactions = const {},
    this.isPinned = false,
    required this.createdAt,
    this.delivered = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawReactions = data['reactions'] as Map<String, dynamic>? ?? {};
    final reactions = rawReactions.map(
      (emoji, uids) => MapEntry(emoji, List<String>.from(uids as List)),
    );

    AttachmentType? attachmentType;
    final typeStr = data['attachment_type'] as String?;
    if (typeStr == 'image') attachmentType = AttachmentType.image;
    if (typeStr == 'video') attachmentType = AttachmentType.video;
    if (typeStr == 'audio') attachmentType = AttachmentType.audio;

    return ChatMessage(
      messageId: doc.id,
      senderUid: data['sender_uid'] as String? ?? '',
      senderDisplayName: data['sender_display_name'] as String? ?? '',
      senderAvatarUrl: data['sender_avatar_url'] as String? ?? '',
      content: data['content'] as String?,
      attachmentUrl: data['attachment_url'] as String?,
      attachmentType: attachmentType,
      reactions: reactions,
      isPinned: data['is_pinned'] as bool? ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      delivered: data['delivered'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'message_id': messageId,
      'sender_uid': senderUid,
      'sender_display_name': senderDisplayName,
      'sender_avatar_url': senderAvatarUrl,
      'content': content,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType?.name,
      'reactions': reactions,
      'is_pinned': isPinned,
      'created_at': Timestamp.fromDate(createdAt),
      'delivered': delivered,
    };
  }
}
