import 'package:get/get.dart';
import '../../../core/controllers/auth_controller.dart';
import '../models/home_model.dart';
import '../../catequista/viewmodels/catequista_viewmodel.dart';
import '../../turma/viewmodels/turma_viewmodel.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../../relatorio/viewmodels/relatorio_viewmodel.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';
import '../../encontros/viewmodels/encontros_viewmodel.dart';
import '../../coordenadores/viewmodels/coordenador_viewmodel.dart';

class HomeViewModel extends GetxController {
  final Rx<HomeModel> data = HomeModel(title: 'Início').obs;
  final RxInt counter = 0.obs;
  int _selectedIndex = 0;
  final catequistaVm = Get.put(CatequistaViewModel());
  final turmaVm = Get.put(TurmaViewModel());
  final catequizandoVm = Get.put(CatequizandoViewModel());
  final matriculaVm = Get.put(MatriculaViewModel());
  final encontrosVm = EncontrosViewModel();
  final relatorioVm = RelatorioViewModel();
  final profileVm = ProfileViewModel();
  final coordenadorVm = CoordenadorViewModel();

  final _restrictedIndices = <int>{};

  @override
  void onInit() {
    super.onInit();
    _updateRestrictions();
    if (_restrictedIndices.contains(_selectedIndex)) {
      _selectedIndex = 0;
    }
    ever(Get.find<AuthController>().firestoreUser, (_) {
      _updateRestrictions();
      update(['selectedIndex']);
    });
  }

  bool get isAdmin => _role == 'administrador';

  bool isRestricted(int index) => _restrictedIndices.contains(index);

  String get _role {
    final user = Get.find<AuthController>().firestoreUser.value;
    return user?.role ?? '';
  }

  void _updateRestrictions() {
    _restrictedIndices.clear();
    if (_role != 'administrador') {
      _restrictedIndices.add(7);
    }
    if (_role == 'catequista') {
      _restrictedIndices.add(1);
    }
  }

  List<int> get visibleIndices {
    _updateRestrictions();
    return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        .where((i) => !_restrictedIndices.contains(i))
        .toList();
  }

  int mapVisualToActual(int visualIndex) => visibleIndices[visualIndex];

  int mapActualToVisual(int actualIndex) => visibleIndices.indexOf(actualIndex);

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int value) {
    if (_restrictedIndices.contains(value)) return;
    _selectedIndex = value;
    update(['selectedIndex']);
  }

  void increment() => counter.value++;
}
