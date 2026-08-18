import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../domain/notification_preferences.dart';

abstract class NotificationRepository {
  Future<void> saveFcmToken(String uid);
  Future<void> updatePreferences(
      String uid, String groupId, NotificationPreferences prefs);
  Future<NotificationPreferences> getPreferences(String uid, String groupId);
  Stream<NotificationPreferences> watchPreferences(String uid, String groupId);
}

class FirestoreNotificationRepository implements NotificationRepository {
  FirestoreNotificationRepository(this._firestore, this._messaging);

  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  @override
  Future<void> saveFcmToken(String uid) async {
    final token = await _messaging.getToken();
    if (token == null) return;
    await _firestore.collection('users').doc(uid).update({
      'fcm_tokens': FieldValue.arrayUnion([token]),
    });
  }

  @override
  Future<void> updatePreferences(
      String uid, String groupId, NotificationPreferences prefs) async {
    await _firestore
        .collection('notification_prefs')
        .doc(uid)
        .collection('groups')
        .doc(groupId)
        .set(prefs.toMap());
  }

  @override
  Future<NotificationPreferences> getPreferences(
      String uid, String groupId) async {
    final doc = await _firestore
        .collection('notification_prefs')
        .doc(uid)
        .collection('groups')
        .doc(groupId)
        .get();
    if (!doc.exists) return const NotificationPreferences();
    return NotificationPreferences.fromMap(
        doc.data() as Map<String, dynamic>);
  }

  @override
  Stream<NotificationPreferences> watchPreferences(
      String uid, String groupId) {
    return _firestore
        .collection('notification_prefs')
        .doc(uid)
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return const NotificationPreferences();
      return NotificationPreferences.fromMap(
          doc.data() as Map<String, dynamic>);
    });
  }
}
