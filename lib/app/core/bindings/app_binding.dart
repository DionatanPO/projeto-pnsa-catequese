import 'package:get/get.dart';
import '../../modules/home/viewmodels/home_viewmodel.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeViewModel>(() => HomeViewModel());
  }
}
