import 'package:get/get.dart';
import '../models/profile_model.dart';
import '../../../routes/app_pages.dart';

class ProfileViewModel extends GetxController {
  final Rx<ProfileModel> profile = ProfileModel(
    name: 'Administrador',
    email: 'admin@pnsa.com',
    role: 'Catequista',
  ).obs;

  void logout() {
    Get.offAllNamed(AppRoutes.login);
  }
}
