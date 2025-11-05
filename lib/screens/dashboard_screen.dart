import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/analytics/cubit/analytics_cubit.dart';
import 'package:focus_flow/history/bloc/history_bloc.dart';
import 'package:focus_flow/repositories/session_repository.dart';
import 'package:focus_flow/screens/history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          // We embed the HistoryView, which is fine for now.
          const Expanded(child: HistoryView()),
        ],
      ),
    );
  }

  Widget _buildAnalyticsHeader(BuildContext context) {
    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (context, state) {
        if (state.status != AnalyticsStatus.success) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ));
        }

        // We have stats, show them
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Use Expanded to make cards fill the space
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Sessions Today',
                  value: state.totalSessionsToday.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16), // Add spacing
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Minutes Today',
                  value: state.totalFocusTimeToday.toString(),
                  icon: Icons.timer,
                  color: Colors.blue,
                ),
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
    final theme = Theme.of(context);
    
    // Use the CardTheme we defined in main.dart
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              // Use the theme's text style
              style: theme.textTheme.headlineMedium,
            ),
            // Use the theme's body text style
            Text(title, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}