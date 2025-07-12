import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp_clone/core/interfaces/status_repository_interface.dart';
import 'package:whatsapp_clone/core/repositories/status_repository.dart';
import 'package:whatsapp_clone/view_model/controllers/status_controller.dart';

class StatusBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<IStatusRepository>(() => StatusRepository());
    
    // Controller
    Get.lazyPut<StatusController>(() {
      final repository = Get.find<IStatusRepository>();
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      return StatusController(
        repository: repository,
        currentUserId: currentUserId,
      );
    });
  }
} 