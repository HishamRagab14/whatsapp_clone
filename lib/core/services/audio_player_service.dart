import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:whatsapp_clone/core/interfaces/audio_service_interface.dart';

class AudioPlayerService implements IAudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  @override
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  @override
  final RxDouble progress = 0.0.obs;
  @override
  final RxString currentTime = '0:00'.obs;
  @override
  final RxString totalDuration = '0:00'.obs;
  @override
  final RxString currentAudioUrl = ''.obs;

  Timer? _progressTimer;
  Duration? _totalDuration;

  AudioPlayerService() {
    _setupListeners();
  }

  void _setupListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;

      if (state == PlayerState.playing) {
        _startProgressTimer();
      } else if (state == PlayerState.stopped ||
          state == PlayerState.completed) {
        progress.value = 0.0;
        currentTime.value = '0:00';
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      isPlaying.value = false;
      progress.value = 0.0;
      currentTime.value = '0:00';
      _stopProgressTimer();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      totalDuration.value = _formatDuration(duration);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (_totalDuration != null && _totalDuration!.inMilliseconds > 0) {
        final newProgress =
            position.inMilliseconds / _totalDuration!.inMilliseconds;
        progress.value = newProgress.clamp(0.0, 1.0);
        currentTime.value = _formatDuration(position);
      }
    });
  }

  void _startProgressTimer() {
    _stopProgressTimer();
    _progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (isPlaying.value && _totalDuration != null) {
        _audioPlayer.getCurrentPosition().then((position) {
          if (position != null && _totalDuration!.inMilliseconds > 0) {
            final newProgress =
                position.inMilliseconds / _totalDuration!.inMilliseconds;
            progress.value = newProgress.clamp(0.0, 1.0);
            currentTime.value = _formatDuration(position);
          }
        });
      }
    });
  }

  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> playAudio(String audioUrl) async {
    try {
      if (audioUrl.isEmpty) {
        throw Exception('Audio URL is empty');
      }

      if (isPlaying.value) {
        await stopAudio();
        await Future.delayed(Duration(milliseconds: 200));
      }

      isLoading.value = true;
      currentAudioUrl.value = audioUrl;

      await _audioPlayer.play(UrlSource(audioUrl));

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  @override
  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      // ignore: empty_catches
    }
  }

  @override
  Future<void> resumeAudio() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      // ignore: empty_catches
    }
  }

  @override
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      isPlaying.value = false;
      progress.value = 0.0;
      currentTime.value = '0:00';
      _stopProgressTimer();
    } catch (e) {
      // ignore: empty_catches
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      // ignore: empty_catches
    }
  }

  @override
  Future<void> seekToProgress(double progressValue) async {
    try {
      if (_totalDuration != null) {
        final position = Duration(
          milliseconds:
              (_totalDuration!.inMilliseconds * progressValue).round(),
        );
        await seekTo(position);
      }
    } catch (e) {
      // ignore: empty_catches
    }
  }

  Future<Duration?> getCurrentPosition() async {
    try {
      return await _audioPlayer.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  Future<Duration?> getDuration() async {
    try {
      return await _audioPlayer.getDuration();
    } catch (e) {
      return null;
    }
  }

  bool get isCurrentlyPlaying => isPlaying.value;
  double get currentProgress => progress.value;
  String get formattedCurrentTime => currentTime.value;
  String get formattedTotalDuration => totalDuration.value;

  @override
  void dispose() {
    _stopProgressTimer();
    _audioPlayer.dispose();
  }
}
