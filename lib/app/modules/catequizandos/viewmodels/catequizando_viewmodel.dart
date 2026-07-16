import 'dart:async';
import 'package:get/get.dart';
import '../models/catequizando_model.dart';
import '../repositories/catequizando_repository.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../../turma/viewmodels/turma_viewmodel.dart';
import '../../turma/models/turma_model.dart';

class CatequizandoViewModel extends GetxController {
  final CatequizandoRepository _repository;

  final RxList<Catequizando> catequizandos = <Catequizando>[].obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 0.obs;
  final RxInt sortColumn = (-1).obs;
  final RxBool sortAscending = true.obs;

  final RxString filterStatus = 'Todos'.obs;
  // Filtros de sacramentos: 'Todos', 'Pendente Batismo', 'Pendente Eucaristia', 'Pendente Crisma'
  final RxString filterSacramento = 'Todos'.obs;

  int pageSize = 25;
  Timer? _debounce;

  CatequizandoViewModel({CatequizandoRepository? repository})
      : _repository = repository ?? CatequizandoRepository() {
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await _repository.getAll();
    catequizandos.value = list;
  }

  List<Catequizando> get filteredCatequizandos {
    var list = catequizandos as List<Catequizando>;

    // 1. Filtro por status
    if (filterStatus.value != 'Todos') {
      list = list.where((a) => a.status == filterStatus.value).toList();
    }

    // 2. Filtro por sacramento pendente
    if (filterSacramento.value != 'Todos') {
      list = list.where((a) {
        if (filterSacramento.value == 'Pendente Batismo') {
          return !a.batizado;
        } else if (filterSacramento.value == 'Pendente Eucaristia') {
          return a.fezPrimeiraEucaristia != true;
        } else if (filterSacramento.value == 'Pendente Crisma') {
          return a.fezCrisma != true;
        }
        return true;
      }).toList();
    }

    // 3. Filtro por query de busca
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      final matriculaVm = Get.find<MatriculaViewModel>();
      final turmas = Get.find<TurmaViewModel>().turmas;
      list = list.where((a) {
        final turmaAtual = matriculaVm.getNomeTurmaAtual(a.id, turmas) ?? '';
        return a.nome.toLowerCase().contains(query) ||
            turmaAtual.toLowerCase().contains(query) ||
            a.responsavel.toLowerCase().contains(query);
      }).toList();
    }

    // 4. Ordenação
    if (sortColumn.value >= 0) {
      final matriculaVm = Get.find<MatriculaViewModel>();
      final turmas = Get.find<TurmaViewModel>().turmas;
      list = List<Catequizando>.from(list);
      list.sort((a, b) {
        final ka = _sortKey(a, matriculaVm, turmas);
        final kb = _sortKey(b, matriculaVm, turmas);
        return sortAscending.value ? ka.compareTo(kb) : kb.compareTo(ka);
      });
    }

    return list;
  }

  List<Catequizando> get paginatedCatequizandos {
    final list = filteredCatequizandos;
    final start = currentPage.value * pageSize;
    final end = (start + pageSize).clamp(0, list.length);
    if (start >= list.length) return [];
    return list.sublist(start, end);
  }

  String _sortKey(Catequizando a, MatriculaViewModel matriculaVm, List<TurmaModel> turmas) {
    switch (sortColumn.value) {
      case 1: return a.nome;
      case 2: return matriculaVm.getNomeTurmaAtual(a.id, turmas) ?? '';
      case 3: return a.status;
      case 4: return a.dataNascimento.toIso8601String();
      default: return '';
    }
  }

  int get totalPages {
    final count = _totalCount;
    if (count == 0) return 0;
    return (count / pageSize).ceil();
  }

  int get _totalCount {
    return filteredCatequizandos.length;
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

  Future<String> addCatequizando(Catequizando c) async {
    final id = await _repository.add(c);
    _loadData();
    return id;
  }

  Future<void> updateCatequizando(Catequizando c) async {
    await _repository.update(c);
    _loadData();
  }

  Future<void> removeCatequizando(String id) async {
    await _repository.remove(id);
    _loadData();
  }
}
