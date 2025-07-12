import 'dart:developer';

import 'package:get/get.dart';
import 'package:whatsapp_clone/core/repositories/user_repository.dart';
import 'package:whatsapp_clone/core/services/auth_service.dart';
import 'package:whatsapp_clone/view_model/controllers/otp_controller.dart'; // Important if OtpController uses Get.find<AuthService>()

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository());

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final String verificationId = args['verificationId'] as String? ?? '';
    final String fullPhoneNumber = args['fullPhoneNumber'] as String? ?? '';

    if (verificationId.isEmpty) {
      log("OtpBinding ERROR: Verification ID is empty!");
    }

    Get.lazyPut<OtpController>(
      () => OtpController(
        verificationId: verificationId,
        fullPhoneNumberForDisplay: fullPhoneNumber,
      ),
    );
  }
}
