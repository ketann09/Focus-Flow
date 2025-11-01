import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/settings/cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // The cubit is created here and loads its settings
      create: (context) => SettingsCubit()..loadSettings(),
      child: const SettingsView(),
    );
  }
}

// 1. Converted to a StatefulWidget to manage controllers
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // 2. Created controllers as state variables
  late final TextEditingController _workController;
  late final TextEditingController _breakController;

  @override
  void initState() {
    super.initState();
    // 3. Initialized controllers from the BLoC's *current* state
    //    (This will be the default '25' and '5' at first)
    final currentState = context.read<SettingsCubit>().state;
    _workController =
        TextEditingController(text: currentState.workDuration.toString());
    _breakController =
        TextEditingController(text: currentState.breakDuration.toString());
  }

  @override
  void dispose() {
    // 4. Disposed the controllers
    _workController.dispose();
    _breakController.dispose();
    super.dispose();
  }

  // 5. Created a save function
  void _saveWorkDuration() {
    final duration = int.tryParse(_workController.text);
    if (duration != null && duration > 0) {
      // Tell the cubit to save the new value
      context.read<SettingsCubit>().setWorkDuration(duration);
      FocusScope.of(context).unfocus(); // Dismiss the keyboard
    }
  }

  // 5. Created a save function
  void _saveBreakDuration() {
    final duration = int.tryParse(_breakController.text);
    if (duration != null && duration > 0) {
      // Tell the cubit to save the new value
      context.read<SettingsCubit>().setBreakDuration(duration);
      FocusScope.of(context).unfocus(); // Dismiss the keyboard
    }
  }

  @override
  Widget build(BuildContext context) {
    // 6. Use BlocListener to update text fields when settings *load*
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        // When loadSettings() finishes, this will fire
        // This check prevents a bug where the cursor jumps
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
                  controller: _workController, // Use the state controller
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  // 7. Use onEditingComplete
                  // This fires when the "Done" key is pressed OR
                  // when the text field loses focus (e.g., user taps away)
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
                  controller: _breakController, // Use the state controller
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  // 7. Use onEditingComplete
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