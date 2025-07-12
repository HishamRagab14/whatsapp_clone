import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:whatsapp_clone/core/constants.dart';
import 'package:whatsapp_clone/firebase_options.dart';
import 'package:whatsapp_clone/view/home/home_screen.dart';
import 'package:whatsapp_clone/view/login/login_screen.dart';
import 'package:whatsapp_clone/view/login/otp_verification_screen.dart';
import 'package:whatsapp_clone/view/settings/settings_screen.dart';
import 'package:whatsapp_clone/view/splash/splash_screen.dart';
import 'package:whatsapp_clone/view/users/all_users_screen.dart';
import 'package:whatsapp_clone/view_model/bindings/login_binding.dart';
import 'package:whatsapp_clone/view_model/bindings/otp_binding.dart';
import 'package:whatsapp_clone/view_model/bindings/settings_binding.dart';
import 'package:whatsapp_clone/view_model/bindings/status_binding.dart';
import 'package:whatsapp_clone/view_model/bindings/main_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // تهيئة GetStorage
  await GetStorage.init();

  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      initialBinding: MainBinding(),

      getPages: [
        GetPage(name: SplashScreen.splashRoute, page: () => SplashScreen()),
        GetPage(
          name: LoginScreen.loginRoute,
          page: () => LoginScreen(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: OtpVerificationScreen.otpRoute,
          page: () => OtpVerificationScreen(),
          binding: OtpBinding(),
        ),
        GetPage(
          name: HomeScreen.homeRoute,
          page: () {
            return HomeScreen();
          },
          binding: StatusBinding(),
        ),
        GetPage(
          name: SettingsScreen.settingsRoute,
          page: () => SettingsScreen(),
          binding: SettingsBinding(),
        ),
        GetPage(
          name: AllUsersScreen.allUsersRoute,
          page: () {
            return const AllUsersScreen();
          },
        ),
      ],
      theme: ThemeData(
        scaffoldBackgroundColor: kLightBackgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: kLightPrimaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: kDarkBackgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: kDarkPrimaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
