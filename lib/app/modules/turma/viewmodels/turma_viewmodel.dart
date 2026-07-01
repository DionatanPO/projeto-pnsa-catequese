import 'package:get/get.dart';
import '../models/turma_model.dart';

class TurmaViewModel extends GetxController {
  final RxList<TurmaModel> turmas = [
    TurmaModel(nome: '1ª Eucaristia - A', totalCatequizandos: 18, horario: 'Sábado 08:00', catequista: 'Maria José Silva'),
    TurmaModel(nome: '1ª Eucaristia - B', totalCatequizandos: 20, horario: 'Sábado 10:00', catequista: 'João Pedro Santos'),
    TurmaModel(nome: '2ª Eucaristia - A', totalCatequizandos: 16, horario: 'Domingo 08:00', catequista: 'Ana Clara Oliveira'),
    TurmaModel(nome: '2ª Eucaristia - B', totalCatequizandos: 19, horario: 'Domingo 10:00', catequista: 'Carlos Eduardo Lima'),
    TurmaModel(nome: 'Crisma - A', totalCatequizandos: 22, horario: 'Sábado 14:00', catequista: 'Lucia Aparecida Souza'),
    TurmaModel(nome: 'Crisma - B', totalCatequizandos: 17, horario: 'Sábado 16:00', catequista: 'Pedro Henrique Costa'),
    TurmaModel(nome: 'Batismo', totalCatequizandos: 14, horario: 'Terça 19:00', catequista: 'Rita de Cássia Pereira'),
    TurmaModel(nome: 'Perseverança', totalCatequizandos: 16, horario: 'Quinta 19:00', catequista: 'Antônio Carlos Gomes'),
  ].obs;

  final RxString searchQuery = ''.obs;

  List<TurmaModel> get filteredTurmas {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return turmas;
    return turmas.where((t) =>
      t.nome.toLowerCase().contains(query) ||
      t.catequista.toLowerCase().contains(query) ||
      t.horario.toLowerCase().contains(query)
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
}
