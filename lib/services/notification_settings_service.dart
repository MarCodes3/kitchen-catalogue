import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationSettingsService {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> updateSettings(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('settings')
      .doc('notifications')
      .set(data, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>> getSettings() {
    return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('settings')
      .doc('notifications')
      .snapshots()
      .map((doc) => doc.data() ?? {});
  }
}
