part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class AddTask extends TaskEvent {
  final String title;

  const AddTask(this.title);

  @override
  List<Object> get props => [title];
}

class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class _TasksUpdated extends TaskEvent {
  final List<Task> tasks;

  const _TasksUpdated(this.tasks);

  @override
  List<Object> get props => [tasks];
}
