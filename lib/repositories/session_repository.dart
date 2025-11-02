import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_flow/models/session_model.dart';

class SessionRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<Session>> getSessions() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Stream.value([]);
    }

    return _db
        .collection('sessions')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true) 
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Session.fromJson(doc.data());
      }).toList();
    });
  }

  Future<void> addSession(Session session) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid != session.userId) {
      return; 
    }

    await _db
        .collection('sessions')
        .doc(session.id)
        .set(session.toJson());
  }
}