import 'package:get/get.dart';
import 'package:whatsapp_clone/core/repositories/user_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<UserRepository>(UserRepository());
  }
}
