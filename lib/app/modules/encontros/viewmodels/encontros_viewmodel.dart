import 'dart:async';
import 'package:get/get.dart';
import '../models/encontro_model.dart';
import '../models/chamada_model.dart';
import '../repositories/encontros_repository.dart';
import '../repositories/chamada_repository.dart';
import '../../turma/models/turma_model.dart';

typedef EncontroItem = ({Encontro encontro, String turmaNome});

class EncontrosViewModel extends GetxController {
  final EncontrosRepository _repository;
  final ChamadaRepository chamadaRepo;

  final RxList<Encontro> encontros = <Encontro>[].obs;
  final RxString searchQuery = ''.obs;
  final RxList<EncontroItem> _allItems = <EncontroItem>[].obs;
  List<EncontroItem> get allItems => _allItems;
  final RxInt currentPage = 0.obs;
  final RxInt sortColumn = (-1).obs;
  final RxBool sortAscending = true.obs;

  int pageSize = 25;
  Timer? _debounce;

  final RxInt calendarMonth = DateTime.now().month.obs;
  final RxInt calendarYear = DateTime.now().year.obs;
  final RxString selectedTurmaId = ''.obs;

  void nextMonth() {
    if (calendarMonth.value == 12) {
      calendarMonth.value = 1;
      calendarYear.value++;
    } else {
      calendarMonth.value++;
    }
    update(['calendar']);
  }

  void prevMonth() {
    if (calendarMonth.value == 1) {
      calendarMonth.value = 12;
      calendarYear.value--;
    } else {
      calendarMonth.value--;
    }
    update(['calendar']);
  }

  List<({Encontro encontro, bool temChamada, String turmaNome})> encontrosDoMes({String? turmaId}) {
    final result = <({Encontro encontro, bool temChamada, String turmaNome})>[];
    for (final e in encontros) {
      if (e.data.year == calendarYear.value && e.data.month == calendarMonth.value) {
        if (turmaId == null || e.turmaId == turmaId) {
          final nome = _turmas?.firstWhereOrNull((t) => t.id == e.turmaId)?.nome ?? '';
          result.add((
            encontro: e,
            temChamada: chamadaRepo.getByEncontro(e.id).isNotEmpty,
            turmaNome: nome,
          ));
        }
      }
    }
    return result;
  }

  List<DateTime> diasComEncontroNoMes({String? turmaId}) {
    final dias = <DateTime>{};
    for (final e in encontros) {
      if (e.data.year == calendarYear.value && e.data.month == calendarMonth.value) {
        if (turmaId == null || e.turmaId == turmaId) {
          dias.add(DateTime(e.data.year, e.data.month, e.data.day));
        }
      }
    }
    return dias.toList()..sort();
  }

  Map<DateTime, bool> statusChamadaPorDia({String? turmaId}) {
    final map = <DateTime, bool>{};
    for (final e in encontros) {
      if (e.data.year == calendarYear.value && e.data.month == calendarMonth.value) {
        if (turmaId == null || e.turmaId == turmaId) {
          final dia = DateTime(e.data.year, e.data.month, e.data.day);
          final chamadas = chamadaRepo.getByEncontro(e.id);
          if (!map.containsKey(dia) || chamadas.isNotEmpty) {
            map[dia] = chamadas.isNotEmpty;
          }
        }
      }
    }
    return map;
  }

  EncontrosViewModel({EncontrosRepository? repository, ChamadaRepository? chamadaRepository})
      : _repository = repository ?? EncontrosRepository(),
        chamadaRepo = chamadaRepository ?? ChamadaRepository() {
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await _repository.getAll();
    encontros.value = list;
    await chamadaRepo.loadAll();
    update(['calendar']);
  }

  List<TurmaModel>? _turmas;

  void rebuildList(List<TurmaModel> turmas) {
    _turmas = turmas;
    _rebuildItems();
  }

