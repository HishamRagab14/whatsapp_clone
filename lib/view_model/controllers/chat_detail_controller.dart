import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_clone/core/interfaces/chat_repository_interface.dart';
import 'package:whatsapp_clone/core/interfaces/audio_service_interface.dart';
import 'package:whatsapp_clone/core/interfaces/voice_recorder_interface.dart';
import 'package:whatsapp_clone/core/repositories/chat_repository.dart';
import 'package:whatsapp_clone/core/services/voice_recorder_service.dart';
import 'package:whatsapp_clone/core/services/audio_player_service.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';

class SimpleChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String type;
  final String? audioUrl;
  final String? imageUrl;
  final bool isUploading;

  SimpleChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.id,
    required this.type,
    this.audioUrl,
    this.imageUrl,
    this.isUploading = false,
  });

  SimpleChatMessage copyWith({
    String? text,
    bool? isMe,
    DateTime? timestamp,
    String? id,
    String? type,
    String? audioUrl,
    String? imageUrl,
    bool? isUploading,
  }) {
    return SimpleChatMessage(
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      timestamp: timestamp ?? this.timestamp,
      id: id ?? this.id,
      type: type ?? this.type,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      isUploading: isUploading ?? this.isUploading,
    );
  }

  factory SimpleChatMessage.fromJson(
    Map<String, dynamic> data,
    String currentUserId,
    String docId,
  ) {
    DateTime timestamp;
    try {
      final timestampData = data['timestamp'];
      
      if (timestampData == null) {
        debugPrint('⚠️ Timestamp is null, using current time');
        timestamp = DateTime.now();
      } else {
        try {
          if (timestampData.runtimeType.toString().contains('Timestamp')) {
            final dynamic timestampObj = timestampData;
            if (timestampObj != null && timestampObj.toString().contains('Timestamp')) {
              timestamp = timestampObj.toDate();
            } else {
              timestamp = DateTime.now();
            }
          } else if (timestampData is DateTime) {
            timestamp = timestampData;
          } else if (timestampData is String) {
            timestamp = DateTime.parse(timestampData);
          } else {
            debugPrint('⚠️ Unknown timestamp format: ${timestampData.runtimeType}');
            timestamp = DateTime.now();
          }
        } catch (e) {
          debugPrint('⚠️ Error processing timestamp: $e');
          timestamp = DateTime.now();
        }
      }
    } catch (e) {
      debugPrint('❌ Error parsing timestamp: $e');
      debugPrint('📝 Data: $data');
      timestamp = DateTime.now();
    }

    return SimpleChatMessage(
      text: data['text'] ?? '',
      isMe: data['senderId'] == currentUserId,
      timestamp: timestamp,
      id: docId,
      type: data['type'] ?? 'text',
      audioUrl: data['audioUrl'],
      imageUrl: data['imageUrl'],
    );
  }
}

class ChatDetailController extends GetxController {
  // Dependencies (injected)
  final IChatRepository _chatRepository;
  final IVoiceRecorderService _voiceRecorderService;
  final IAudioPlayerService _audioPlayerService;
  
  // Controllers
  final TextEditingController messageInputController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  // User data
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final String receiverId;
  late final String chatDocId;

  // Observable variables
  final RxList<SimpleChatMessage> messages = <SimpleChatMessage>[].obs;
  final RxBool isTyping = false.obs;
  final RxBool isRecording = false.obs;
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final RxString recordingDuration = '0:00'.obs;
  final RxMap<String, String> audioDurations = <String, String>{}.obs;
  final RxBool isUploadingImage = false.obs;

  // Private variables
  String? recordedFilePath;
  Timer? _recordingTimer;

