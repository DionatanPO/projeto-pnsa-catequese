import 'package:get/get.dart';
import '../models/turma_model.dart';
import '../../catequizandos/models/catequizando_model.dart';

class TurmaViewModel extends GetxController {
  final RxList<TurmaModel> turmas = [
    TurmaModel(
        id: '1',
        nome: '1ª Eucaristia - A',
        ano: 2026,
        etapa: 'Eucaristia',
        diaHorario: 'Sábado 08:00',
        localSala: 'Sala 01',
        capacidade: 20,
        status: 'Ativa',
        catequista: 'Maria José Silva'),
  ].obs;

  final RxString searchQuery = ''.obs;

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

  void addTurma(TurmaModel turma) {
    turmas.add(turma);
    update(['turmas']);
  }

  void updateTurma(TurmaModel turma) {
    final index = turmas.indexWhere((t) => t.id == turma.id);
    if (index != -1) {
      turmas[index] = turma;
      update(['turmas']);
    }
  }

  void removeTurma(String id) {
    turmas.removeWhere((t) => t.id == id);
    update(['turmas']);
  }

  List<Catequizando> alunosDaTurma(String turmaNome, List<Catequizando> todos) {
    return todos.where((a) => a.turmaNome == turmaNome).toList();
  }

  int totalAlunosTurma(String turmaNome, List<Catequizando> todos) {
    return alunosDaTurma(turmaNome, todos).length;
  }
}
