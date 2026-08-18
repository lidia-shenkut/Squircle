import 'package:cloud_firestore/cloud_firestore.dart';

enum MoodState { happy, sad, excited, tired, anxious, grateful }

extension MoodStateExtension on MoodState {
  String get emoji {
    switch (this) {
      case MoodState.happy: return '😊';
      case MoodState.sad: return '😢';
      case MoodState.excited: return '🤩';
      case MoodState.tired: return '😴';
      case MoodState.anxious: return '😰';
      case MoodState.grateful: return '🙏';
    }
  }

  String get label {
    return name[0].toUpperCase() + name.substring(1);
  }
}

MoodState? moodFromString(String value) {
  try {
    return MoodState.values.firstWhere((m) => m.name == value.toLowerCase());
  } catch (_) {
    return null;
  }
}

class MoodCheckIn {
  final String checkinId;
  final String authorUid;
  final String authorDisplayName;
  final MoodState mood;
  final Map<String, List<String>> reactions;
  final String dateKey; // YYYY-MM-DD
  final DateTime createdAt;

  const MoodCheckIn({
    required this.checkinId,
    required this.authorUid,
    required this.authorDisplayName,
    required this.mood,
    this.reactions = const {},
    required this.dateKey,
    required this.createdAt,
  });

  factory MoodCheckIn.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawReactions = data['reactions'] as Map<String, dynamic>? ?? {};
    final reactions = rawReactions.map(
      (k, v) => MapEntry(k, List<String>.from(v as List)),
    );
    return MoodCheckIn(
      checkinId: doc.id,
      authorUid: data['author_uid'] as String? ?? '',
      authorDisplayName: data['author_display_name'] as String? ?? '',
      mood: moodFromString(data['mood'] as String? ?? '') ?? MoodState.happy,
      reactions: reactions,
      dateKey: data['date_key'] as String? ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'checkin_id': checkinId,
      'author_uid': authorUid,
      'author_display_name': authorDisplayName,
      'mood': mood.name,
      'reactions': reactions,
      'date_key': dateKey,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
