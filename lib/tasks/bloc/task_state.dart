part of 'task_bloc.dart';

enum TaskStatus { initial, loading, success, failure }

class TaskState extends Equatable {
  const TaskState({
    this.status = TaskStatus.initial,
    this.tasks = const <Task>[], 
  });

  final TaskStatus status;
  final List<Task> tasks;

  TaskState copyWith({
    TaskStatus? status,
    List<Task>? tasks,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  List<Object> get props => [status, tasks];
}