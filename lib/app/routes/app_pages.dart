import 'package:get/get.dart';
import '../core/middlewares/auth_middleware.dart';
import '../core/middlewares/guest_middleware.dart';
import '../modules/home/views/home_page.dart';
import '../modules/login/views/login_page.dart';

part 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
