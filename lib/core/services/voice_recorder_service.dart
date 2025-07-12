import 'dart:io' show File;
import 'dart:io' show Platform;
import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/core/interfaces/voice_recorder_interface.dart';

class VoiceRecorderService implements IVoiceRecorderService {
  final AudioRecorder audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;
  Timer? _recordingTimer;
  int _recordingDuration = 0; // بالثواني

  int get recordingDuration => _recordingDuration;
  @override
  String get formattedDuration {
    final minutes = _recordingDuration ~/ 60;
    final seconds = _recordingDuration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // التحقق من أن الجهاز محاكي
  bool get _isEmulator {
    if (Platform.isAndroid) {
      try {
        // التحقق من علامات المحاكي
        final buildFingerprint =
            Platform.environment['ro.build.fingerprint'] ?? '';
        final buildModel = Platform.environment['ro.product.model'] ?? '';
        final buildProduct = Platform.environment['ro.product.name'] ?? '';

        return buildFingerprint.contains('sdk') ||
            buildModel.contains('sdk') ||
            buildModel.contains('google_sdk') ||
            buildModel.contains('Emulator') ||
            buildModel.contains('Android SDK') ||
            buildProduct.contains('sdk') ||
            buildProduct.contains('google_sdk');
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<bool> _requestPermission() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  /// بدء التسجيل الصوتي
  @override
  Future<void> startRecording() async {
    try {
      if (_isRecording) {
        return;
      }

      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        Get.snackbar(
          'Permission Required',
          'Microphone permission is required to record voice messages.',
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
        );
        throw Exception('Microphone permission not granted');
      }

      final directory = await getTemporaryDirectory();
      _currentRecordingPath =
          '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      final recorderHasPermission = await audioRecorder.hasPermission();
      if (!recorderHasPermission) {
        Get.snackbar(
          'Permission Required',
          'Audio recording permission is required.',
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
        );
        throw Exception('Audio recorder permission not granted');
      }

      final config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
      );

      await audioRecorder.start(config, path: _currentRecordingPath!);
      _isRecording = true;
      _recordingDuration = 0;

      _startRecordingTimer();
    } catch (e) {
      _isRecording = false;
      _currentRecordingPath = null;
      rethrow;
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isRecording) {
        _recordingDuration++;
      } else {
        timer.cancel();
      }
    });
  }

  /// إيقاف التسجيل الصوتي
  @override
  Future<File?> stopRecording() async {
    try {
      if (!_isRecording) {
        return null;
      }

      final isStillRecording = await audioRecorder.isRecording();
      if (!isStillRecording) {
        _isRecording = false;
        _stopRecordingTimer();
        return null;
      }

      final path = await audioRecorder.stop();
      _isRecording = false;
      _stopRecordingTimer();

      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final fileSize = await file.length();
          if (fileSize > 0) {
            return file;
          } else {
            Get.snackbar(
              'Recording Failed',
              'Voice recording is empty. Please try again.',
              duration: Duration(seconds: 3),
              snackPosition: SnackPosition.BOTTOM,
            );
            return null;
          }
        } else {
          Get.snackbar(
            'Recording Failed',
            'Voice recording file not found. Please try again.',
            duration: Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Recording Failed',
          'Voice recording failed. Please try again.',
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return null;
    } catch (e) {
      _isRecording = false;
      _stopRecordingTimer();
      Get.snackbar(
        'Recording Error',
        'Failed to stop recording: $e',
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      _currentRecordingPath = null;
    }
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  /// التحقق من حالة التسجيل
  @override
  Future<bool> isRecording() async {
    try {
      final recording = await audioRecorder.isRecording();
      return recording;
    } catch (e) {
      return false;
    }
  }

  /// التحقق من أن الجهاز محاكي
  bool get isEmulator => _isEmulator;

  /// تنظيف الموارد
  @override
  void dispose() {
    try {
      _stopRecordingTimer();
      if (_isRecording) {
        audioRecorder.stop();
        _isRecording = false;
      }
    } catch (e) {
      // Error during dispose: $e
    }
  }

  /// الحصول على مسار التسجيل الحالي
  String? get currentRecordingPath => _currentRecordingPath;

  Future<void> recordAudioStatus() async {
    try {
      // هنا سيتم إضافة منطق تسجيل الصوت
      // يمكن استخدام flutter_sound أو أي مكتبة أخرى
      Get.snackbar('Info', 'Audio recording feature coming soon!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to record audio: $e');
    }
  }
}
