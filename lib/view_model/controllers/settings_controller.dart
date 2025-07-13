import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_clone/core/services/auth_service.dart';
import 'package:whatsapp_clone/core/services/firestore_user_service.dart';
import 'package:whatsapp_clone/core/repositories/user_repository.dart';
import 'package:whatsapp_clone/model/users/user_model.dart';
import 'package:whatsapp_clone/view_model/controllers/chat_list_controller.dart';
import 'package:whatsapp_clone/view_model/controllers/status_controller.dart';
import 'package:whatsapp_clone/view_model/controllers/chat_detail_controller.dart';

class SettingsController extends GetxController {
  final FirestoreUserService _userService = FirestoreUserService();
  
  // Observable variables
  final AuthService _authService = Get.find<AuthService>();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
  }

  /// تحميل بيانات المستخدم الحالي
  Future<void> loadCurrentUser() async {
    try {
      isLoading.value = true;
      final user = await _userService.getCurrentUser();
      currentUser.value = user;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load user data',
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// اختيار صورة من الكاميرا أو المعرض
  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadAndUpdateImage(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        duration: Duration(seconds: 3),
      );
    }
  }

  /// رفع وتحديث الصورة
  Future<void> _uploadAndUpdateImage(File imageFile) async {
    try {
      isUpdating.value = true;
      
      final String? imageUrl = await _userService.uploadProfileImage(
        imageFile,
        currentUser.value!.uId,
      );

      if (imageUrl != null) {
        await _userService.updateProfileImage(currentUser.value!.uId, imageUrl);
        await loadCurrentUser(); // إعادة تحميل البيانات
        Get.snackbar(
          'Success',
          'Profile image updated successfully',
          duration: Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to upload image',
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update image: $e',
        duration: Duration(seconds: 3),
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// حذف الصورة الشخصية
  Future<void> deleteProfileImage() async {
    try {
      if (currentUser.value?.profileImageUrl != null) {
        await _userService.deleteProfileImage(currentUser.value!.uId);
        await loadCurrentUser(); // إعادة تحميل البيانات
        Get.snackbar(
          'Success',
          'Profile image deleted successfully',
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete profile image: $e',
        duration: Duration(seconds: 3),
      );
    }
  }

  /// تحديث اسم المستخدم
  Future<void> updateUserName(String newName) async {
    try {
      if (currentUser.value != null) {
        await _userService.updateUserName(currentUser.value!.uId, newName);
        await loadCurrentUser(); // إعادة تحميل البيانات
        Get.snackbar(
          'Success',
          'Name updated successfully',
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update name: $e',
        duration: Duration(seconds: 3),
      );
    }
  }

  /// تحديث حالة المستخدم (Status)
  Future<void> updateUserStatus(String newStatus) async {
    try {
      if (currentUser.value != null) {
        await _userService.updateUserStatus(currentUser.value!.uId, newStatus);
        await loadCurrentUser(); // إعادة تحميل البيانات
        Get.snackbar(
          'Success',
          'Status updated successfully',
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update status: $e',
        duration: Duration(seconds: 3),
      );
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    try {
      // إظهار مؤشر التحميل
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      
      // إيقاف جميع الـ Stream Listeners أولاً
      _stopAllStreamListeners();
      
      // تسجيل الخروج من Firebase
      await _authService.signOut();
      
      // مسح البيانات المحلية
      final userRepository = Get.find<UserRepository>();
      await userRepository.clearCachedUser();
      
      // إغلاق dialog التحميل
      Get.back();
      
      // الانتقال إلى شاشة تسجيل الدخول مع إعادة تعيين الـ navigation stack
      Get.offAllNamed('/login');
    } catch (e) {
      // إغلاق dialog التحميل في حالة الخطأ
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      Get.snackbar(
        'Error',
        'Failed to logout: $e',
        duration: Duration(seconds: 3),
      );
    }
  }

  /// إيقاف جميع الـ Stream Listeners
  void _stopAllStreamListeners() {
    try {
      // حذف ChatListController لإيقاف Stream Listener للـ chats
      if (Get.isRegistered<ChatListController>()) {
        Get.delete<ChatListController>();
      }
      
      // حذف StatusController لإيقاف Stream Listener للـ statuses
      if (Get.isRegistered<StatusController>()) {
        Get.delete<StatusController>();
      }
      
      // حذف ChatDetailController لإيقاف Stream Listener للـ messages
      if (Get.isRegistered<ChatDetailController>()) {
        Get.delete<ChatDetailController>();
      }
    } catch (e) {
      print('❌ Error stopping stream listeners: $e');
    }
  }

  /// الحصول على مدة التسجيل المنسقة
  String get formattedDuration {
    // يمكن إضافة منطق إضافي هنا إذا لزم الأمر
    return '0:00';
  }

  /// التحقق من وجود صورة شخصية
  bool get hasProfileImage => currentUser.value?.profileImageUrl != null;

  /// الحصول على رابط الصورة الشخصية
  String? get profileImageUrl => currentUser.value?.profileImageUrl;

  /// الحصول على اسم المستخدم
  String get userName => currentUser.value?.userName ?? 'No Name';

  /// الحصول على رقم الهاتف
  String get phoneNumber => currentUser.value?.phoneNumber ?? '';

  /// الحصول على حالة المستخدم
  String? get userStatus => currentUser.value?.status;
} 