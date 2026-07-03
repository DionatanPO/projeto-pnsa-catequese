import 'package:get/get.dart';
import '../models/turma_model.dart';
import '../../catequizandos/models/catequizando_model.dart';
import '../repositories/turma_repository.dart';

class TurmaViewModel extends GetxController {
  final TurmaRepository _repository;

  final RxList<TurmaModel> turmas = <TurmaModel>[].obs;
  final RxString searchQuery = ''.obs;

  TurmaViewModel({TurmaRepository? repository})
      : _repository = repository ?? TurmaRepository() {
    _loadData();
  }

  void _loadData() {
    turmas.value = _repository.getAll();
  }

  List<TurmaModel> get filteredTurmas {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return turmas;
    return turmas.where((t) =>
      t.nome.toLowerCase().contains(query) ||
      t.catequista.toLowerCase().contains(query) ||
      t.diaHorario.toLowerCase().contains(query) ||
      t.etapa.toLowerCase().contains(query)
    ).toList();
  }

  void setSearch(String value) {
    searchQuery.value = value;
    update(['turmas']);
  }

  Future<void> addTurma(TurmaModel turma) async {
    await _repository.add(turma);
    _loadData();
    update(['turmas']);
  }

  Future<void> updateTurma(TurmaModel turma) async {
    await _repository.update(turma);
    _loadData();
    update(['turmas']);
  }

  Future<void> removeTurma(String id) async {
    await _repository.remove(id);
    _loadData();
    update(['turmas']);
  }

  List<Catequizando> alunosDaTurma(String turmaNome, List<Catequizando> todos) {
    return todos.where((a) => a.turmaNome == turmaNome).toList();
  }

  int totalAlunosTurma(String turmaNome, List<Catequizando> todos) {
    return alunosDaTurma(turmaNome, todos).length;
  }
}
