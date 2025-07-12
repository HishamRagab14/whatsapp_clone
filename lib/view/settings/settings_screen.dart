import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_clone/view_model/controllers/settings_controller.dart';
import 'package:whatsapp_clone/view_model/controllers/notification_settings_controller.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});
  static const String settingsRoute = '/settings';
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.currentUser.value == null) {
          return const Center(child: Text('Failed to load user data'));
        }
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _profileImage(
                profileImageUrl: controller.profileImageUrl,
                onPickImage: () => controller.pickImage(ImageSource.gallery),
              ),
              Center(
                child: _profileCard(
                  username: controller.userName,
                  status: controller.userStatus,
                  onEdit: _goToEditProfile,
                ),
              ),
              const SizedBox(height: 4),
              _SettingsSectionContainer(
                opacity: 0.5,
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.blueGrey, size: 22),
                    title: Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    ),
                    onTap: _goToEditProfile,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                    tileColor: Colors.transparent,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(height: 1, thickness: 0.7, color: Colors.grey[300]),
                  ),
                  _settingsTile(icon: Icons.key, title: 'Privacy', divider: false),
                ],
              ),
              const SizedBox(height: 8),
              _SettingsSectionContainer(
                opacity: 0.5,
                children: [
                  _settingsTile(icon: Icons.wallpaper, title: 'Chat Wallpaper', divider: true),
                  _settingsTile(icon: Icons.notifications, title: 'Notifications', divider: false),
                ],
              ),
              const SizedBox(height: 8),
              _SettingsSectionContainer(
                opacity: 0.5,
                children: [
                  _settingsTile(icon: Icons.storage, title: 'Storage and Data', divider: false),
                ],
              ),
              const SizedBox(height: 8),
              _SettingsSectionContainer(
                opacity: 0.5,
                children: [
                  _settingsTile(icon: Icons.help, title: 'Help Center', divider: true),
                  _settingsTile(icon: Icons.info, title: 'About', divider: false),
                ],
              ),
              const SizedBox(height: 16),
              _buildLogoutButton(),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  Widget _profileImage({
    required String? profileImageUrl,
    required VoidCallback onPickImage,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                  ? NetworkImage(profileImageUrl)
                  : const AssetImage('assets/images/person.jpg') as ImageProvider,
              backgroundColor: Colors.grey[300],
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: InkWell(
              onTap: onPickImage,
              child: CircleAvatar(
                radius: 13,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.camera_alt, color: Colors.grey[700], size: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard({
    required String username,
    required String? status,
    required VoidCallback onEdit,
  }) {
    return Column(
      children: [
        Text(
          username,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          controller.phoneNumber,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        if (status != null) ...[
          SizedBox(height: 8),
          Text(
            status,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }

 
  Widget _settingsTile({
    required IconData icon,
    required String title,
    required bool divider,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.blueGrey, size: 22),
          title: Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
          ),
          onTap: () => _navigateToSettingsItem(title),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          tileColor: Colors.transparent,
        ),
        if (divider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 1, thickness: 0.7, color: Colors.grey[300]),
          ),
      ],
    );
  }

  /// زر تسجيل الخروج
  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () => controller.logout(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  
  void _goToEditProfile() {
    Get.to(() => const EditProfileScreen());
  }

  void _navigateToSettingsItem(String title) {
    switch (title) {
      case 'Notifications':
        Get.lazyPut<NotificationSettingsController>(() => NotificationSettingsController());
        Get.to(() => const NotificationSettingsScreen());
        break;
      case 'Edit Profile':
        _goToEditProfile();
        break;
      default:
        Get.snackbar('Info', '$title will be implemented');
    }
  }
}

class _SettingsSectionContainer extends StatelessWidget {
  final List<Widget> children;
  final double opacity;
  const _SettingsSectionContainer({required this.children, this.opacity = 0.35});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
