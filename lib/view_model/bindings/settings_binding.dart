import 'package:get/get.dart';
import 'package:whatsapp_clone/core/services/auth_service.dart';
import 'package:whatsapp_clone/view_model/controllers/settings_controller.dart';
import 'package:whatsapp_clone/core/services/firestore_user_service.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // 1. تسجيل Service أولاً
    Get.lazyPut<FirestoreUserService>(() => FirestoreUserService());

    Get.lazyPut<AuthService>(() => AuthService());
    
    // 2. تسجيل Controller (سيحصل على Service تلقائياً)
    Get.lazyPut<SettingsController>(() => SettingsController());

    
  }
} 