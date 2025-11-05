part of 'timer_bloc.dart';

enum PomodoroStatus{work,breakTime}

enum TimerStatus { initial, running, paused, finished }

class TimerState extends Equatable {
  const TimerState({
    this.status = TimerStatus.initial,
    this.pomodoroStatus=PomodoroStatus.work,
    this.duration = 0, 
  });

  final TimerStatus status;
  final int duration; 
  final PomodoroStatus pomodoroStatus;
  TimerState copyWith({
    TimerStatus? status,
    PomodoroStatus? pomodoroStatus,
    int? duration,
  }) {
    return TimerState(
      status: status ?? this.status,
      pomodoroStatus: pomodoroStatus??this.pomodoroStatus,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object> get props => [status,pomodoroStatus, duration];
}