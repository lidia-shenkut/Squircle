import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String groupId;
  final String name;
  final String? iconUrl;
  final String adminUid;
  final List<String> memberUids;
  final String inviteCode;
  final bool inviteLinkActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int xp;
  final int groupStreak;
  final DateTime? groupStreakLastActive;

  const GroupModel({
    required this.groupId,
    required this.name,
    this.iconUrl,
    required this.adminUid,
    required this.memberUids,
    required this.inviteCode,
    this.inviteLinkActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.xp = 0,
    this.groupStreak = 0,
    this.groupStreakLastActive,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      groupId: doc.id,
      name: data['name'] as String? ?? '',
      iconUrl: data['icon_url'] as String?,
      adminUid: data['admin_uid'] as String? ?? '',
      memberUids: List<String>.from(data['member_uids'] ?? []),
      inviteCode: data['invite_code'] as String? ?? '',
      inviteLinkActive: data['invite_link_active'] as bool? ?? true,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      xp: data['xp'] as int? ?? 0,
      groupStreak: data['group_streak'] as int? ?? 0,
      groupStreakLastActive:
          (data['group_streak_last_active'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'group_id': groupId,
      'name': name,
      'icon_url': iconUrl,
      'admin_uid': adminUid,
      'member_uids': memberUids,
      'invite_code': inviteCode,
      'invite_link_active': inviteLinkActive,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'xp': xp,
      'group_streak': groupStreak,
      'group_streak_last_active': groupStreakLastActive != null
          ? Timestamp.fromDate(groupStreakLastActive!)
          : null,
    };
  }

  GroupModel copyWith({
    String? name,
    String? iconUrl,
    List<String>? memberUids,
    String? inviteCode,
    bool? inviteLinkActive,
    int? xp,
    int? groupStreak,
  }) {
    return GroupModel(
      groupId: groupId,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      adminUid: adminUid,
      memberUids: memberUids ?? this.memberUids,
      inviteCode: inviteCode ?? this.inviteCode,
      inviteLinkActive: inviteLinkActive ?? this.inviteLinkActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      xp: xp ?? this.xp,
      groupStreak: groupStreak ?? this.groupStreak,
      groupStreakLastActive: groupStreakLastActive,
    );
  }
}
