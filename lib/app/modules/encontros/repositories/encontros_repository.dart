import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/encontro_model.dart';

class EncontrosRepository {
  Future<List<Encontro>> getAll() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('encontros')
        .orderBy('data', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Encontro.fromMap(doc.id, doc.data());
    }).toList();
  }

  Future<void> add(Encontro encontro) async {
    await FirebaseFirestore.instance.collection('encontros').add(encontro.toMap());
  }

  Future<void> update(Encontro encontro) async {
    await FirebaseFirestore.instance
        .collection('encontros')
        .doc(encontro.id)
        .update(encontro.toMap());
  }

  Future<void> remove(Encontro encontro) async {
    await FirebaseFirestore.instance.collection('encontros').doc(encontro.id).delete();
  }

  Future<List<Encontro>> encontrosDaTurma(String turmaId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('encontros')
        .where('turmaId', isEqualTo: turmaId)
        .orderBy('data', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return Encontro.fromMap(doc.id, doc.data());
    }).toList();
  }

  Future<Encontro?> encontroDoDia(String turmaId, DateTime data) async {
    final start = DateTime(data.year, data.month, data.day);
    final end = start.add(const Duration(days: 1));
    final snapshot = await FirebaseFirestore.instance
        .collection('encontros')
        .where('turmaId', isEqualTo: turmaId)
        .where('data', isGreaterThanOrEqualTo: start)
        .where('data', isLessThan: end)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Encontro.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
  }

  Future<void> addAll(List<Encontro> encontros) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final e in encontros) {
      final ref = FirebaseFirestore.instance.collection('encontros').doc();
      batch.set(ref, e.toMap());
    }
    await batch.commit();
  }

  Future<Encontro> criarOuObterEncontro(String turmaId, DateTime data) async {
    final existing = await encontroDoDia(turmaId, data);
    if (existing != null) return existing;
    final ref = await FirebaseFirestore.instance.collection('encontros').add({
      'turmaId': turmaId,
      'data': data,
      'descricao': '',
    });
    final doc = await ref.get();
    return Encontro.fromMap(doc.id, doc.data()!);
  }
}
