import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}
