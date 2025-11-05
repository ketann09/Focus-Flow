import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:focus_flow/models/session_model.dart';
import 'package:focus_flow/repositories/session_repository.dart';
import 'package:flutter/material.dart'; 

part 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final SessionRepository _sessionRepository;
  StreamSubscription? _sessionSubscription;

  AnalyticsCubit({required SessionRepository sessionRepository})
      : _sessionRepository = sessionRepository,
        super(const AnalyticsState()) {
    _listenToSessions();
  }

  void _listenToSessions() {
    emit(state.copyWith(status: AnalyticsStatus.loading));
    _sessionSubscription = _sessionRepository.getSessions().listen(
      (sessions) {
        _calculateStats(sessions);
      },
      onError: (_) => emit(state.copyWith(status: AnalyticsStatus.failure)),
    );
  }

  void _calculateStats(List<Session> sessions) {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);

    int timeToday = 0;
    int sessionsToday = 0;

    for (final session in sessions) {
      final sessionDate = DateUtils.dateOnly(session.timestamp);
      
      if (sessionDate.isAtSameMomentAs(today)) {
        timeToday += session.durationInSeconds;
        sessionsToday++;
      }
    }

    emit(state.copyWith(
      status: AnalyticsStatus.success,
      totalSessionsToday: sessionsToday,
      totalFocusTimeToday: (timeToday / 60).floor(), 
    ));
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    return super.close();
  }
}