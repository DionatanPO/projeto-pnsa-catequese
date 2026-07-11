import 'package:get/get.dart';
import '../../../core/controllers/auth_controller.dart';
import '../models/profile_model.dart';

class ProfileViewModel extends GetxController {
  final Rx<ProfileModel> profile = ProfileModel(
    name: '---',
    email: '---',
    role: '---',
  ).obs;

  @override
  void onInit() {
    super.onInit();
    ever(Get.find<AuthController>().firestoreUser, (_) => _loadProfile());
    _loadProfile();
  }

  void _loadProfile() {
    final u = Get.find<AuthController>().firestoreUser.value;
    if (u == null) return;
    profile.value = ProfileModel(
      name: u.nome,
      email: u.email,
      role: _roleLabel(u.role),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'administrador':
        return 'Administrador';
      case 'coordenador':
        return 'Coordenador';
      default:
        return 'Catequista';
    }
  }

  void logout() {
    Get.find<AuthController>().logout();
  }
}
