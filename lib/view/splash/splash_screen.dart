import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:whatsapp_clone/view/login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String splashRoute = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // ظاهرة الـ logo بالـ animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _visible = true;
      });
    });
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    try {
      // نخلي الـ splash ظاهر على الأقل 2 ثانية
      await Future.delayed(const Duration(seconds: 2));
      
      // بعد الـ 2 ثانية، نتأكد من حالة المستخدم المحفوظة
      final user = FirebaseAuth.instance.currentUser;
      log("💡 SplashScreen: currentUser = $user");

      if (user != null && user.uid.isNotEmpty) {
        log("→ Found signed-in user: ${user.uid}");
        // لو في مستخدم محفوظ (مسجّل دخول)
        Get.offAllNamed('/home');
      } else {
        log("→ No user found. Redirecting to /login");
        // لو مفيش مستخدم مسجّل
        Get.offAllNamed('/login');
      }
    } catch (e) {
      log("❌ Error in splash navigation: $e");
      // في حالة حدوث خطأ، انتقل إلى شاشة تسجيل الدخول
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF075E54),
      body: Stack(
        children: [
          Center(
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 1000),
              offset: _visible ? Offset.zero : const Offset(0, -2),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _visible ? 1 : 0,
                child: Image.asset(
                  'assets/images/whatsapp.png',
                  height: 100,
                  width: 100,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'from',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                Text(
                  'Meta',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
