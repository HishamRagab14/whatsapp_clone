import 'package:get/get.dart';

abstract class IAudioPlayerService {
  Future<void> playAudio(String audioUrl);
  Future<void> pauseAudio();
  Future<void> resumeAudio();
  Future<void> stopAudio();
  Future<void> seekToProgress(double progress);
  void dispose();
  
  // Getters
  RxBool get isPlaying;
  RxString get currentAudioUrl;
  RxDouble get progress;
  RxString get currentTime;
  RxString get totalDuration;
} 