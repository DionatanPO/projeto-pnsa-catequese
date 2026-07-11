import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/matricula_model.dart';

class MatriculaRepository {
  List<Matricula> _cache = [];

  Future<List<Matricula>> getAll() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('matriculas')
        .get();

    _cache = snapshot.docs
        .map((doc) => Matricula.fromMap(doc.id, doc.data()))
        .toList();
    return List.unmodifiable(_cache);
  }

  List<Matricula> getAllSync() => List.unmodifiable(_cache);

  List<Matricula> getAtivas() =>
      _cache.where((m) => m.status == 'Ativa').toList();

  List<Matricula> getByCatequizando(String catequizandoId) =>
      _cache.where((m) => m.catequizandoId == catequizandoId).toList();

  List<Matricula> getByTurma(String turmaId) =>
      _cache.where((m) => m.turmaId == turmaId).toList();

  List<Matricula> getAtivasPorTurma(String turmaId) => _cache
      .where((m) => m.turmaId == turmaId && m.status == 'Ativa')
      .toList();

  Matricula? getAtivaDoCatequizando(String catequizandoId) =>
      _cache.firstWhereOrNull(
        (m) => m.catequizandoId == catequizandoId && m.status == 'Ativa',
      );

  Future<void> add(Matricula matricula) async {
    final ref = await FirebaseFirestore.instance
        .collection('matriculas')
        .add(matricula.toMap());

    final nova = Matricula(
      id: ref.id,
      catequizandoId: matricula.catequizandoId,
      turmaId: matricula.turmaId,
      ano: matricula.ano,
      dataMatricula: matricula.dataMatricula,
      status: matricula.status,
      dataConclusao: matricula.dataConclusao,
      observacoes: matricula.observacoes,
    );
    _cache.add(nova);
  }

  Future<void> update(Matricula matricula) async {
    await FirebaseFirestore.instance
        .collection('matriculas')
        .doc(matricula.id)
        .update(matricula.toMap());

    final idx = _cache.indexWhere((m) => m.id == matricula.id);
    if (idx != -1) {
      _cache[idx] = matricula;
    }
  }

  Future<void> remove(String id) async {
    await FirebaseFirestore.instance.collection('matriculas').doc(id).delete();
    _cache.removeWhere((m) => m.id == id);
  }
}
