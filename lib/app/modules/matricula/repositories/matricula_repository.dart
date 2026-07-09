import 'package:get/get.dart';
import '../models/matricula_model.dart';

class MatriculaRepository {
  final List<Matricula> _mockData = [];

  List<Matricula> getAll() => List.unmodifiable(_mockData);

  List<Matricula> getAtivas() =>
      _mockData.where((m) => m.status == 'Ativa').toList();

  List<Matricula> getByCatequizando(String catequizandoId) =>
      _mockData.where((m) => m.catequizandoId == catequizandoId).toList();

  List<Matricula> getByTurma(String turmaId) =>
      _mockData.where((m) => m.turmaId == turmaId).toList();

  List<Matricula> getAtivasPorTurma(String turmaId) =>
      _mockData.where((m) => m.turmaId == turmaId && m.status == 'Ativa').toList();

  Matricula? getAtivaDoCatequizando(String catequizandoId) =>
      _mockData.firstWhereOrNull(
        (m) => m.catequizandoId == catequizandoId && m.status == 'Ativa',
      );

  Future<void> add(Matricula matricula) async {
    _mockData.add(matricula);
  }

  Future<void> update(Matricula matricula) async {
    final idx = _mockData.indexWhere((m) => m.id == matricula.id);
    if (idx != -1) {
      _mockData[idx] = matricula;
    }
  }

  Future<void> remove(String id) async {
    _mockData.removeWhere((m) => m.id == id);
  }
}
