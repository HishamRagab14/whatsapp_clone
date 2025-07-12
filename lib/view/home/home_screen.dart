import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whatsapp_clone/core/constants.dart';
import 'package:whatsapp_clone/core/services/firestore_user_service.dart';
import 'package:whatsapp_clone/core/widgets/custom_app_bar.dart';
import 'package:whatsapp_clone/view/calls/calls_screen.dart';
import 'package:whatsapp_clone/view/chats/chats_screen.dart';
import 'package:whatsapp_clone/view/settings/settings_screen.dart';
import 'package:whatsapp_clone/view/updates/updates_screen.dart';
import 'package:whatsapp_clone/view_model/controllers/settings_controller.dart';
import 'package:whatsapp_clone/view_model/controllers/status_controller.dart';
import 'package:whatsapp_clone/core/repositories/status_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String homeRoute = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> appTitles = ['Updates', 'Calls', 'Chats', 'Settings'];
  int currentIndex = 2;
  final List<Widget> pages = [
    Builder(
      builder: (context) {
        Get.delete<StatusController>();
        Get.put(StatusController(
          repository: StatusRepository(),
          currentUserId: FirebaseAuth.instance.currentUser?.uid ?? '',
        ));
        return UpdatesScreen();
      },
    ),
    CallsScreen(),
    ChatScreen(),
    Builder(
      builder: (context) {
        Get.delete<SettingsController>();
        Get.put(SettingsController());
        return SettingsScreen();
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    // تحديث بيانات المستخدم إذا كانت غير مكتملة
    _updateUserDataIfNeeded();
  }

  Future<void> _updateUserDataIfNeeded() async {
    try {
      final userService = FirestoreUserService();
      await userService.updateCurrentUserIfNeeded();
    } catch (e) {
      // print('❌ Error updating user data: $e');
    }
  }

  Widget _buildCurrentPage() {
    return pages[currentIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            appTitle: appTitles[currentIndex],
            action:
                currentIndex == 2
                    ? IconButton(
                      onPressed: () {
                        Get.toNamed('/all-users');
                      },
                      icon: CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 16,
                        child: Icon(Icons.add, color: Colors.white, size: 22),
                      ),
                    )
                    : null,
          ),
          Expanded(child: _buildCurrentPage()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kLightPrimaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Updates'),
          BottomNavigationBarItem(icon: Icon(Iconsax.call), label: 'Calls'),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.message_2),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.setting4),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
