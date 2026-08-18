import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/mood_checkin.dart';

abstract class MoodRepository {
  Future<void> submitMoodCheckIn(String groupId, String uid,
      String displayName, MoodState mood);
  Stream<List<MoodCheckIn>> watchMoodFeed(String groupId);
  Future<void> addReaction(
      String groupId, String checkinId, String reaction, String uid);
  Future<bool> hasCheckedInToday(String uid, String groupId);
}

class FirestoreMoodRepository implements MoodRepository {
  FirestoreMoodRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference _checkins(String groupId) => _firestore
      .collection('groups')
      .doc(groupId)
      .collection('mood_checkins');

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<bool> hasCheckedInToday(String uid, String groupId) async {
    final today = _todayKey();
    final snap = await _checkins(groupId)
        .where('author_uid', isEqualTo: uid)
        .where('date_key', isEqualTo: today)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  @override
  Future<void> submitMoodCheckIn(
      String groupId, String uid, String displayName, MoodState mood) async {
    final alreadyCheckedIn = await hasCheckedInToday(uid, groupId);
    if (alreadyCheckedIn) {
      throw Exception(
          'You\'ve already shared your mood today. Come back tomorrow!');
    }

    final today = _todayKey();
    final docRef = _checkins(groupId).doc();
    await docRef.set({
      'checkin_id': docRef.id,
      'author_uid': uid,
      'author_display_name': displayName,
      'mood': mood.name,
      'reactions': {},
      'date_key': today,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<MoodCheckIn>> watchMoodFeed(String groupId) {
    final today = _todayKey();
    return _checkins(groupId)
        .where('date_key', isEqualTo: today)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => MoodCheckIn.fromFirestore(doc)).toList());
  }

  @override
  Future<void> addReaction(
      String groupId, String checkinId, String reaction, String uid) async {
    await _checkins(groupId).doc(checkinId).update({
      'reactions.$reaction': FieldValue.arrayUnion([uid]),
    });
  }
}
