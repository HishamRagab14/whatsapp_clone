import 'package:get/get.dart';
import 'package:whatsapp_clone/core/services/auth_service.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService(), permanent: true);
  }
} 