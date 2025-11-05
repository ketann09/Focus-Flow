part of 'analytics_cubit.dart';

enum AnalyticsStatus { initial, loading, success, failure }

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.totalFocusTimeToday = 0,
    this.totalSessionsToday = 0,
  });

  final AnalyticsStatus status;
  final int totalFocusTimeToday; 
  final int totalSessionsToday;

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    int? totalFocusTimeToday,
    int? totalSessionsToday,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      totalFocusTimeToday:
          totalFocusTimeToday ?? this.totalFocusTimeToday,
      totalSessionsToday: totalSessionsToday ?? this.totalSessionsToday,
    );
  }

  @override
  List<Object> get props => [status, totalFocusTimeToday, totalSessionsToday];
}