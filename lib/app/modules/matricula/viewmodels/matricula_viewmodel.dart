import 'package:get/get.dart';
import '../models/matricula_model.dart';
import '../repositories/matricula_repository.dart';
import '../../catequizandos/models/catequizando_model.dart';
import '../../turma/models/turma_model.dart';

class MatriculaViewModel extends GetxController {
  final MatriculaRepository _repository;

  final RxList<Matricula> matriculas = <Matricula>[].obs;

  MatriculaViewModel({MatriculaRepository? repository})
      : _repository = repository ?? MatriculaRepository() {
    _loadData();
  }

  void _loadData() {
    matriculas.value = _repository.getAll();
  }

  void sincronizar(List<Catequizando> catequizandos, List<TurmaModel> turmas) {
    if (matriculas.isNotEmpty) return;

    final anoAtual = DateTime.now().year;

    for (var i = 0; i < catequizandos.length; i++) {
      final c = catequizandos[i];
      final turma = turmas.isNotEmpty ? turmas[i % turmas.length] : null;
      if (turma == null) continue;

      final matricula = Matricula(
        id: 'mat_${c.id}_${turma.id}',
        catequizandoId: c.id,
        turmaId: turma.id,
        ano: anoAtual,
        status: 'Ativa',
      );
      _repository.add(matricula);
    }
    _loadData();
  }

  String? getNomeTurmaAtual(
    String catequizandoId,
    List<TurmaModel> todasTurmas,
  ) {
    final ativa = _repository.getAtivaDoCatequizando(catequizandoId);
    if (ativa == null) return null;
    final turma = todasTurmas.firstWhereOrNull((t) => t.id == ativa.turmaId);
    return turma?.nome;
  }

  int? mesesNaTurmaAtual(String catequizandoId) {
    final ativa = _repository.getAtivaDoCatequizando(catequizandoId);
    if (ativa == null) return null;
    return DateTime.now().difference(ativa.dataMatricula).inDays ~/ 30;
  }

  bool getTemTempoLongo(String catequizandoId, {int meses = 11}) {
    final m = mesesNaTurmaAtual(catequizandoId);
    if (m == null) return false;
    return m >= meses;
  }

  List<Catequizando> getAlunosDaTurma(
    String turmaId,
    List<Catequizando> todos,
  ) {
    final ids = _repository
        .getAtivasPorTurma(turmaId)
        .map((m) => m.catequizandoId)
        .toSet();
    return todos.where((a) => ids.contains(a.id)).toList();
  }

  int totalAlunosNaTurma(String turmaId) {
    return _repository.getAtivasPorTurma(turmaId).length;
  }

  Future<void> matricular(
    String catequizandoId,
    String turmaId, {
    int? ano,
  }) async {
    final existente = _repository.getAtivaDoCatequizando(catequizandoId);
    if (existente != null) {
      final concluida = Matricula(
        id: existente.id,
        catequizandoId: existente.catequizandoId,
        turmaId: existente.turmaId,
        ano: existente.ano,
        dataMatricula: existente.dataMatricula,
        status: 'Concluída',
        dataConclusao: DateTime.now(),
      );
      await _repository.update(concluida);
    }

    final nova = Matricula(
      catequizandoId: catequizandoId,
      turmaId: turmaId,
      ano: ano ?? DateTime.now().year,
      status: 'Ativa',
    );
    await _repository.add(nova);
    _loadData();
  }

  Future<void> transferir(
    String catequizandoId,
    String novaTurmaId,
  ) async {
    final ativa = _repository.getAtivaDoCatequizando(catequizandoId);
    if (ativa == null) return;

    final concluida = Matricula(
      id: ativa.id,
      catequizandoId: ativa.catequizandoId,
      turmaId: ativa.turmaId,
      ano: ativa.ano,
      dataMatricula: ativa.dataMatricula,
      status: 'Transferida',
      dataConclusao: DateTime.now(),
    );
    await _repository.update(concluida);

    final nova = Matricula(
      catequizandoId: catequizandoId,
      turmaId: novaTurmaId,
      ano: DateTime.now().year,
      status: 'Ativa',
    );
    await _repository.add(nova);
    _loadData();
  }

  Future<void> concluir(String catequizandoId) async {
    final ativa = _repository.getAtivaDoCatequizando(catequizandoId);
    if (ativa == null) return;
    final concluida = Matricula(
      id: ativa.id,
      catequizandoId: ativa.catequizandoId,
      turmaId: ativa.turmaId,
      ano: ativa.ano,
      dataMatricula: ativa.dataMatricula,
      status: 'Concluída',
      dataConclusao: DateTime.now(),
    );
    await _repository.update(concluida);
    _loadData();
  }

  Future<void> desmatricular(String catequizandoId) async {
    final ativa = _repository.getAtivaDoCatequizando(catequizandoId);
    if (ativa == null) return;
    final concluida = Matricula(
      id: ativa.id,
      catequizandoId: ativa.catequizandoId,
      turmaId: ativa.turmaId,
      ano: ativa.ano,
      dataMatricula: ativa.dataMatricula,
      status: 'Cancelada',
      dataConclusao: DateTime.now(),
    );
    await _repository.update(concluida);
    _loadData();
  }

  List<Matricula> getHistorico(String catequizandoId) {
    return _repository.getByCatequizando(catequizandoId);
  }

  List<({Matricula matricula, String? turmaNome})> getHistoricoComTurma(
    String catequizandoId,
    List<TurmaModel> todasTurmas,
  ) {
    return getHistorico(catequizandoId).map((m) {
      final turma = todasTurmas.firstWhereOrNull((t) => t.id == m.turmaId);
      return (matricula: m, turmaNome: turma?.nome);
    }).toList()
      ..sort((a, b) => b.matricula.ano.compareTo(a.matricula.ano));
  }

  Future<void> removeMatricula(String id) async {
    await _repository.remove(id);
    _loadData();
  }
}
