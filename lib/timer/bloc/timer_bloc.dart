import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:focus_flow/models/session_model.dart';
import 'package:focus_flow/repositories/session_repository.dart';
import 'package:focus_flow/services/settings_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final SettingsService _settingsService;
  final SessionRepository _sessionRepository;
  StreamSubscription<int>? _tickerSubscription;
  int _initialDuration = 25 * 60;

  static const int _tickDuration = 1;
  Stream<int> _tick() {
    return Stream.periodic(const Duration(seconds: _tickDuration), (x) => x);
  }

  TimerBloc({
    SettingsService? settingsService,
    required SessionRepository sessionRepository,
  }) : _settingsService = settingsService ?? SettingsService(),
       _sessionRepository = sessionRepository,
       super(const TimerState()) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<_TimerTicked>(_onTicked);

    _loadInitialDuration();
  }

  Future<void> _loadInitialDuration() async {
    final workMinutes = await _settingsService.getWorkDuration();
    _initialDuration = workMinutes * 60;
    
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(state.copyWith(status: TimerStatus.running));
    _tickerSubscription?.cancel();
    _tickerSubscription = _tick().listen(
      (tick) => add(_TimerTicked(state.duration - _tickDuration)),
    );
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state.status == TimerStatus.running) {
      _tickerSubscription?.pause();
      emit(state.copyWith(status: TimerStatus.paused));
    }
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    if (state.status == TimerStatus.paused) {
      _tickerSubscription?.resume();
      emit(state.copyWith(status: TimerStatus.running));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(TimerState(status: TimerStatus.initial, duration: _initialDuration));
  }

  void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
    if (event.duration > 0) {
      emit(state.copyWith(duration: event.duration));
    } else {
      _tickerSubscription?.cancel();
      emit(state.copyWith(status: TimerStatus.finished));

      _logSession();
    }
  }

  Future<void> _logSession() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final session = Session(
      id: const Uuid().v4(),
      userId: userId,
      timestamp: DateTime.now(),
      durationInSeconds: _initialDuration,
    );

    try {
      await _sessionRepository.addSession(session);
    } catch (e) {
      print("error Logging session");
    }
  }
}
