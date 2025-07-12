// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For UserCredential
import 'package:whatsapp_clone/core/repositories/user_repository.dart';
import 'package:whatsapp_clone/core/services/auth_service.dart';
import 'package:whatsapp_clone/model/users/user_model.dart'; // Your AuthService

class OtpController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  final String verificationId;
  final String fullPhoneNumberForDisplay;

  final TextEditingController otpInputController = TextEditingController(
    text: "",
  );
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  OtpController({
    required this.verificationId,
    required this.fullPhoneNumberForDisplay,
  });

  // --- LISTENER METHOD - DEFINED BEFORE onInit and onClose ---
  void _onOtpChanged() {
    if (otpInputController.text.length == 6 && !isLoading.value) {
      submitOtp(); // Call the submitOtp method
    }
    // Clear error message when user starts typing again
    if (otpInputController.text.isNotEmpty && errorMessage.value.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    log(
      "OtpController initialized. Verification ID: $verificationId, Phone: $fullPhoneNumberForDisplay",
    );
    otpInputController.addListener(
      _onOtpChanged,
    ); // Now _onOtpChanged is defined above
  }

  Future<void> submitOtp() async {
    if (isLoading.value) return;

    final String otpCode = otpInputController.text.trim();
    if (otpCode.length != 6) {
      errorMessage.value = "Please enter a 6-digit OTP.";
      return;
    }

    FocusScope.of(Get.overlayContext!).unfocus();

    isLoading.value = true;
    errorMessage.value = '';

    try {
      UserCredential? userCredential = await _authService.signInWithOtp(
        verificationId,
        otpCode,
      );

      isLoading.value = false;
      if (userCredential != null && userCredential.user != null) {
        final user = userCredential.user!;
        log(
          "OtpController: User Signed In successfully: ${userCredential.user!.uid}",
        );
        final userExists = await _userRepository.isUserExists(user.uid);

        if (!userExists) {
          final newUser = UserModel(
            uId: user.uid,
            phoneNumber: fullPhoneNumberForDisplay,
            userName: '',
            profileImageUrl: '',
            isOnline: true,
            status: 'Hey there! I am using Hisham\'s WhatsApp .',
            lastSeen: DateTime.now(),
          );
          await _userRepository.createUser(newUser);
          log("OtpController: New user created in Firestore: ${user.uid}");
        } else {
          log("OtpController: User already exists in Firestore: ${user.uid}");
        }

        final userModel = await _userRepository.getUserById(user.uid);
        if (userModel != null) {
          await _userRepository.cachUser(userModel);
          log("OtpController: User cached locally: ${userModel.uId}");
        }
        Get.offAllNamed('/home');
      } else {
        errorMessage.value =
            "Invalid OTP or session expired. Please try again.";
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      errorMessage.value =
          "OTP verification failed: ${e.message ?? 'Unknown error.'}";
      log("OtpController: FirebaseAuthException: ${e.code} - ${e.message}");
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = "An unexpected error occurred. Please try again.";
      log("OtpController: Unexpected error: $e");
    }
  }

  @override
  void onClose() {
    otpInputController.removeListener(
      _onOtpChanged,
    ); // Now _onOtpChanged is defined above
    otpInputController.dispose();
    super.onClose();
  }
}
