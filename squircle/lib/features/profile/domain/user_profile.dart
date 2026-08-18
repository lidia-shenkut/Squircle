import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? email;
  final String? phone;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final String avatarType; // "default" | "photo"
  final String? defaultAvatarId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> fcmTokens;
  final List<String> groupIds;

  const UserProfile({
    required this.uid,
    this.email,
    this.phone,
    required this.displayName,
    required this.username,
    this.avatarUrl,
    this.avatarType = 'default',
    this.defaultAvatarId,
    required this.createdAt,
    required this.updatedAt,
    this.fcmTokens = const [],
    this.groupIds = const [],
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      displayName: data['display_name'] as String? ?? '',
      username: data['username'] as String? ?? '',
      avatarUrl: data['avatar_url'] as String?,
      avatarType: data['avatar_type'] as String? ?? 'default',
      defaultAvatarId: data['default_avatar_id'] as String?,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fcmTokens: List<String>.from(data['fcm_tokens'] ?? []),
      groupIds: List<String>.from(data['group_ids'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'phone': phone,
      'display_name': displayName,
      'username': username,
      'avatar_url': avatarUrl,
      'avatar_type': avatarType,
      'default_avatar_id': defaultAvatarId,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'fcm_tokens': fcmTokens,
      'group_ids': groupIds,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? username,
    String? avatarUrl,
    String? avatarType,
    String? defaultAvatarId,
    List<String>? fcmTokens,
    List<String>? groupIds,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      phone: phone,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarType: avatarType ?? this.avatarType,
      defaultAvatarId: defaultAvatarId ?? this.defaultAvatarId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      fcmTokens: fcmTokens ?? this.fcmTokens,
      groupIds: groupIds ?? this.groupIds,
    );
  }
}
