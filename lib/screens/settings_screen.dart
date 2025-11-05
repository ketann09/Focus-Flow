import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/settings/cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit()..loadSettings(),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final TextEditingController _workController;
  late final TextEditingController _breakController;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<SettingsCubit>().state;
    _workController =
        TextEditingController(text: currentState.workDuration.toString());
    _breakController =
        TextEditingController(text: currentState.breakDuration.toString());
  }

  @override
  void dispose() {
    _workController.dispose();
    _breakController.dispose();
    super.dispose();
  }

  void _saveWorkDuration() {
    final duration = int.tryParse(_workController.text);
    if (duration != null && duration > 0) {
      context.read<SettingsCubit>().setWorkDuration(duration);
      FocusScope.of(context).unfocus(); // Dismiss the keyboard
    }
  }

  void _saveBreakDuration() {
    final duration = int.tryParse(_breakController.text);
    if (duration != null && duration > 0) {
      context.read<SettingsCubit>().setBreakDuration(duration);
      FocusScope.of(context).unfocus(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (_workController.text != state.workDuration.toString()) {
          _workController.text = state.workDuration.toString();
        }
        if (_breakController.text != state.breakDuration.toString()) {
          _breakController.text = state.breakDuration.toString();
        }
      },
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Timer Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Work Duration (minutes)'),
              trailing: SizedBox(
                width: 80,
                child: TextField(
                  controller: _workController, 
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onEditingComplete: _saveWorkDuration,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Break Duration (minutes)'),
              trailing: SizedBox(
                width: 80,
                child: TextField(
                  controller: _breakController, 
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onEditingComplete: _saveBreakDuration,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}