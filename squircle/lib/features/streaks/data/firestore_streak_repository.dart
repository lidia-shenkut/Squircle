import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/streak_model.dart';

abstract class StreakRepository {
  Stream<UserStreak?> watchUserStreak(String uid, String groupId);
  Stream<GroupStreak> watchGroupStreak(String groupId);
  Future<void> recordActivity(String uid, String groupId);
}

class FirestoreStreakRepository implements StreakRepository {
  FirestoreStreakRepository(this._firestore);

  final FirebaseFirestore _firestore;

  String _docId(String uid, String groupId) => '${uid}__$groupId';

  DocumentReference _streakDoc(String uid, String groupId) =>
      _firestore.collection('streaks').doc(_docId(uid, groupId));

  @override
  Stream<UserStreak?> watchUserStreak(String uid, String groupId) {
    return _streakDoc(uid, groupId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserStreak.fromFirestore(doc);
    });
  }

  @override
  Stream<GroupStreak> watchGroupStreak(String groupId) {
    return _firestore.collection('groups').doc(groupId).snapshots().map((doc) {
      if (!doc.exists) {
        return GroupStreak(groupId: groupId);
      }
      final data = doc.data() as Map<String, dynamic>;
      return GroupStreak(
        groupId: groupId,
        groupStreak: data['group_streak'] as int? ?? 0,
        xp: data['xp'] as int? ?? 0,
      );
    });
  }

  @override
  Future<void> recordActivity(String uid, String groupId) async {
    final today = _todayKey();
    final docRef = _streakDoc(uid, groupId);
    final doc = await docRef.get();

    if (!doc.exists) {
      // First activity — create streak document
      await docRef.set({
        'uid': uid,
        'group_id': groupId,
        'chat_streak': 1,
        'chat_streak_last_active': today,
        'event_streak': 0,
        'event_streak_last_active': '',
        'badges': [],
        'title': null,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } else {
      final data = doc.data() as Map<String, dynamic>;
      final lastActive = data['chat_streak_last_active'] as String? ?? '';
      if (lastActive == today) return; // Already recorded today

      final yesterday = _yesterdayKey();
      final currentStreak = data['chat_streak'] as int? ?? 0;
      final newStreak = lastActive == yesterday ? currentStreak + 1 : 1;

      // Check for badge milestone
      final badges = List<String>.from(data['badges'] ?? []);
      if (newStreak % 7 == 0) {
        final badge = '🔥 ${newStreak}-day streak';
        if (!badges.contains(badge)) badges.add(badge);
      }

      await docRef.update({
        'chat_streak': newStreak,
        'chat_streak_last_active': today,
        'badges': badges,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _yesterdayKey() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }
}
