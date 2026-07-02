import 'package:get/get.dart';
import '../../catequizandos/models/catequizando_model.dart';
import '../../catequizandos/viewmodels/catequizando_viewmodel.dart';
import '../../turma/models/turma_model.dart';
import '../../turma/viewmodels/turma_viewmodel.dart';
import '../models/encontro_model.dart';
import '../models/frequencia_model.dart';
import 'encontros_viewmodel.dart';

class EncontroViewModel extends GetxController {
  final EncontrosViewModel encontrosVm;

  EncontroViewModel({
    required this.encontrosVm,
  });

  TurmaModel? _turma;
  TurmaModel? get turma => _turma;

  List<Catequizando> _todosAlunos = [];
  List<Catequizando> get todosAlunos => _todosAlunos;

  final abaAtual = 0.obs;
  final dataSelecionada = DateTime.now().obs;
  final descricao = ''.obs;
  final searchQuery = ''.obs;
  final presencasLocais = <String, bool>{};

  List<Catequizando> get alunosFiltrados {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return _todosAlunos;
    return _todosAlunos.where((a) =>
      a.nome.toLowerCase().contains(query) ||
      a.responsavel.toLowerCase().contains(query)
    ).toList();
  }

  int get totalPresentes => presencasLocais.values.where((v) => v).length;

  void definirTurma(TurmaModel turmaSelecionada, TurmaViewModel turmaVm, CatequizandoViewModel catequizandoVm) {
    _turma = turmaSelecionada;
    _todosAlunos = turmaVm.alunosDaTurma(turmaSelecionada.nome, catequizandoVm.catequizandos);
    presencasLocais.clear();
    carregarData(dataSelecionada.value);
    update();
  }

  void setAba(int index) => abaAtual.value = index;
  void setDescricao(String v) => descricao.value = v;
  void setSearch(String v) => searchQuery.value = v;

  void carregarData(DateTime data) {
    if (_turma == null) return;
    dataSelecionada.value = DateTime(data.year, data.month, data.day);
    final e = encontrosVm.encontroDoDia(_turma!.id, dataSelecionada.value);
    descricao.value = e?.descricao ?? '';
    for (final a in _todosAlunos) {
      presencasLocais[a.id] = encontrosVm.frequenciaAluno(_turma!.id, dataSelecionada.value, a.id) ?? true;
    }
  }

  void alternarPresenca(String alunoId, bool value) {
    presencasLocais[alunoId] = value;
  }

  void salvar() {
    if (_turma == null) return;
    final frequencias = presencasLocais.entries
        .map((e) => Frequencia(catequizandoId: e.key, presente: e.value))
        .toList();
    encontrosVm.salvarFrequencias(_turma!.id, dataSelecionada.value, frequencias);
  }

  void carregarDadosDoEncontro(DateTime data, String desc) {
    carregarData(data);
    descricao.value = desc;
    abaAtual.value = 0;
  }

  void removerEncontro(Encontro encontro) {
    encontrosVm.removerEncontro(encontro);
  }
}
