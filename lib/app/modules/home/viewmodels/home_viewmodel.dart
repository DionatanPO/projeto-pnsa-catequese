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

  int get avisosCount {
    final mesAtual = DateTime.now().month;
    final catequistas = catequistaVm.data.value.catequistas;
    final birthdays = catequistas.where((c) {
      final parts = c.dataNascimento.split('/');
      if (parts.length != 3) return false;
      return int.tryParse(parts[1]) == mesAtual;
    }).length;

    final alunos = catequizandoVm.catequizandos
        .where((a) => a.status == 'Em Andamento')
        .toList();

    if (alunos.isEmpty) return birthdays;

    final Map<String, List<String>> alunosPorTurma = {};
    for (final a in alunos) {
      final turmaId = matriculaVm.getTurmaAtualId(a.id);
      if (turmaId != null) {
        alunosPorTurma.putIfAbsent(turmaId, () => []).add(a.id);
      }
    }

    int baixaFrequencia = 0;

    for (final entry in alunosPorTurma.entries) {
      final turmaId = entry.key;
      final alunoIds = entry.value;
      final encontros = encontrosVm.encontrosDaTurma(turmaId);

      if (encontros.isEmpty) continue;

      for (final alunoId in alunoIds) {
        int presentes = 0;
        int totalChamadas = 0;

        for (final e in encontros) {
          final chamadas = encontrosVm.chamadaRepo.getByEncontro(e.id);
          final c = chamadas.firstWhereOrNull((c) => c.catequizandoId == alunoId);
          if (c != null) {
            totalChamadas++;
            if (c.presente) presentes++;
          }
        }

        if (totalChamadas > 0) {
          final freq = (presentes / totalChamadas) * 100;
          if (freq < 75) baixaFrequencia++;
        }
      }
    }

    return birthdays + baixaFrequencia;
  }
}
