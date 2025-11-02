import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:focus_flow/models/task_model.dart';
import 'package:focus_flow/repositories/task_repository.dart';
part   'task_event.dart';
part   'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  StreamSubscription? _taskSubscription; 

  TaskBloc({required TaskRepository taskRepository})
      : _taskRepository = taskRepository,
        super(const TaskState()) { 
    
    
    on<AddTask>(_onAddTask);

    on<UpdateTask>(_onUpdateTask);
    
    on<_TasksUpdated>(_onTasksUpdated);

    _taskSubscription = _taskRepository.getTasks().listen(
      (tasks) {
        add(_TasksUpdated(tasks));
      },
    );
  }

  
  void _onAddTask(AddTask event, Emitter<TaskState> emit) {
    _taskRepository.addTask(event.title);
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) {
    _taskRepository.updateTask(event.task);
  }

  void _onTasksUpdated(_TasksUpdated event, Emitter<TaskState> emit) {
    emit(state.copyWith(
      status: TaskStatus.success,
      tasks: event.tasks,
    ));
  }

  @override
  Future<void> close() {
    _taskSubscription?.cancel();
    return super.close();
  }
}