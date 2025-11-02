part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

// Event to tell the BLoC to start loading the sessions
class LoadHistory extends HistoryEvent {}

// Internal event (like in TaskBloc) to update the state with new sessions
class _HistoryUpdated extends HistoryEvent {
  final List<Session> sessions;

  const _HistoryUpdated(this.sessions);

  @override
  List<Object> get props => [sessions];
}