  ChatDetailController({
    required this.receiverId,
    IChatRepository? chatRepository,
    IVoiceRecorderService? voiceRecorderService,
    IAudioPlayerService? audioPlayerService,
  }) : _chatRepository = chatRepository ?? ChatRepository(),
       _voiceRecorderService = voiceRecorderService ?? VoiceRecorderService(),
       _audioPlayerService = audioPlayerService ?? AudioPlayerService();

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
    _setupMessageStream();
    _setupTextFieldListener();
  }

  // ==================== INITIALIZATION METHODS ====================
  
  void _initializeChat() {
    chatDocId = _chatRepository.getChatId(currentUserId, receiverId);
  }

  void _setupMessageStream() {
    messages.bindStream(
      _chatRepository.getMessagesStream(chatDocId).map((snapshot) {
        final List<SimpleChatMessage> validMessages = [];
        
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final message = SimpleChatMessage.fromJson(data, currentUserId, doc.id);
            validMessages.add(message);
          } catch (e) {
            debugPrint('❌ Error parsing message ${doc.id}: $e');
            continue;
          }
        }
        
        return validMessages;
      }),
    );
  }

  void _setupTextFieldListener() {
    messageInputController.addListener(_onTextFieldChanged);
  }

  // ==================== VOICE RECORDING METHODS ====================

  Future<void> startVoiceRecording() async {
    try {
      debugPrint('🎤 Starting voice recording...');
      
      final isCurrentlyRecording = await _voiceRecorderService.isRecording();
      if (isCurrentlyRecording) {
        await _voiceRecorderService.stopRecording();
        await Future.delayed(Duration(milliseconds: 500));
      }
      
      await _voiceRecorderService.startRecording();
      isRecording.value = true;
      _startRecordingDurationTimer();
      
      debugPrint('✅ Voice recording started successfully');
    } catch (e) {
      debugPrint('❌ Error starting voice recording: $e');
      isRecording.value = false;
      _showErrorSnackbar('Recording Error', 'Failed to start recording: ${e.toString()}');
    }
  }

  void _startRecordingDurationTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (isRecording.value) {
        recordingDuration.value = _voiceRecorderService.formattedDuration;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> stopRecording() async {
    try {
      debugPrint('🛑 Stopping voice recording...');
      
      final isCurrentlyRecording = await _voiceRecorderService.isRecording();
      if (!isCurrentlyRecording) {
        debugPrint('⚠️ Not recording, nothing to stop');
        isRecording.value = false;
        return;
      }
      
      isRecording.value = false;
      _recordingTimer?.cancel();

      final file = await _voiceRecorderService.stopRecording().timeout(
        Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏰ Voice recording stop timeout');
          throw Exception('Voice recording stop timeout');
        },
      );
      
      if (file == null || !await file.exists()) {
        _showErrorSnackbar('Error', 'Failed to record voice message - no file created');
        return;
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        _showErrorSnackbar('Error', 'Voice recording is empty');
        return;
      }

      debugPrint('🎤 Voice file recorded successfully: ${file.path}');
      _uploadVoiceMessageInBackground(file.path);
    } catch (e) {
      debugPrint('❌ Error in stopRecording: $e');
      isRecording.value = false;
      _showErrorSnackbar('Error', 'Failed to process voice message: ${e.toString()}');
    }
  }

  Future<void> _uploadVoiceMessageInBackground(String filePath) async {
    try {
      debugPrint('🔄 Starting upload in background...');
      
      final result = await _chatRepository.uploadVoiceMessage(
        filePath: filePath,
        chatId: chatDocId,
        senderId: currentUserId,
      );

      if (result['success']) {
        debugPrint('✅ Voice message uploaded successfully: ${result['url']}');
      } else {
        debugPrint('❌ Voice message upload failed: ${result['error']}');
        _showErrorSnackbar('Error', 'Failed to upload voice message: ${result['error']}');
      }
    } catch (e) {
      debugPrint('❌ Error in upload task: $e');
      _showErrorSnackbar('Error', 'Failed to upload voice message: ${e.toString()}');
    }
  }

  // ==================== MESSAGE METHODS ====================

  Future<void> sendMessage() async {
    final text = messageInputController.text.trim();
    if (text.isEmpty) return;
    
    messageInputController.clear();
    _scrollToBottom();

    await _chatRepository.sendMessage(chatDocId, currentUserId, text);
  }

  Future<void> sendImageMessage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source, 
        imageQuality: 80, 
        maxWidth: 1024, 
        maxHeight: 1024
      );
      
      if (pickedFile == null) return;
      
      final file = File(pickedFile.path);
      isUploadingImage.value = true;
      
      await _chatRepository.sendImageMessage(chatDocId, currentUserId, file);
      _scrollToBottom();
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to send image: $e');
    } finally {
      isUploadingImage.value = false;
    }
  }

  // ==================== AUDIO PLAYBACK METHODS ====================

  Future<void> playVoiceMessage(String audioUrl) async {
    try {
      debugPrint('🎵 Attempting to play voice message: $audioUrl');
      
      if (audioUrl.isEmpty) {
        _showErrorSnackbar('Error', 'Invalid audio URL');
        return;
      }
      
      if (_audioPlayerService.isPlaying.value) {
        await _audioPlayerService.stopAudio();
        await Future.delayed(Duration(milliseconds: 100));
      }
      
      await _audioPlayerService.playAudio(audioUrl);
      debugPrint('✅ Voice message started playing successfully');
    } catch (e) {
      debugPrint('❌ Error playing voice message: $e');
      _showPlaybackError(e);
    }
  }

  Future<void> stopVoiceMessage() async {
    try {
      await _audioPlayerService.stopAudio();
    } catch (e) {
      debugPrint('❌ Error stopping voice message: $e');
    }
  }

  Future<void> seekVoiceMessage(double progress, String audioUrl) async {
    try {
      if (_audioPlayerService.currentAudioUrl.value == audioUrl) {
        await _audioPlayerService.seekToProgress(progress);
      }
    } catch (e) {
      debugPrint('❌ Error seeking voice message: $e');
    }
  }

  Future<void> toggleVoiceMessagePlayback(String audioUrl) async {
    try {
      if (_audioPlayerService.isPlaying.value) {
        await _audioPlayerService.pauseAudio();
      } else {
        if (_audioPlayerService.currentAudioUrl.value == audioUrl) {
          await _audioPlayerService.resumeAudio();
        } else {
          await playVoiceMessage(audioUrl);
        }
      }
    } catch (e) {
      debugPrint('❌ Error toggling voice message playback: $e');
    }
  }

  // ==================== AUDIO DURATION METHODS ====================

  Future<void> fetchAndCacheAudioDuration(String audioUrl) async {
    if (audioUrl.isEmpty || audioDurations.containsKey(audioUrl)) return;
    if (isAudioPlaying) return;
    
    try {
      final player = AudioPlayer();
      await player.setSource(UrlSource(audioUrl));
      final duration = await player.getDuration();
      
      if (duration != null) {
        final minutes = duration.inMinutes;
        final seconds = duration.inSeconds % 60;
        final formatted = '$minutes:${seconds.toString().padLeft(2, '0')}';
        audioDurations[audioUrl] = formatted;
      } else {
        debugPrint('❌ Could not get duration for $audioUrl');
      }
      
      await player.dispose();
    } catch (e) {
      debugPrint('❌ Error fetching audio duration: $e');
    }
  }

  // ==================== GETTER METHODS ====================

  bool get isAudioPlaying => _audioPlayerService.isPlaying.value;
  String get currentAudioUrl => _audioPlayerService.currentAudioUrl.value;
  double get audioProgress => _audioPlayerService.progress.value;
  String get audioCurrentTime => _audioPlayerService.currentTime.value;
  String get audioTotalDuration => _audioPlayerService.totalDuration.value;

  bool isMessagePlaying(String audioUrl) {
    return isAudioPlaying && currentAudioUrl == audioUrl;
  }

  double getMessageProgress(String audioUrl) {
    if (isMessagePlaying(audioUrl)) {
      return audioProgress;
    }
    return 0.0;
  }

  String getMessageCurrentTime(String audioUrl) {
    if (isMessagePlaying(audioUrl)) {
      return audioCurrentTime;
    }
    return '0:00';
  }

  String getMessageTotalDuration(String audioUrl) {
    if (isMessagePlaying(audioUrl)) {
      return audioTotalDuration;
    }
    return '0:00';
  }

  // ==================== UTILITY METHODS ====================

  void _scrollToBottom() {
    try {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      debugPrint('❌ Error scrolling to bottom: $e');
    }
  }

  void _onTextFieldChanged() {
    isTyping.value = messageInputController.text.trim().isNotEmpty;
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title, 
      message,
      duration: Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showPlaybackError(dynamic error) {
    String errorMessage = 'Failed to play voice message';
    
    if (error.toString().contains('timeout')) {
      errorMessage = 'Voice message took too long to load. Please try again.';
    } else if (error.toString().contains('network')) {
      errorMessage = 'Network error. Please check your connection.';
    } else if (error.toString().contains('format')) {
      errorMessage = 'Audio format not supported.';
    } else if (error.toString().contains('permission')) {
      errorMessage = 'Audio permission denied.';
    }
    
    _showErrorSnackbar('Playback Error', errorMessage);
  }

  Future<void> _cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      for (final file in files) {
        if (file is File && file.path.contains('audio_')) {
          final age = DateTime.now().difference(file.statSync().modified);
          if (age.inHours > 1) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up temp files: $e');
    }
  }

  @override
  void onClose() {
    messageInputController.removeListener(_onTextFieldChanged);
    messageInputController.dispose();
    scrollController.dispose();
    _recordingTimer?.cancel();
    _voiceRecorderService.dispose();
    _audioPlayerService.dispose();
    _cleanupTempFiles();
    super.onClose();
  }
}


  
  