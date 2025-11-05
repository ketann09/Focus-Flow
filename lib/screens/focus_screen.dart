import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow/repositories/session_repository.dart';
import 'package:focus_flow/timer/bloc/timer_bloc.dart';
import 'package:focus_flow/audio/cubit/audio_cubit.dart';
import 'package:focus_flow/widgets/timer_painter.dart';
import 'dart:math'; // Import this for pi

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
    final theme = Theme.of(context);

    // This selects the BLoC
    final timerBloc = context.watch<TimerBloc>();
    final timerState = timerBloc.state;

    // This gets the correct starting duration (work or break)
    final int initialDuration =
        (timerState.pomodoroStatus == PomodoroStatus.work
                ? timerBloc.initialWorkDuration
                : timerBloc.initialBreakDuration)
            .clamp(1, 100000); // ensure it's not zero

    final duration = timerState.duration;
    final status = timerState.status;
    final pomodoroStatus = timerState.pomodoroStatus;

    // Calculate progress from 0.0 to 1.0
    final double progress = (duration / initialDuration);

    return Scaffold(
      // 1. Wrap the entire body in SafeArea
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- AMBIENT SOUNDS (SECTION 1) ---
            Expanded(
              flex: 1, // Give this section a flex of 1
              child: BlocBuilder<AudioCubit, AudioState>(
                builder: (context, audioState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.water_drop,
                          color: audioState.currentSound == 'rain.mp3' &&
                                  audioState.status == AudioStatus.playing
                              ? theme.primaryColor
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
                              ? theme.primaryColor
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
            ),

            // --- NEW TIMER WIDGET (SECTION 2) ---
            Expanded(
              flex: 4, // Give the timer a larger flex of 4
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: AspectRatio(
                  aspectRatio: 1.0, // Force 1:1 square
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // The custom painter
                      SizedBox.expand(
                        child: CustomPaint(
                          painter: TimerPainter(
                            progress: progress,
                            foregroundColor: theme.primaryColor,
                            backgroundColor:
                                theme.scaffoldBackgroundColor.computeLuminance() >
                                        0.5
                                    ? Colors.white
                                    : Colors.grey[800]!,
                          ),
                        ),
                      ),
                      // The text inside
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatDuration(duration),
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: min(
                                  MediaQuery.of(context).size.width * 0.2, 80),
                            ),
                          ),
                          Text(
                            pomodoroStatus == PomodoroStatus.work
                                ? 'Focus Time'
                                : 'Break Time',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- ACTION BUTTONS (SECTION 3) ---
            Expanded(
              flex: 2, // Give the buttons a flex of 2
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (status == TimerStatus.running ||
                      status == TimerStatus.paused)
                    FloatingActionButton(
                      onPressed: () =>
                          context.read<TimerBloc>().add(TimerReset()),
                      backgroundColor: Colors.white,
                      foregroundColor: theme.textTheme.bodyMedium?.color,
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
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    child: Icon(
                      (status == TimerStatus.running)
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 40,
                    ),
                  ),
                  if (status == TimerStatus.running ||
                      status == TimerStatus.paused)
                    const SizedBox(width: 56), // 56 is FAB size
                  if (status == TimerStatus.finished)
                    FloatingActionButton(
                      onPressed: () =>
                          context.read<TimerBloc>().add(TimerReset()),
                      backgroundColor: Colors.white,
                      foregroundColor: theme.textTheme.bodyMedium?.color,
                      child: const Icon(Icons.refresh),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}