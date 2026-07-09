import 'dart:async';
import 'package:get/get.dart';
import '../models/encontro_model.dart';
import '../models/frequencia_model.dart';
import '../repositories/encontros_repository.dart';
import '../../turma/models/turma_model.dart';

typedef EncontroItem = ({Encontro encontro, String turmaNome});

class EncontrosViewModel extends GetxController {
  final EncontrosRepository _repository;

  final RxList<Encontro> encontros = <Encontro>[].obs;
  final RxString searchQuery = ''.obs;
  final RxList<EncontroItem> _allItems = <EncontroItem>[].obs;
  List<EncontroItem> get allItems => _allItems;
  final RxInt currentPage = 0.obs;
  final RxInt sortColumn = (-1).obs;
  final RxBool sortAscending = true.obs;

  int pageSize = 25;
  Timer? _debounce;

  EncontrosViewModel({EncontrosRepository? repository})
      : _repository = repository ?? EncontrosRepository() {
    _loadData();
  }

  void _loadData() {
    encontros.value = _repository.getAll();
  }

  void rebuildList(List<TurmaModel> turmas) {
    final items = <EncontroItem>[];
    for (final t in turmas) {
      for (final e in _repository.encontrosDaTurma(t.id)) {
        items.add((encontro: e, turmaNome: t.nome));
      }
    }
    items.sort((a, b) => b.encontro.data.compareTo(a.encontro.data));
    _allItems.value = items;
    currentPage.value = 0;
  }

  List<EncontroItem> get paginatedItems {
    var list = _allItems as List<EncontroItem>;

    final query = searchQuery.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      list = list.where((item) =>
        item.turmaNome.toLowerCase().contains(query) ||
        item.encontro.descricao.toLowerCase().contains(query) ||
        '${item.encontro.data.day.toString().padLeft(2, '0')}/${item.encontro.data.month.toString().padLeft(2, '0')}/${item.encontro.data.year}'.contains(query)
      ).toList();
    }

    if (sortColumn.value >= 0) {
      list = List<EncontroItem>.from(list);
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

  String _sortKey(EncontroItem item) {
    switch (sortColumn.value) {
      case 0:
        final d = item.encontro.data;
        return '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
      case 1: return item.turmaNome;
      case 2: return item.encontro.descricao;
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
    if (query.isEmpty) return _allItems.length;
    return _allItems.where((item) =>
      item.turmaNome.toLowerCase().contains(query) ||
      item.encontro.descricao.toLowerCase().contains(query) ||
      '${item.encontro.data.day.toString().padLeft(2, '0')}/${item.encontro.data.month.toString().padLeft(2, '0')}/${item.encontro.data.year}'.contains(query)
    ).length;
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
      update(['encontros']);
      return;
    }
    _debounce?.cancel();
    final query = value;
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query;
      currentPage.value = 0;
      update(['encontros']);
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  List<Encontro> encontrosDaTurma(String turmaId) {
    return _repository.encontrosDaTurma(turmaId);
  }

  Encontro? encontroDoDia(String turmaId, DateTime data) {
    return _repository.encontroDoDia(turmaId, data);
  }

  List<Frequencia> frequenciasDoDia(String turmaId, DateTime data) {
    final encontro = encontroDoDia(turmaId, data);
    return encontro?.frequencias ?? [];
  }

  bool? frequenciaAluno(String turmaId, DateTime data, String catequizandoId) {
    final frequencias = frequenciasDoDia(turmaId, data);
    final f = frequencias.firstWhereOrNull((f) => f.catequizandoId == catequizandoId);
    return f?.presente;
  }

  Future<void> salvarFrequencias(String turmaId, DateTime data, List<Frequencia> novasFrequencias) async {
    final encontro = await _repository.criarOuObterEncontro(turmaId, data);
    encontro.frequencias
      ..clear()
      ..addAll(novasFrequencias);
    _loadData();
    encontros.refresh();
  }

  int presentesNoDia(String turmaId, String dia, int total) {
    final date = DateTime.parse(dia);
    final presencas = frequenciasDoDia(turmaId, date);
    return presencas.where((f) => f.presente).length;
  }

  Future<bool> criarEncontro(String turmaId, DateTime data, String descricao) async {
    if (encontroDoDia(turmaId, data) != null) return false;
    await _repository.add(Encontro(
      id: '${turmaId}_${data.toIso8601String()}',
      data: data,
      descricao: descricao,
    ));
    _loadData();
    return true;
  }

  Future<void> atualizarEncontro(Encontro encontro, String descricao) async {
    await _repository.update(Encontro(
      id: encontro.id,
      data: encontro.data,
      descricao: descricao,
      frequencias: encontro.frequencias,
    ));
    _loadData();
    encontros.refresh();
  }

  Future<void> removerEncontro(Encontro encontro) async {
    await _repository.remove(encontro);
    _loadData();
  }
}
