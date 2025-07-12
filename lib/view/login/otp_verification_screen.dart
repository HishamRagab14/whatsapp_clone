import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:whatsapp_clone/view_model/controllers/otp_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});
  static const String otpRoute = '/otp';

  @override
  Widget build(BuildContext context) {
    // final LoginScreenController controller = Get.put(LoginScreenController());
    final ThemeData theme = Theme.of(context);

    final Map<String, dynamic> args = Get.arguments ?? {};
    final String verificationId = args['verificationId'] ?? '';
    final String fullPhoneNumber = args['phoneNumber'] ?? '';
    final OtpController controller = Get.put(
      OtpController(
        verificationId: verificationId,
        fullPhoneNumberForDisplay: fullPhoneNumber,
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            children: [
              Text(
                'Verifying your number',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Waiting to automatically detect an SMS sent to ',
                    ),
                    TextSpan(
                      text: '+01 234567890',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const TextSpan(text: '. '), // Add a period and space
                    TextSpan(
                      text: 'Wrong number?',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              // print('Wrong number tapped!');
                              Navigator.of(context).pop();
                            },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              Pinput(
                length: 6,
                controller: controller.otpInputController,
                defaultPinTheme: PinTheme(
                  width: 40,
                  height: 45,
                  textStyle: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1.5, color: theme.hintColor),
                    ),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 40,
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 2.0, color: theme.primaryColor),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Obx(() {
                if (controller.errorMessage.isNotEmpty) {
                  return Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
              Obx(
                () =>
                    controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : Text(
                          "Enter 6-digit code",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
              ),
              // Text(
              //   "--- Placeholder for OTP Fields ---",
              //   style: TextStyle(color: Colors.grey[400]),
              // ),
              // const SizedBox(height: 24),
              // Text(
              //   "Enter 6-digit code",
              //   style: theme.textTheme.bodySmall?.copyWith(
              //     color: theme.hintColor,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
