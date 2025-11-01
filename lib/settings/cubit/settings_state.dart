part of 'settings_cubit.dart';

// A single state class to hold our settings values
class SettingsState extends Equatable {
  final int workDuration;
  final int breakDuration;

  const SettingsState({
    this.workDuration = 25, // Default value
    this.breakDuration = 5,   // Default value
  });

  // copyWith allows us to create a new state with modified values
  SettingsState copyWith({
    int? workDuration,
    int? breakDuration,
  }) {
    return SettingsState(
      workDuration: workDuration ?? this.workDuration,
      breakDuration: breakDuration ?? this.breakDuration,
    );
  }

  @override
  List<Object> get props => [workDuration, breakDuration];
}