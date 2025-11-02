import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;
  final String userId;

  const Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'userId': userId,
    };
  }

  factory Task.fromJson(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      userId: map['userId'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted, userId];
}
