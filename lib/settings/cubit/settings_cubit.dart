import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:focus_flow/services/settings_service.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsService _settingsService;

  SettingsCubit({SettingsService? settingsService})
      : _settingsService = settingsService ?? SettingsService(),
        super(const SettingsState());

  Future<void> loadSettings() async {
    final workDuration = await _settingsService.getWorkDuration();
    final breakDuration = await _settingsService.getBreakDuration();
    emit(SettingsState(
      workDuration: workDuration,
      breakDuration: breakDuration,
    ));
  }

  Future<void> setWorkDuration(int duration) async {
    await _settingsService.setWorkDuration(duration);
    emit(state.copyWith(workDuration: duration));
  }

  Future<void> setBreakDuration(int duration) async {
    await _settingsService.setBreakDuration(duration);
    emit(state.copyWith(breakDuration: duration));
  }
}