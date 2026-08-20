import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firestore_event_repository.dart';
import 'event_model.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return FirestoreEventRepository(FirebaseFirestore.instance);
});

final upcomingEventsProvider =
    StreamProvider.family<List<EventModel>, String>((ref, groupId) {
  return ref.watch(eventRepositoryProvider).watchUpcomingEvents(groupId);
});
