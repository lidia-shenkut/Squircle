import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/event_model.dart';

abstract class EventRepository {
  Future<String> createEvent(String groupId, EventModel event);
  Future<void> updateEvent(String groupId, String eventId, Map<String, dynamic> fields);
  Future<void> cancelEvent(String groupId, String eventId);
  Future<void> submitVote(String groupId, String eventId, String pollOptionId, String uid);
  Stream<List<EventModel>> watchUpcomingEvents(String groupId);
  Stream<EventModel> watchEvent(String groupId, String eventId);
}

class FirestoreEventRepository implements EventRepository {
  FirestoreEventRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference _events(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('events');

  @override
  Future<String> createEvent(String groupId, EventModel event) async {
    if (event.title.isEmpty || event.title.length > 100) {
      throw Exception('Event title must be between 1 and 100 characters.');
    }
    if (event.poll != null &&
        (event.poll!.options.length < 2 || event.poll!.options.length > 10)) {
      throw Exception('Poll must have between 2 and 10 options.');
    }
    final docRef = _events(groupId).doc();
    await docRef.set({
      ...event.toFirestore(),
      'event_id': docRef.id,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  @override
  Future<void> updateEvent(
      String groupId, String eventId, Map<String, dynamic> fields) async {
    await _events(groupId).doc(eventId).update({
      ...fields,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> cancelEvent(String groupId, String eventId) async {
    await _events(groupId).doc(eventId).update({
      'is_cancelled': true,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> submitVote(
      String groupId, String eventId, String pollOptionId, String uid) async {
    await _firestore.runTransaction((transaction) async {
      final docRef = _events(groupId).doc(eventId);
      final doc = await transaction.get(docRef);
      if (!doc.exists) throw Exception('Event not found.');

      final data = doc.data() as Map<String, dynamic>;
      final pollData = data['poll'] as Map<String, dynamic>?;
      if (pollData == null) throw Exception('This event has no poll.');

      final votes = Map<String, String>.from(pollData['votes'] ?? {});
      final options = List<Map<String, dynamic>>.from(pollData['options'] ?? []);

      // Remove previous vote if exists
      final prevOptionId = votes[uid];
      if (prevOptionId != null) {
        for (var i = 0; i < options.length; i++) {
          if (options[i]['option_id'] == prevOptionId) {
            final count = (options[i]['vote_count'] as int? ?? 0);
            options[i] = {...options[i], 'vote_count': count > 0 ? count - 1 : 0};
          }
        }
      }

      // Add new vote
      votes[uid] = pollOptionId;
      for (var i = 0; i < options.length; i++) {
        if (options[i]['option_id'] == pollOptionId) {
          final count = options[i]['vote_count'] as int? ?? 0;
          options[i] = {...options[i], 'vote_count': count + 1};
        }
      }

      transaction.update(docRef, {
        'poll.votes': votes,
        'poll.options': options,
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Stream<List<EventModel>> watchUpcomingEvents(String groupId) {
    return _events(groupId)
        .where('is_cancelled', isEqualTo: false)
        .where('event_date', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('event_date')
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<EventModel> watchEvent(String groupId, String eventId) {
    return _events(groupId).doc(eventId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Event not found.');
      return EventModel.fromFirestore(doc);
    });
  }
}
