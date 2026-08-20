import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firestore_mood_repository.dart';
import 'mood_checkin.dart';

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return FirestoreMoodRepository(FirebaseFirestore.instance);
});

final moodFeedProvider =
    StreamProvider.family<List<MoodCheckIn>, String>((ref, groupId) {
  return ref.watch(moodRepositoryProvider).watchMoodFeed(groupId);
});
