part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadHistory extends HistoryEvent {}

class _HistoryUpdated extends HistoryEvent {
  final List<Session> sessions;

  const _HistoryUpdated(this.sessions);

  @override
  List<Object> get props => [sessions];
}