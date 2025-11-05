part of 'audio_cubit.dart';

enum AudioStatus { playing, stopped }

class AudioState extends Equatable {
  const AudioState({
    this.status = AudioStatus.stopped,
    this.currentSound = '',
  });

  final AudioStatus status;
  final String currentSound; // e.g., 'rain.mp3'

  @override
  List<Object> get props => [status, currentSound];

  AudioState copyWith({
    AudioStatus? status,
    String? currentSound,
  }) {
    return AudioState(
      status: status ?? this.status,
      currentSound: currentSound ?? this.currentSound,
    );
  }
}