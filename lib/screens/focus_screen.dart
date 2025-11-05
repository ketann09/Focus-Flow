import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/repositories/session_repository.dart';
import 'package:focus_flow/timer/bloc/timer_bloc.dart';
import 'package:focus_flow/audio/cubit/audio_cubit.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TimerBloc(
            sessionRepository: RepositoryProvider.of<SessionRepository>(context),
          )..add(TimerReset()),
        ),
        BlocProvider(
          create: (context) => AudioCubit(),
        ),
      ],
      child: BlocListener<TimerBloc, TimerState>(
        listener: (context, state) {
          if (state.status == TimerStatus.paused ||
              state.status == TimerStatus.initial) {
            context.read<AudioCubit>().stopSound();
          }
        },
        child: const FocusView(),
      ),
    );
  }
}

class FocusView extends StatelessWidget {
  const FocusView({super.key});

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TimerBloc, TimerState>(
        builder: (context, timerState) {
          final duration = timerState.duration;
          final status = timerState.status;
          final pomodoroStatus = timerState.pomodoroStatus;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BlocBuilder<AudioCubit, AudioState>(
                builder: (context, audioState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.water_drop,
                          color: audioState.currentSound == 'rain.mp3' &&
                                 audioState.status == AudioStatus.playing
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                        onPressed: () {
                          context.read<AudioCubit>().toggleSound('rain.mp3');
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.coffee,
                          color: audioState.currentSound == 'cafe.mp3' &&
                                 audioState.status == AudioStatus.playing
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                        onPressed: () {
                          context.read<AudioCubit>().toggleSound('cafe.mp3');
                        },
                      ),
                    ],
                  );
                },
              ),
              Center(
                child: Text(
                  pomodoroStatus == PomodoroStatus.work
                      ? 'Focus Time'
                      : 'Break Time',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _formatDuration(duration),
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (status == TimerStatus.running ||
                      status == TimerStatus.paused)
                    FloatingActionButton(
                      onPressed: () =>
                          context.read<TimerBloc>().add(TimerReset()),
                      child: const Icon(Icons.refresh),
                    ),
                  FloatingActionButton.large(
                    onPressed: () {
                      switch (status) {
                        case TimerStatus.initial:
                        case TimerStatus.finished:
                          context.read<TimerBloc>().add(const TimerStarted());
                          break;
                        case TimerStatus.running:
                          context.read<TimerBloc>().add(const TimerPaused());
                          break;
                        case TimerStatus.paused:
                          context.read<TimerBloc>().add(const TimerResumed());
                          break;
                      }
                    },
                    child: Icon(
                      (status == TimerStatus.running)
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 40,
                    ),
                  ),
                  if (status == TimerStatus.running ||
                      status == TimerStatus.paused)
                    const SizedBox(width: 56),
                  if (status == TimerStatus.finished)
                    FloatingActionButton(
                      onPressed: () =>
                          context.read<TimerBloc>().add(TimerReset()),
                      child: const Icon(Icons.refresh),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}