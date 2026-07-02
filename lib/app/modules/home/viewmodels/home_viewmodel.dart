import 'package:get/get.dart';
import '../models/home_model.dart';
import '../../catequista/viewmodels/catequista_viewmodel.dart';
import '../../turma/viewmodels/turma_viewmodel.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../../relatorio/viewmodels/relatorio_viewmodel.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';
import '../../encontros/viewmodels/encontros_viewmodel.dart';

class HomeViewModel extends GetxController {
  final Rx<HomeModel> data = HomeModel(title: 'Início').obs;
  final RxInt counter = 0.obs;
  int _selectedIndex = 0;
  final catequistaVm = CatequistaViewModel();
  final turmaVm = Get.put(TurmaViewModel());
  final catequizandoVm = CatequizandoViewModel();
  final encontrosVm = EncontrosViewModel();
  final relatorioVm = RelatorioViewModel();
  final profileVm = ProfileViewModel();

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    _selectedIndex = value;
    update(['selectedIndex']);
  }

  void increment() => counter.value++;
}
