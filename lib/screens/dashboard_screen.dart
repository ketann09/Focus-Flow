import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/analytics/cubit/analytics_cubit.dart';
import 'package:focus_flow/history/bloc/history_bloc.dart';
import 'package:focus_flow/repositories/session_repository.dart';
import 'package:focus_flow/screens/history_screen.dart'; // We'll reuse this!

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We'll provide both BLoCs needed for this screen
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AnalyticsCubit(
            sessionRepository: RepositoryProvider.of<SessionRepository>(context),
          ),
        ),
        BlocProvider(
          create: (context) => HistoryBloc(
            sessionRepository: RepositoryProvider.of<SessionRepository>(context),
          )..add(LoadHistory()),
        ),
      ],
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Analytics Header ---
          _buildAnalyticsHeader(context),
          
          // --- 2. History List ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Recent Sessions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          // We'll reuse the HistoryView, but only its list part.
          // For simplicity, we just embed the whole HistoryView for now.
          const Expanded(child: HistoryView()),
        ],
      ),
    );
  }

  Widget _buildAnalyticsHeader(BuildContext context) {
    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (context, state) {
        if (state.status != AnalyticsStatus.success) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // We have stats, show them
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                context,
                title: 'Sessions Today',
                value: state.totalSessionsToday.toString(),
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
              _buildStatCard(
                context,
                title: 'Minutes Today',
                value: state.totalFocusTimeToday.toString(),
                icon: Icons.timer,
                color: Colors.blue,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}