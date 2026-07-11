import 'dart:async';
import 'package:get/get.dart';
import '../models/catequista_model.dart';
import '../repositories/catequista_repository.dart';

class CatequistaViewModel extends GetxController {
  final CatequistaRepository _repository;

  final Rx<CatequistaModel> data = CatequistaModel().obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 0.obs;
  final RxInt sortColumn = (-1).obs;
  final RxBool sortAscending = true.obs;

  int pageSize = 25;
  Timer? _debounce;

  CatequistaViewModel({CatequistaRepository? repository})
      : _repository = repository ?? CatequistaRepository() {
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await _repository.getAll();
    data.value = CatequistaModel(
      totalTurmas: 8,
      totalCatequizandos: 142,
      totalCatequistas: list.length,
      catequistas: list,
    );
  }

  List<Catequista> get paginatedCatequistas {
    var list = data.value.catequistas;

    final query = searchQuery.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      list = list.where((c) =>
        c.nome.toLowerCase().contains(query)
      ).toList();
    }

    if (sortColumn.value >= 0) {
      list = List<Catequista>.from(list);
      list.sort((a, b) {
        final ka = _sortKey(a);
        final kb = _sortKey(b);
        return sortAscending.value ? ka.compareTo(kb) : kb.compareTo(ka);
      });
    }

    final start = currentPage.value * pageSize;
    final end = (start + pageSize).clamp(0, list.length);
    if (start >= list.length) return [];
    return list.sublist(start, end);
  }

  String _sortKey(Catequista c) {
    switch (sortColumn.value) {
      case 1: return c.nome;
      case 2: return c.status;
      case 3: return c.email;
      case 4: return c.telefone;
      default: return '';
    }
  }

  int get totalPages {
    final count = _totalCount;
    if (count == 0) return 0;
    return (count / pageSize).ceil();
  }

  int get _totalCount {
    final query = searchQuery.value.toLowerCase().trim();
    final list = data.value.catequistas;
    if (query.isEmpty) return list.length;
    return list.where((c) => c.nome.toLowerCase().contains(query)).length;
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

  Future<void> addCatequista(Catequista c) async {
    await _repository.add(c);
    await _loadData();
  }

  Future<void> updateCatequista(Catequista c) async {
    await _repository.update(c);
    await _loadData();
  }

  Future<void> removeCatequista(String id) async {
    await _repository.remove(id);
    await _loadData();
  }
}
