import 'package:cloud_firestore/cloud_firestore.dart';

class PollOption {
  final String optionId;
  final String label;
  final int voteCount;

  const PollOption({
    required this.optionId,
    required this.label,
    this.voteCount = 0,
  });

  factory PollOption.fromMap(Map<String, dynamic> data) {
    return PollOption(
      optionId: data['option_id'] as String? ?? '',
      label: data['label'] as String? ?? '',
      voteCount: data['vote_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'option_id': optionId, 'label': label, 'vote_count': voteCount};
  }
}

class EventPoll {
  final List<PollOption> options;
  final Map<String, String> votes; // uid -> optionId

  const EventPoll({required this.options, this.votes = const {}});

  factory EventPoll.fromMap(Map<String, dynamic> data) {
    return EventPoll(
      options: (data['options'] as List? ?? [])
          .map((o) => PollOption.fromMap(o as Map<String, dynamic>))
          .toList(),
      votes: Map<String, String>.from(data['votes'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'options': options.map((o) => o.toMap()).toList(),
      'votes': votes,
    };
  }
}

class EventModel {
  final String eventId;
  final String creatorUid;
  final String title;
  final DateTime eventDate;
  final bool isCancelled;
  final EventPoll? poll;
  final bool reminder24hSent;
  final bool reminder1hSent;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventModel({
    required this.eventId,
    required this.creatorUid,
    required this.title,
    required this.eventDate,
    this.isCancelled = false,
    this.poll,
    this.reminder24hSent = false,
    this.reminder1hSent = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      eventId: doc.id,
      creatorUid: data['creator_uid'] as String? ?? '',
      title: data['title'] as String? ?? '',
      eventDate: (data['event_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCancelled: data['is_cancelled'] as bool? ?? false,
      poll: data['poll'] != null
          ? EventPoll.fromMap(data['poll'] as Map<String, dynamic>)
          : null,
      reminder24hSent: data['reminder_24h_sent'] as bool? ?? false,
      reminder1hSent: data['reminder_1h_sent'] as bool? ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'event_id': eventId,
      'creator_uid': creatorUid,
      'title': title,
      'event_date': Timestamp.fromDate(eventDate),
      'is_cancelled': isCancelled,
      'poll': poll?.toMap(),
      'reminder_24h_sent': reminder24hSent,
      'reminder_1h_sent': reminder1hSent,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  Duration get timeUntilEvent => eventDate.difference(DateTime.now());
}
