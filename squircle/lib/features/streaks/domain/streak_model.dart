import 'package:cloud_firestore/cloud_firestore.dart';

class UserStreak {
  final String uid;
  final String groupId;
  final int chatStreak;
  final String chatStreakLastActive; // YYYY-MM-DD
  final int eventStreak;
  final String eventStreakLastActive; // YYYY-MM-DD
  final List<String> badges;
  final String? title;
  final DateTime updatedAt;

  const UserStreak({
    required this.uid,
    required this.groupId,
    this.chatStreak = 0,
    this.chatStreakLastActive = '',
    this.eventStreak = 0,
    this.eventStreakLastActive = '',
    this.badges = const [],
    this.title,
    required this.updatedAt,
  });

  factory UserStreak.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserStreak(
      uid: data['uid'] as String? ?? '',
      groupId: data['group_id'] as String? ?? '',
      chatStreak: data['chat_streak'] as int? ?? 0,
      chatStreakLastActive: data['chat_streak_last_active'] as String? ?? '',
      eventStreak: data['event_streak'] as int? ?? 0,
      eventStreakLastActive: data['event_streak_last_active'] as String? ?? '',
      badges: List<String>.from(data['badges'] ?? []),
      title: data['title'] as String?,
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'group_id': groupId,
      'chat_streak': chatStreak,
      'chat_streak_last_active': chatStreakLastActive,
      'event_streak': eventStreak,
      'event_streak_last_active': eventStreakLastActive,
      'badges': badges,
      'title': title,
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}

class GroupStreak {
  final String groupId;
  final int groupStreak;
  final int everyoneActiveStreak;
  final int xp;

  const GroupStreak({
    required this.groupId,
    this.groupStreak = 0,
    this.everyoneActiveStreak = 0,
    this.xp = 0,
  });
}
