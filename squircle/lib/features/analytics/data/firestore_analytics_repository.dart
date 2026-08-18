import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/group_analytics.dart';

abstract class AnalyticsRepository {
  Stream<GroupAnalytics?> watchGroupAnalytics(String groupId);
}

class FirestoreAnalyticsRepository implements AnalyticsRepository {
  FirestoreAnalyticsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<GroupAnalytics?> watchGroupAnalytics(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('analytics')
        .doc('summary')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return GroupAnalytics.fromFirestore(doc);
    });
  }
}
