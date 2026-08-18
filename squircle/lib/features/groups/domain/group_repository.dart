import 'group_model.dart';

abstract class GroupRepository {
  Future<String> createGroup(GroupModel group);
  Future<void> updateGroup(String groupId, Map<String, dynamic> fields);
  Future<void> joinGroupByCode(String inviteCode, String uid);
  Future<void> joinGroupByLink(String groupId, String uid);
  Future<String> generateInviteCode(String groupId);
  Future<void> revokeInviteCode(String groupId);
  Future<void> inviteByEmail(String groupId, String email);
  Future<void> removeMember(String groupId, String uid);
  Stream<List<GroupModel>> watchUserGroups(String uid);
  Stream<GroupModel> watchGroup(String groupId);
  Future<GroupModel?> getGroup(String groupId);
}
