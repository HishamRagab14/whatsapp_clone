// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/core/data/countries.dart';
import 'package:whatsapp_clone/core/repositories/user_repository.dart';
import 'package:whatsapp_clone/core/services/auth_service.dart';
import 'package:whatsapp_clone/model/country_model.dart';
import 'package:whatsapp_clone/model/phone_verification_request.dart';

class LoginScreenController extends GetxController {
  // final AuthService _authService = Get.put(AuthService());
  final AuthService _authService = Get.find<AuthService>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var verificationIdStore = ''.obs;
  final TextEditingController phoneInputController = TextEditingController();

  final Rx<CountryModel> _selectedCountry = countries[0].obs;
  CountryModel get selectedCountry => _selectedCountry.value;
  Rx<CountryModel> get selectedCountryRx => _selectedCountry;

  RxString dialCode = ''.obs;

  void updateSelectedCountry(CountryModel newCountry) {
    _selectedCountry.value = newCountry;
  }

  String get selectedDialCode => _selectedCountry.value.dialCode;

  Future<void> verifyAndSendOtp() async {
    if (phoneInputController.text.trim().isEmpty) {
      errorMessage.value = "Please enter your phone number.";
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    final String fullPhoneNumber =
        selectedDialCode + phoneInputController.text.trim();

    print("Attempting to verify phone number: $fullPhoneNumber");

    final verificationRequest = PhoneVerificationRequest(
      phoneNumber: fullPhoneNumber,
      onCodeSent: (String verificationId, int? resendToken) {
        print(
          "OTP Code Sent (via Request Object). Verification ID: $verificationId",
        );
        verificationIdStore.value = verificationId;
        isLoading.value = false;
        Get.toNamed(
          '/otp',
          arguments: {
            'verificationId': verificationId,
            'fullPhoneNumber': fullPhoneNumber,
          },
        );
      },

      onVerificationFailed: (FirebaseAuthException e) async {
        print(
          "OTP Verification Failed (via Request Object): ${e.code} - ${e.message}",
        );
        isLoading.value = false;
        errorMessage.value =
            "Failed to send OTP: ${e.message ?? 'Please try again.'}";
      },

      onVerificationCompleted: (PhoneAuthCredential credential) async {
        print("OTP Verification automatically completed (via Request Object)!");

        isLoading.value = true;
        errorMessage.value = '';
        try {
          final userCredential = await _authService.signInWithCredential(
            credential,
          );
          isLoading.value = false;

          final user = userCredential.user;

          if (user != null) {
            print(
              "LoginController: User Signed In via auto-completion: ${user.uid}",
            );

            await Get.find<UserRepository>().createUserIfNotExist(user);

            final userModel = await Get.find<UserRepository>().getUserById(
              user.uid,
            );

            if (userModel != null) {
              await Get.find<UserRepository>().cachUser(userModel);
            }

            Get.offAllNamed('/home');
          } else {
            errorMessage.value =
                "Auto sign-in failed. Please try OTP manually.";
          }
        } on FirebaseAuthException catch (e) {
          isLoading.value = false;
          errorMessage.value =
              "Sign-in error after auto-verification: ${e.message ?? 'Unknown error.'}";
          print(
            "LoginController: FirebaseAuthException during auto sign-in: ${e.code} - ${e.message}",
          );
        } catch (e) {
          isLoading.value = false;
          errorMessage.value =
              "An unexpected error occurred during auto sign-in.";
          print("LoginController: Unexpected error during auto sign-in: $e");
        }
      },
      onCodeAutoRetrievalTimeout: (String verificationId) {
        print(
          "LoginController: OTP Auto-retrieval timed out. Verification ID: $verificationId",
        );
        verificationIdStore.value = verificationId;
        if (Get.currentRoute != '/otp' && isLoading.value) {
          isLoading.value = false;
          Get.toNamed(
            '/otp',
            arguments: {
              'verificationId': verificationId,
              'fullPhoneNumber': fullPhoneNumber,
            },
          );
        } else if (isLoading.value && Get.currentRoute == '/otp') {
          isLoading.value = false;
        }
      },
      timeout: Duration(seconds: 60),
      forceResendingToken: null,
    );

    try {
      await _authService.verifyPhoneNumber(request: verificationRequest);
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = "Could not initiate phone verification. $e";
      print(
        "LoginController: Error calling _authService.verifyPhoneNumber: $e",
      );
    }
  }

  @override
  // ignore: unnecessary_overrides
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    phoneInputController.dispose();
    super.onClose();
  }
}
