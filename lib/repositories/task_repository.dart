import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_flow/models/task_model.dart';

class TaskRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<Task>> getTasks() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Stream.value([]);
    }

    return _db
        .collection('tasks')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Task.fromJson(doc.data());
          }).toList();
        });
  }

  Future<void> addTask(String title) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return;
    }
    final newDocRef = _db.collection('tasks').doc();

    final Task newTask = Task(
      id: newDocRef.id,
      title: title,
      isCompleted: false,
      userId: uid,
    );

    await newDocRef.set(newTask.toJson());
  }

  Future<void> updateTask(Task task) async {
    final String id = task.id;

    if (id.isEmpty) {
      return;
    }

    await _db.collection('tasks').doc(id).update(task.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || taskId.isEmpty) {
      return;
    }
    await _db.collection('tasks').doc(taskId).delete();
  }
}
