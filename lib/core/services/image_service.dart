import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  static const String _downloadSuccessMessage = 'Image saved to Gallery';
  static const String _downloadErrorMessage = 'Could not download image';
  static const String _permissionErrorMessage = 'Storage permission is required to save images';
  static const String _shareErrorMessage = 'Could not share image';
  static const String _copySuccessMessage = 'Image URL copied to clipboard';

  final ImagePicker _picker = ImagePicker();

  /// تحميل صورة من الرابط
  Future<void> downloadImage(String imageUrl) async {
    try {
      _showDownloadingSnackbar();

      if (!await _requestStoragePermission()) {
        _showErrorSnackbar('Permission Denied', _permissionErrorMessage);
        return;
      }

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        await _saveImageToGallery(response.bodyBytes);
      } else {
        _showErrorSnackbar('Error', _downloadErrorMessage);
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to download image: $e');
    }
  }

  /// مشاركة صورة
  Future<void> shareImage(String imageUrl) async {
    try {
      if (await canLaunchUrl(Uri.parse(imageUrl))) {
        await launchUrl(Uri.parse(imageUrl));
      } else {
        _showErrorSnackbar('Error', _shareErrorMessage);
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to share image: $e');
    }
  }

  /// نسخ رابط الصورة
  void copyImageUrl(String imageUrl) {
    Clipboard.setData(ClipboardData(text: imageUrl));
    _showSuccessSnackbar('Copied', _copySuccessMessage);
  }

  /// طلب إذن التخزين
  Future<bool> _requestStoragePermission() async {
    // محاولة الحصول على إذن الصور أولاً
    var photosStatus = await Permission.photos.status;
    if (photosStatus.isGranted) return true;

    photosStatus = await Permission.photos.request();
    if (photosStatus.isGranted) return true;

    // إذا فشل، جرب إذن التخزين
    var storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) return true;

    storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  /// حفظ الصورة في المعرض
  Future<void> _saveImageToGallery(List<int> imageBytes) async {
    final fileName = 'whatsapp_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    // محاولة حفظ في مجلد DCIM أولاً
    final dcimDir = Directory('/storage/emulated/0/DCIM');
    if (await dcimDir.exists()) {
      await _saveImageToDirectory(dcimDir, fileName, imageBytes);
      return;
    }

    // إذا فشل، جرب مجلد Pictures
    final picturesDir = Directory('/storage/emulated/0/Pictures');
    if (await picturesDir.exists()) {
      await _saveImageToDirectory(picturesDir, fileName, imageBytes);
      return;
    }

    _showErrorSnackbar('Error', 'Could not access storage directories');
  }

  /// حفظ الصورة في مجلد محدد
  Future<void> _saveImageToDirectory(Directory directory, String fileName, List<int> imageBytes) async {
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(imageBytes);
    _showSuccessSnackbar('Success', _downloadSuccessMessage);
  }

  /// عرض رسالة التحميل
  void _showDownloadingSnackbar() {
    Get.snackbar(
      'Downloading...',
      'Please wait while downloading the image',
      duration: const Duration(seconds: 2),
    );
  }

  /// عرض رسالة نجاح
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  /// عرض رسالة خطأ
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  /// اختيار صورة من المعرض
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      rethrow;
    }
  }

  /// التقاط صورة بالكاميرا
  Future<XFile?> takePhotoWithCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      rethrow;
    }
  }
} 