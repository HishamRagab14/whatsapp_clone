import 'dart:io';

abstract class IVoiceRecorderService {
  Future<void> startRecording();
  Future<File?> stopRecording();
  Future<bool> isRecording();
  void dispose();
  
  // Getters
  String get formattedDuration;
} 