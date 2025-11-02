import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/history/bloc/history_bloc.dart';
import 'package:focus_flow/repositories/session_repository.dart';
import 'package:intl/intl.dart'; // We need this for date formatting

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Add 'intl' to your pubspec.yaml and run 'flutter pub get'
    // dependencies:
    //   intl: ^0.19.0
    
    return BlocProvider(
      create: (context) => HistoryBloc(
        sessionRepository: RepositoryProvider.of<SessionRepository>(context),
      )..add(LoadHistory()), // Tell the BLoC to start loading
      child: const HistoryView(),
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state.status == HistoryStatus.loading ||
              state.status == HistoryStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == HistoryStatus.failure) {
            return const Center(child: Text('Failed to load history.'));
          }
          if (state.sessions.isEmpty) {
            return const Center(child: Text('No completed sessions yet.'));
          }

          // We have sessions, let's build the list
          return ListView.builder(
            itemCount: state.sessions.length,
            itemBuilder: (context, index) {
              final session = state.sessions[index];
              
              // Format the duration (e.g., 60s -> 1 min)
              final durationInMinutes =
                  (session.durationInSeconds / 60).floor();
              
              // Format the date (e.g., "Nov 02, 3:45 PM")
              final formattedDate =
                  DateFormat('MMM dd, h:mm a').format(session.timestamp);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    '$durationInMinutes Minute Session',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(formattedDate),
                  leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}