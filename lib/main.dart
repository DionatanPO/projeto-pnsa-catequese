import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app/core/controllers/auth_controller.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final user = FirebaseAuth.instance.currentUser;
  runApp(MainApp(isLoggedIn: user != null));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;

  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController(), permanent: true);

    return GetMaterialApp(
      title: 'PNSA Catequese',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.expressiveLight,
      darkTheme: AppTheme.expressiveDark,
      themeMode: ThemeMode.light,
      initialRoute: isLoggedIn ? AppRoutes.home : AppRoutes.login,
      getPages: AppPages.pages,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      locale: const Locale('pt', 'BR'),
    );
  }
}
