import 'package:get/get.dart';
import 'package:whatsapp_clone/core/services/auth_service.dart';
import 'package:whatsapp_clone/core/repositories/user_repository.dart';
import 'package:whatsapp_clone/core/services/firestore_user_service.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<UserRepository>(UserRepository(), permanent: true);
    Get.put<FirestoreUserService>(FirestoreUserService(), permanent: true);
  }
} 