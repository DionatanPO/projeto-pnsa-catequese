import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final Rx<User?> user = Rx<User?>(null);
  final Rx<UserModel?> firestoreUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    user.value = _authService.currentUser;
    _authService.user.listen((user) {
      this.user.value = user;
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        firestoreUser.value = null;
      }
    });
  }

  bool get isLoggedIn => user.value != null;

  Future<void> _loadUserData(String uid) async {
    final data = await _userService.getUser(uid);
    if (data != null) {
      firestoreUser.value = data;
    }
  }

  Future<void> ensureUserDocExists(String uid, String email) async {
    final existing = await _userService.getUser(uid);
    if (existing == null) {
      final newUser = UserModel(
        id: uid,
        nome: email.split('@').first,
        email: email,
      );
      await _userService.createUser(newUser);
      firestoreUser.value = newUser;
    }
  }

  Future<void> login(String email, String password) async {
    await _authService.loginWithEmail(email, password);
  }

  void logout() async {
    await _authService.logout();
    firestoreUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }
}
