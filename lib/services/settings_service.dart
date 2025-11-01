import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _workDurationKey = 'workDuration';
  static const String _breakDurationKey = 'breakDuration';

  
  Future<int> getWorkDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_workDurationKey) ?? 25; 
  }

  Future<int> getBreakDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_breakDurationKey) ?? 5;
  }


  Future<void> setWorkDuration(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_workDurationKey, minutes);
  }

  Future<void> setBreakDuration(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_breakDurationKey, minutes);
  }
}