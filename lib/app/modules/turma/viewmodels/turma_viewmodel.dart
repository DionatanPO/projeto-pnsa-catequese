import 'dart:async';
import 'package:get/get.dart';
import '../models/turma_model.dart';
import '../../catequizandos/models/catequizando_model.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../../encontros/repositories/encontros_repository.dart';
import '../../encontros/repositories/chamada_repository.dart';
import '../repositories/turma_repository.dart';

class TurmaViewModel extends GetxController {
  final TurmaRepository _repository;

  final RxList<TurmaModel> turmas = <TurmaModel>[].obs;
  List<TurmaModel> get turmasAtivas => turmas.where((t) => t.status == 'Ativa').toList();
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 0.obs;
  final RxInt sortColumn = (-1).obs;
  final RxBool sortAscending = true.obs;

  final RxString filterStatus = 'Todos'.obs;

  int pageSize = 25;
  Timer? _debounce;

  TurmaViewModel({TurmaRepository? repository})
      : _repository = repository ?? TurmaRepository() {
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await _repository.getAll();
    turmas.value = list;
  }

  List<TurmaModel> get filteredTurmas {
    var list = turmas.toList();

    // Filtro de Status
    if (filterStatus.value != 'Todos') {
      list = list.where((t) => t.status == filterStatus.value).toList();
    }

    // Filtro por busca
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      list = list.where((t) =>
        t.nome.toLowerCase().contains(query) ||
        t.catequistas.any((c) => c.toLowerCase().contains(query)) ||
        t.diaHorario.toLowerCase().contains(query) ||
        t.etapa.toLowerCase().contains(query)
      ).toList();
    }

    // Ordenação
    if (sortColumn.value >= 0) {
      list = List<TurmaModel>.from(list);
      list.sort((a, b) {
        final ka = _sortKey(a);
        final kb = _sortKey(b);
        return sortAscending.value ? ka.compareTo(kb) : kb.compareTo(ka);
      });
    }

    return list;
  }

  List<TurmaModel> get paginatedTurmas {
    final list = filteredTurmas;
    final start = currentPage.value * pageSize;
    final end = (start + pageSize).clamp(0, list.length);
    if (start >= list.length) return [];
    return list.sublist(start, end);
  }

  String _sortKey(TurmaModel t) {
    switch (sortColumn.value) {
      case 0: return t.nome;
      case 1: return t.catequistas.join(', ');
      case 2: return t.diaHorario;
      case 3: return t.status;
      case 4: return Get.find<MatriculaViewModel>().totalAlunosNaTurma(t.id).toString().padLeft(6, '0');
      case 5: return t.observacoes ?? '';
      default: return '';
    }
  }

  int get totalPages {
    final count = _totalCount;
    if (count == 0) return 0;
    return (count / pageSize).ceil();
  }

  int get _totalCount {
    return filteredTurmas.length;
  }

  void sortBy(int column) {
    if (sortColumn.value == column) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortColumn.value = column;
      sortAscending.value = true;
    }
    currentPage.value = 0;
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      currentPage.value++;
    }
  }

  void prevPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page < totalPages) {
      currentPage.value = page;
    }
  }

  void setSearch(String value) {
    if (value.isEmpty) {
      _debounce?.cancel();
      searchQuery.value = '';
      currentPage.value = 0;
      return;
    }
    _debounce?.cancel();
    final query = value;
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query;
      currentPage.value = 0;
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<String?> addTurma(TurmaModel turma) async {
    final exists = await _repository.existsByName(turma.nome);
    if (exists) return 'Já existe uma turma com este nome.';
    await _repository.add(turma);
    await _loadData();
    return null;
  }

  Future<String?> updateTurma(TurmaModel turma) async {
    final exists = await _repository.existsByName(turma.nome, excludeId: turma.id);
    if (exists) return 'Já existe outra turma com este nome.';
    await _repository.update(turma);
    await _loadData();
    return null;
  }

  Future<void> removeTurma(String id) async {
    final encontrosRepo = EncontrosRepository();
    final chamadaRepo = ChamadaRepository();
    final encontros = await encontrosRepo.encontrosDaTurma(id);
    for (final e in encontros) {
      await chamadaRepo.deletarPorEncontro(e.id);
      await encontrosRepo.remove(e);
    }
    await _repository.remove(id);
    await _loadData();
  }

  List<Catequizando> alunosDaTurma(String turmaId, List<Catequizando> todos) {
    final matriculaVm = Get.find<MatriculaViewModel>();
    return matriculaVm.getAlunosDaTurma(turmaId, todos);
  }

  int totalAlunosTurma(String turmaId) {
    final matriculaVm = Get.find<MatriculaViewModel>();
    return matriculaVm.totalAlunosNaTurma(turmaId);
  }
}
