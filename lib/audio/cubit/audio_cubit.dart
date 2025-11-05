import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  // Create our single audio player instance
  final AudioPlayer _audioPlayer;

  AudioCubit()
      : _audioPlayer = AudioPlayer(),
        super(const AudioState());

  Future<void> playSound(String soundAsset) async {
    // If it's the same sound and already playing, do nothing
    if (state.status == AudioStatus.playing && state.currentSound == soundAsset) {
      return;
    }
    
    // Stop any previous sound
    await stopSound();

    // Set the source and loop it
    await _audioPlayer.setSource(AssetSource('audio/$soundAsset'));
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    
    // Start playing
    await _audioPlayer.resume();

    // Emit the new state
    emit(state.copyWith(
      status: AudioStatus.playing,
      currentSound: soundAsset,
    ));
  }

  Future<void> stopSound() async {
    await _audioPlayer.stop();
    emit(state.copyWith(
      status: AudioStatus.stopped,
      currentSound: '',
    ));
  }

  // Toggles a sound on or off
  Future<void> toggleSound(String soundAsset) async {
    if (state.status == AudioStatus.playing && state.currentSound == soundAsset) {
      // It's this sound, stop it
      await stopSound();
    } else {
      // It's a new sound (or no sound), play it
      await playSound(soundAsset);
    }
  }

  // Make sure we stop the player when the BLoC is closed
  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}