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
  int _initialWorkDuration = 25 * 60;
  int _initialBreakDuration = 5 * 60;

  static const int _tickDuration = 1;
  Stream<int> _tick() {
    return Stream.periodic(const Duration(seconds: _tickDuration), (x) => x);
  }

  TimerBloc({
    SettingsService? settingsService,
    required SessionRepository sessionRepository,
  }) : _settingsService = settingsService ?? SettingsService(),
       _sessionRepository = sessionRepository,
       super(TimerState(duration: 25 * 60)) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<_TimerTicked>(_onTicked);

    _loadDuration();
  }

  Future<void> _loadDuration() async {
    _initialWorkDuration = (await _settingsService.getWorkDuration()) * 60;
    _initialBreakDuration = (await _settingsService.getBreakDuration()) * 60;
    if (state.pomodoroStatus == PomodoroStatus.work) {
      add(TimerReset());
    }
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
    emit(
      TimerState(
        status: TimerStatus.initial,
        pomodoroStatus: PomodoroStatus.work,
        duration: _initialWorkDuration,
      ),
    );
  }

  // CORRECTED _onTicked METHOD
void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
    if (event.duration > 0) {
      emit(state.copyWith(duration: event.duration));
      } else {
       // Timer finished
       _tickerSubscription?.cancel();

        if (state.pomodoroStatus == PomodoroStatus.work) {
         // --- WORK FINISHED ---
         // 1. Log the completed work session
         _logSession(_initialWorkDuration);

         // 2. Emit a new state to prepare for the break
         emit(state.copyWith(
           pomodoroStatus: PomodoroStatus.breakTime,
           duration: _initialBreakDuration,
         ));

         // 3. Automatically start the break timer
         add(const TimerStarted());

       } else {
         // --- BREAK FINISHED ---
         // 1. Emit a new state to prepare for work
         emit(state.copyWith(
           pomodoroStatus: PomodoroStatus.work,
           duration: _initialWorkDuration,
         ));

         // 2. Automatically start the work timer
         add(const TimerStarted());
       }
     }
   }

  Future<void> _logSession(int durationInSeconds) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final session = Session(
      id: const Uuid().v4(),
      userId: userId,
      timestamp: DateTime.now(),
      durationInSeconds: durationInSeconds,
    );

    try {
      await _sessionRepository.addSession(session);
    } catch (e) {
      print("error Logging session: $e");
    }
  }
}
