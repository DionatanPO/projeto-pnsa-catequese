import 'package:get/get.dart';
import '../models/encontro_model.dart';
import '../models/frequencia_model.dart';
import '../repositories/encontros_repository.dart';

class EncontrosViewModel extends GetxController {
  final EncontrosRepository _repository;

  final RxList<Encontro> encontros = <Encontro>[].obs;
  final RxString searchQuery = ''.obs;

  EncontrosViewModel({EncontrosRepository? repository})
      : _repository = repository ?? EncontrosRepository() {
    _loadData();
  }

  void _loadData() {
    encontros.value = _repository.getAll();
  }

  void setSearch(String value) {
    searchQuery.value = value;
    update(['encontros']);
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
