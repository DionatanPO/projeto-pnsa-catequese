import 'package:get/get.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_service.dart';
import '../models/profile_model.dart';

class ProfileViewModel extends GetxController {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

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

  Future<bool> checkEmailExists(String email) async {
    return await _authService.checkEmailExists(email);
  }

  Future<void> updateProfile({
    required String nome,
    String? email,
    String? newPassword,
  }) async {
    final uid = Get.find<AuthController>().user.value?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');

    if (newPassword != null) {
      await _authService.updateAuthPassword(newPassword);
    }

    if (email != null) {
      await _authService.updateAuthEmail(email);
    }

    await _userService.updateUser(uid, {
      'nome': nome,
      if (email != null) 'email': email,
    });
  }

  void logout() {
    Get.find<AuthController>().logout();
  }
}
