import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:focus_flow/models/session_model.dart';
import 'package:focus_flow/repositories/session_repository.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final SessionRepository _sessionRepository;
  StreamSubscription? _historySubscription;

  HistoryBloc({required SessionRepository sessionRepository})
      : _sessionRepository = sessionRepository,
        super(const HistoryState()) {
    
    // When LoadHistory is added, set state to loading
    on<LoadHistory>((event, emit) {
      emit(state.copyWith(status: HistoryStatus.loading));
      
      // Cancel any old subscription
      _historySubscription?.cancel();
      
      // Start listening to the repository stream
      _historySubscription = _sessionRepository.getSessions().listen(
        (sessions) {
          // When data arrives, add the internal event
          add(_HistoryUpdated(sessions));
        },
      );
    });

    // When new data arrives, update the state to success
    on<_HistoryUpdated>((event, emit) {
      emit(state.copyWith(
        status: HistoryStatus.success,
        sessions: event.sessions,
      ));
    });
  }

  @override
  Future<void> close() {
    _historySubscription?.cancel();
    return super.close();
  }
}