import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_clone/core/constants.dart';
import 'package:whatsapp_clone/core/services/notification_service.dart';
import 'package:whatsapp_clone/view_model/controllers/notification_settings_controller.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationSettingsController>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Obx(() {
        return ListView(
          children: [
            // General Notifications
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'General',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Show notifications'),
                    subtitle: const Text('Enable all notifications'),
                    value: controller.showNotifications.value,
                    onChanged: (value) => controller.toggleShowNotifications(value),
                    activeColor: kLightPrimaryColor,
                  ),
                  SwitchListTile(
                    title: const Text('Sound'),
                    subtitle: const Text('Play sound for notifications'),
                    value: controller.soundEnabled.value,
                    onChanged: (value) => controller.toggleSound(value),
                    activeColor: kLightPrimaryColor,
                  ),
                  SwitchListTile(
                    title: const Text('Vibration'),
                    subtitle: const Text('Vibrate for notifications'),
                    value: controller.vibrationEnabled.value,
                    onChanged: (value) => controller.toggleVibration(value),
                    activeColor: kLightPrimaryColor,
                  ),
                ],
              ),
            ),

            // Message Notifications
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Messages',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('New messages'),
                    subtitle: const Text('Notify when receiving new messages'),
                    value: controller.messageNotifications.value,
                    onChanged: (value) => controller.toggleMessageNotifications(value),
                    activeColor: kLightPrimaryColor,
                  ),
                  SwitchListTile(
                    title: const Text('Message preview'),
                    subtitle: const Text('Show message content in notifications'),
                    value: controller.messagePreview.value,
                    onChanged: (value) => controller.toggleMessagePreview(value),
                    activeColor: kLightPrimaryColor,
                  ),
                ],
              ),
            ),

            // Status Notifications
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Status',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Status updates'),
                    subtitle: const Text('Notify when contacts add new status'),
                    value: controller.statusNotifications.value,
                    onChanged: (value) => controller.toggleStatusNotifications(value),
                    activeColor: kLightPrimaryColor,
                  ),
                ],
              ),
            ),

            // Call Notifications
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Calls',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Missed calls'),
                    subtitle: const Text('Notify for missed calls'),
                    value: controller.missedCallNotifications.value,
                    onChanged: (value) => controller.toggleMissedCallNotifications(value),
                    activeColor: kLightPrimaryColor,
                  ),
                ],
              ),
            ),

            // Test Notification
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 8),
              child: ListTile(
                leading: const Icon(Icons.notifications, color: kLightPrimaryColor),
                title: const Text('Test notification'),
                subtitle: const Text('Send a test notification'),
                onTap: () => _showTestNotification(),
              ),
            ),

            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }

  void _showTestNotification() async {
    try {
      await NotificationService().showTestNotification();
      Get.snackbar(
        'Success',
        'Test notification sent!',
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send test notification: $e',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
} 