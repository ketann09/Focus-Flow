part of 'history_bloc.dart';

enum HistoryStatus { initial, loading, success, failure }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.sessions = const <Session>[],
  });

  final HistoryStatus status;
  final List<Session> sessions;

  HistoryState copyWith({
    HistoryStatus? status,
    List<Session>? sessions,
  }) {
    return HistoryState(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
    );
  }

  @override
  List<Object> get props => [status, sessions];
}