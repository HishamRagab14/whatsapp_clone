import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotificationSettingsController extends GetxController {
  final _storage = GetStorage();
  
  // General Settings
  final RxBool showNotifications = true.obs;
  final RxBool soundEnabled = true.obs;
  final RxBool vibrationEnabled = true.obs;
  
  // Message Settings
  final RxBool messageNotifications = true.obs;
  final RxBool messagePreview = true.obs;
  
  // Status Settings
  final RxBool statusNotifications = true.obs;
  
  // Call Settings
  final RxBool missedCallNotifications = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  /// تحميل الإعدادات المحفوظة
  void _loadSettings() {
    showNotifications.value = _storage.read('showNotifications') ?? true;
    soundEnabled.value = _storage.read('soundEnabled') ?? true;
    vibrationEnabled.value = _storage.read('vibrationEnabled') ?? true;
    messageNotifications.value = _storage.read('messageNotifications') ?? true;
    messagePreview.value = _storage.read('messagePreview') ?? true;
    statusNotifications.value = _storage.read('statusNotifications') ?? true;
    missedCallNotifications.value = _storage.read('missedCallNotifications') ?? true;
  }

  /// حفظ الإعدادات
  void _saveSettings() {
    _storage.write('showNotifications', showNotifications.value);
    _storage.write('soundEnabled', soundEnabled.value);
    _storage.write('vibrationEnabled', vibrationEnabled.value);
    _storage.write('messageNotifications', messageNotifications.value);
    _storage.write('messagePreview', messagePreview.value);
    _storage.write('statusNotifications', statusNotifications.value);
    _storage.write('missedCallNotifications', missedCallNotifications.value);
  }

  /// تبديل إظهار الإشعارات
  void toggleShowNotifications(bool value) {
    showNotifications.value = value;
    _saveSettings();
    
    if (!value) {
      // إيقاف جميع الإشعارات
      messageNotifications.value = false;
      statusNotifications.value = false;
      missedCallNotifications.value = false;
    }
  }

  /// تبديل الصوت
  void toggleSound(bool value) {
    soundEnabled.value = value;
    _saveSettings();
  }

  /// تبديل الاهتزاز
  void toggleVibration(bool value) {
    vibrationEnabled.value = value;
    _saveSettings();
  }

  /// تبديل إشعارات الرسائل
  void toggleMessageNotifications(bool value) {
    messageNotifications.value = value;
    _saveSettings();
    
    if (value && !showNotifications.value) {
      showNotifications.value = true;
    }
  }

  /// تبديل معاينة الرسائل
  void toggleMessagePreview(bool value) {
    messagePreview.value = value;
    _saveSettings();
  }

  /// تبديل إشعارات الـ Status
  void toggleStatusNotifications(bool value) {
    statusNotifications.value = value;
    _saveSettings();
    
    if (value && !showNotifications.value) {
      showNotifications.value = true;
    }
  }

  /// تبديل إشعارات المكالمات الفائتة
  void toggleMissedCallNotifications(bool value) {
    missedCallNotifications.value = value;
    _saveSettings();
    
    if (value && !showNotifications.value) {
      showNotifications.value = true;
    }
  }

  /// إعادة تعيين الإعدادات
  void resetToDefaults() {
    showNotifications.value = true;
    soundEnabled.value = true;
    vibrationEnabled.value = true;
    messageNotifications.value = true;
    messagePreview.value = true;
    statusNotifications.value = true;
    missedCallNotifications.value = true;
    
    _saveSettings();
    
    Get.snackbar(
      'Settings Reset',
      'Notification settings have been reset to defaults',
      duration: const Duration(seconds: 2),
    );
  }

  /// الحصول على إعدادات الإشعارات كـ Map
  Map<String, bool> getNotificationSettings() {
    return {
      'showNotifications': showNotifications.value,
      'soundEnabled': soundEnabled.value,
      'vibrationEnabled': vibrationEnabled.value,
      'messageNotifications': messageNotifications.value,
      'messagePreview': messagePreview.value,
      'statusNotifications': statusNotifications.value,
      'missedCallNotifications': missedCallNotifications.value,
    };
  }
} 