class NotificationPreferences {
  final bool chatMessages;
  final bool memoryPosts;
  final bool events;
  final bool eventReminders;
  final bool streakAlerts;
  final bool gameSessions;
  final bool moodCheckins;

  const NotificationPreferences({
    this.chatMessages = true,
    this.memoryPosts = true,
    this.events = true,
    this.eventReminders = true,
    this.streakAlerts = true,
    this.gameSessions = true,
    this.moodCheckins = true,
  });

  factory NotificationPreferences.fromMap(Map<String, dynamic> data) {
    return NotificationPreferences(
      chatMessages: data['chat_messages'] as bool? ?? true,
      memoryPosts: data['memory_posts'] as bool? ?? true,
      events: data['events'] as bool? ?? true,
      eventReminders: data['event_reminders'] as bool? ?? true,
      streakAlerts: data['streak_alerts'] as bool? ?? true,
      gameSessions: data['game_sessions'] as bool? ?? true,
      moodCheckins: data['mood_checkins'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chat_messages': chatMessages,
      'memory_posts': memoryPosts,
      'events': events,
      'event_reminders': eventReminders,
      'streak_alerts': streakAlerts,
      'game_sessions': gameSessions,
      'mood_checkins': moodCheckins,
    };
  }

  NotificationPreferences copyWith({
    bool? chatMessages,
    bool? memoryPosts,
    bool? events,
    bool? eventReminders,
    bool? streakAlerts,
    bool? gameSessions,
    bool? moodCheckins,
  }) {
    return NotificationPreferences(
      chatMessages: chatMessages ?? this.chatMessages,
      memoryPosts: memoryPosts ?? this.memoryPosts,
      events: events ?? this.events,
      eventReminders: eventReminders ?? this.eventReminders,
      streakAlerts: streakAlerts ?? this.streakAlerts,
      gameSessions: gameSessions ?? this.gameSessions,
      moodCheckins: moodCheckins ?? this.moodCheckins,
    );
  }
}
