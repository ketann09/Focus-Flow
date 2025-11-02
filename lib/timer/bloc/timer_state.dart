part of 'timer_bloc.dart';

enum TimerStatus { initial, running, paused, finished }

class TimerState extends Equatable {
  const TimerState({
    this.status = TimerStatus.initial,
    this.duration = 0, 
  });

  final TimerStatus status;
  final int duration; 
  TimerState copyWith({
    TimerStatus? status,
    int? duration,
  }) {
    return TimerState(
      status: status ?? this.status,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object> get props => [status, duration];
}