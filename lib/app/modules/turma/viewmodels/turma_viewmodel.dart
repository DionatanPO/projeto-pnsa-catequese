import 'package:get/get.dart';
import '../models/turma_model.dart';
import '../../catequizandos/models/catequizando_model.dart';

class TurmaViewModel extends GetxController {
  final RxList<TurmaModel> turmas = [
    TurmaModel(id: '1', nome: 'Cordeirinhos 4 anos', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Sábado, 09:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Primeiros passos na oração, o amor de Jesus pelos pequeninos e a criação.'),
    TurmaModel(id: '2', nome: 'Cordeirinhos 04 a 08 anos', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Domingo, 10:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Grupo de integração: vivência comunitária e musicalização litúrgica.'),
    TurmaModel(id: '3', nome: 'Cordeirinhos 05 anos (Seg)', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Segunda, 14:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'O bom Pastor, a família e a oração do Pai-Nosso.'),
    TurmaModel(id: '4', nome: 'Cordeirinhos 05 anos (Ter)', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Terça, 14:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'O bom Pastor, a família e a oração do Pai-Nosso.'),
    TurmaModel(id: '5', nome: 'Cordeirinhos 06 anos', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Sábado, 10:30', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Os Mandamentos do Amor e o exemplo dos Santos.'),
    TurmaModel(id: '6', nome: 'Cordeirinhos 06 e 07 anos', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Sábado, 10:30', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'A Bíblia como história de amor e os amigos de Jesus.'),
    TurmaModel(id: '7', nome: 'Cordeirinhos 07 anos', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Sábado, 10:30', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'O nascimento, a vida e a missão de Jesus.'),
    TurmaModel(id: '8', nome: 'Cordeirinhos 08 anos (Seg)', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Segunda, 16:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Introdução aos sacramentos e a importância da Missa.'),
    TurmaModel(id: '9', nome: 'Cordeirinhos 08 anos (Ter)', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Terça, 16:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Introdução aos sacramentos e a importância da Missa.'),
    TurmaModel(id: '10', nome: 'Primeira Eucaristia 1', ano: 2026, etapa: 'Iniciação Eucarística', diaHorario: 'Sábado, 08:30', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Iniciação à vida de oração, estudo dos Mandamentos e o perdão (Confissão).'),
    TurmaModel(id: '11', nome: 'Primeira Eucaristia 2', ano: 2026, etapa: 'Iniciação Eucarística', diaHorario: 'Sábado, 08:30', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Preparação final para o encontro com Jesus Eucarístico (Missa e comunhão).'),
    TurmaModel(id: '12', nome: 'Perseverança', ano: 2026, etapa: 'Perseverança', diaHorario: 'Domingo, 09:30', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Fortalecimento do vínculo com a paróquia após a Eucaristia e serviço missionário.'),
    TurmaModel(id: '13', nome: 'Crisma 1', ano: 2026, etapa: 'Crisma', diaHorario: 'Domingo, 18:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'O Espírito Santo, o Credo e a identidade do cristão na sociedade.'),
    TurmaModel(id: '14', nome: 'Crisma 2', ano: 2026, etapa: 'Crisma', diaHorario: 'Domingo, 18:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'O compromisso missionário, os dons do Espírito e a vida em comunidade.'),
    TurmaModel(id: '15', nome: 'Catequese de Adultos', ano: 2026, etapa: 'Catequese de Adultos', diaHorario: 'Quarta-feira, 20:00', localSala: '', capacidade: 30, status: 'Ativa', catequista: 'A definir', observacoes: 'Formação doutrinária básica para quem busca os Sacramentos de Iniciação ou deseja retomar a vida na fé.'),
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
