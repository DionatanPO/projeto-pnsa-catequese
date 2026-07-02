import 'package:get/get.dart';
import '../models/encontro_model.dart';
import '../models/frequencia_model.dart';

class EncontrosViewModel extends GetxController {
  final RxList<Encontro> encontros = <Encontro>[
    Encontro(
      id: '1_2026-06-28T00:00:00.000',
      data: DateTime(2026, 6, 28),
      descricao: 'Encontro de abertura - Apresentação do cronograma',
      frequencias: [
        Frequencia(catequizandoId: '1', presente: true),
        Frequencia(catequizandoId: '2', presente: true),
        Frequencia(catequizandoId: '3', presente: false),
      ],
    ),
    Encontro(
      id: '1_2026-07-05T00:00:00.000',
      data: DateTime(2026, 7, 5),
      descricao: 'Oração do Pai Nosso',
      frequencias: [
        Frequencia(catequizandoId: '1', presente: true),
        Frequencia(catequizandoId: '2', presente: false),
        Frequencia(catequizandoId: '3', presente: true),
      ],
    ),
  ].obs;

  final RxString searchQuery = ''.obs;

  void setSearch(String value) {
    searchQuery.value = value;
    update(['encontros']);
  }

  List<Encontro> encontrosDaTurma(String turmaId) {
    return encontros.where((e) => e.id.startsWith(turmaId)).toList();
  }

  Encontro? encontroDoDia(String turmaId, DateTime data) {
    return encontros.firstWhereOrNull(
      (e) => e.id.startsWith(turmaId) && e.data == data,
    );
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

  void salvarFrequencias(String turmaId, DateTime data, List<Frequencia> novasFrequencias) {
    final encontro = _criarOuObterEncontro(turmaId, data);
    encontro.frequencias
      ..clear()
      ..addAll(novasFrequencias);
    encontros.refresh();
  }

  int presentesNoDia(String turmaId, String dia, int total) {
    final date = DateTime.parse(dia);
    final presencas = frequenciasDoDia(turmaId, date);
    return presencas.where((f) => f.presente).length;
  }

  bool criarEncontro(String turmaId, DateTime data, String descricao) {
    if (encontroDoDia(turmaId, data) != null) return false;
    encontros.add(Encontro(
      id: '${turmaId}_${data.toIso8601String()}',
      data: data,
      descricao: descricao,
    ));
    return true;
  }

  void atualizarEncontro(Encontro encontro, String descricao) {
    final idx = encontros.indexWhere((e) => e.id == encontro.id);
    if (idx != -1) {
      encontros[idx] = Encontro(
        id: encontro.id,
        data: encontro.data,
        descricao: descricao,
        frequencias: encontro.frequencias,
      );
      encontros.refresh();
    }
  }

  void removerEncontro(Encontro encontro) {
    encontros.remove(encontro);
  }

  Encontro _criarOuObterEncontro(String turmaId, DateTime data) {
    final existing = encontroDoDia(turmaId, data);
    if (existing != null) return existing;
    final novo = Encontro(
      id: '${turmaId}_${data.toIso8601String()}',
      data: data,
    );
    encontros.add(novo);
    return novo;
  }
}
