import 'package:cloud_firestore/cloud_firestore.dart';

class GroupAnalytics {
  final String mostActiveUid;
  final int mostActiveCount;
  final String topMediaSenderUid;
  final int topMediaSenderCount;
  final String longestStreakUid;
  final int longestStreakCount;
  final List<String> ghostMemberUids;
  final int totalMemoryPosts;
  final DateTime? computedAt;

  const GroupAnalytics({
    this.mostActiveUid = '',
    this.mostActiveCount = 0,
    this.topMediaSenderUid = '',
    this.topMediaSenderCount = 0,
    this.longestStreakUid = '',
    this.longestStreakCount = 0,
    this.ghostMemberUids = const [],
    this.totalMemoryPosts = 0,
    this.computedAt,
  });

  factory GroupAnalytics.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupAnalytics(
      mostActiveUid: data['most_active_uid'] as String? ?? '',
      mostActiveCount: data['most_active_count'] as int? ?? 0,
      topMediaSenderUid: data['top_media_sender_uid'] as String? ?? '',
      topMediaSenderCount: data['top_media_sender_count'] as int? ?? 0,
      longestStreakUid: data['longest_streak_uid'] as String? ?? '',
      longestStreakCount: data['longest_streak_count'] as int? ?? 0,
      ghostMemberUids: List<String>.from(data['ghost_member_uids'] ?? []),
      totalMemoryPosts: data['total_memory_posts'] as int? ?? 0,
      computedAt: (data['computed_at'] as Timestamp?)?.toDate(),
    );
  }
}
