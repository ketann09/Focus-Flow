part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final int workDuration;
  final int breakDuration;

  const SettingsState({
    this.workDuration = 25, 
    this.breakDuration = 5,  
  });

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