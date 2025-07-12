import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/core/constants.dart';
import 'package:whatsapp_clone/core/widgets/custom_button.dart';
import 'package:whatsapp_clone/core/widgets/custom_phone_text_field.dart';
import 'package:whatsapp_clone/core/widgets/phone_country_input_drag_drop.dart';
import 'package:whatsapp_clone/model/country_model.dart';
import 'package:whatsapp_clone/view_model/controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  static const String loginRoute = '/login';
  // final TextEditingController codeController = TextEditingController();
  // final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final LoginScreenController controller = Get.find<LoginScreenController>();
    final TextEditingController localCodeController = TextEditingController();

    ever(controller.selectedCountryRx, (CountryModel newSelectedCountry) {
      localCodeController.text = newSelectedCountry.dialCode;
      log(
        "LoginScreen 'ever' listener: Country changed to ${newSelectedCountry.name}, Dial code: ${newSelectedCountry.dialCode}",
      );
    });
    localCodeController.text = controller.selectedDialCode;

    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Enter your phone number',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40),
            Text(
              'Whatsapp will need to verify your phone number',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            SizedBox(width: 250, child: PhoneCountryInputDragDrop()),

            SizedBox(height: 30),

            CustomPhoneTextField(
              codeController: localCodeController,
              phoneController: controller.phoneInputController,
            ),
            const Spacer(),
            Obx(() {
              if (controller.errorMessage.value.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Obx(() {
              if (controller.isLoading.value) {
                return const CircularProgressIndicator();
              } else {
                return CustomButton(
                  text: 'Next',
                  onPressed: () {
                    controller.verifyAndSendOtp();
                  },
                );
              }
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
