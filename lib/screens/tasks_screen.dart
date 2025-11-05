import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/models/task_model.dart';
import 'package:focus_flow/repositories/task_repository.dart';
import 'package:focus_flow/tasks/bloc/task_bloc.dart';
import 'package:iconsax/iconsax.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskBloc(
        taskRepository: RepositoryProvider.of<TaskRepository>(context),
      ),
      child: const TasksView(),
    );
  }
}

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    final title = _taskController.text.trim();
    if (title.isNotEmpty) {
      context.read<TaskBloc>().add(AddTask(title));
      _taskController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'Add a new task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTask,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state.status == TaskStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == TaskStatus.success) {
                  if (state.tasks.isEmpty) {
                    return const Center(child: Text('No tasks yet.'));
                  }

                  return ListView.builder(
                    itemCount: state.tasks.length,
                    itemBuilder: (context, index) {
                      final task = state.tasks[index];

                      return Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.endToStart,

                        onDismissed: (direction) {
                          context.read<TaskBloc>().add(DeleteTask(task.id));

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${task.title} deleted' ))
                            );
                        },

                        background:Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal:20 ),
                          child: const Icon(Iconsax.profile_delete, color: Colors.white),
                        ) ,
                        child: CheckboxListTile(
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          value: task.isCompleted,
                          onChanged: (isChecked) {
                            final updatedTask = Task(
                              id: task.id,
                              title: task.title,
                              userId: task.userId,
                              isCompleted: isChecked ?? false,
                            );
                            context.read<TaskBloc>().add(
                              UpdateTask(updatedTask),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('Failed to load tasks.'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