  void _rebuildItems() {
    if (_turmas == null) return;
    final items = <EncontroItem>[];
    for (final t in _turmas!) {
      for (final e in encontros.where((e) => e.turmaId == t.id)) {
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
    update(['encontros']);
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
    return encontros.where((e) => e.turmaId == turmaId).toList();
  }

  Encontro? encontroDoDia(String turmaId, DateTime data) {
    return encontros.firstWhereOrNull(
      (e) => e.turmaId == turmaId && e.data == data,
    );
  }

  List<Chamada> chamadasDoDia(String turmaId, DateTime data) {
    final encontro = encontroDoDia(turmaId, data);
    if (encontro == null) return [];
    return chamadaRepo.getByEncontro(encontro.id);
  }

  bool? frequenciaAluno(String turmaId, DateTime data, String catequizandoId) {
    final chamadas = chamadasDoDia(turmaId, data);
    final c = chamadas.firstWhereOrNull((c) => c.catequizandoId == catequizandoId);
    return c?.presente;
  }

  Future<void> salvarFrequencias(String turmaId, DateTime data, List<Chamada> chamadas, {String descricao = ''}) async {
    final encontro = await _repository.criarOuObterEncontro(turmaId, data);
    if (descricao.isNotEmpty && encontro.descricao != descricao) {
      await _repository.update(Encontro(
        id: encontro.id,
        turmaId: turmaId,
        data: data,
        descricao: descricao,
      ));
    }
    await chamadaRepo.salvarEncontro(encontro.id, chamadas);
    await _loadData();
    _rebuildItems();
    update(['encontros']);
  }

  int presentesNoDia(String turmaId, String dia, int total) {
    final date = DateTime.parse(dia);
    final chamadas = chamadasDoDia(turmaId, date);
    return chamadas.where((c) => c.presente).length;
  }

  int totalPresencasEncontro(String encontroId) {
    return chamadaRepo.getByEncontro(encontroId).where((c) => c.presente).length;
  }

  int totalChamadasEncontro(String encontroId) {
    return chamadaRepo.getByEncontro(encontroId).length;
  }

  Future<int> criarEncontrosRecorrentes({
    required String turmaId,
    required DateTime dataInicio,
    required DateTime dataFim,
    required String descricao,
    required String recorrencia,
  }) async {
    final datas = <DateTime>[];
    var current = DateTime(dataInicio.year, dataInicio.month, dataInicio.day);
    final end = DateTime(dataFim.year, dataFim.month, dataFim.day);

    while (!current.isAfter(end)) {
      final exists = encontros.any(
        (e) => e.turmaId == turmaId && e.data == current,
      );
      if (!exists) {
        datas.add(current);
      }
      switch (recorrencia) {
        case 'Diário':
          current = current.add(const Duration(days: 1));
          break;
        case 'Semanal':
          current = current.add(const Duration(days: 7));
          break;
        case 'Anual':
          current = DateTime(current.year + 1, current.month, current.day);
          break;
        default:
          current = end.add(const Duration(days: 1));
      }
    }

    if (datas.isEmpty) return 0;

    final novosEncontros = datas.map((d) => Encontro(
      id: '',
      turmaId: turmaId,
      data: d,
      descricao: descricao,
    )).toList();

    await _repository.addAll(novosEncontros);
    await _loadData();
    _rebuildItems();
    update(['encontros']);
    return encontros.length;
  }

  Future<bool> criarEncontro(String turmaId, DateTime data, String descricao) async {
    if (encontroDoDia(turmaId, data) != null) return false;
    await _repository.add(Encontro(
      id: '',
      turmaId: turmaId,
      data: data,
      descricao: descricao,
    ));
    await _loadData();
    _rebuildItems();
    update(['encontros']);
    return true;
  }

  Future<void> atualizarEncontro(Encontro encontro) async {
    await _repository.update(encontro);
    await _loadData();
    _rebuildItems();
    update(['encontros']);
  }

  Future<void> removerEncontro(Encontro encontro) async {
    await chamadaRepo.deletarPorEncontro(encontro.id);
    await _repository.remove(encontro);
    await _loadData();
    _rebuildItems();
    update(['encontros']);
  }
}
