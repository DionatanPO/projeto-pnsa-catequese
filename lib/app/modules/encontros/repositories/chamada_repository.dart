import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chamada_model.dart';

class ChamadaRepository {
  final _cache = <String, List<Chamada>>{};
  final _firestore = FirebaseFirestore.instance;

  Future<void> loadAll() async {
    final snapshot = await _firestore.collection('chamadas').get();
    _cache.clear();
    for (final doc in snapshot.docs) {
      final c = Chamada.fromMap(doc.id, doc.data());
      _cache.putIfAbsent(c.encontroId, () => []).add(c);
    }
  }

  List<Chamada> getByEncontro(String encontroId) => _cache[encontroId] ?? [];

  Future<void> salvarEncontro(String encontroId, List<Chamada> chamadas) async {
    final batch = _firestore.batch();

    final existing = await _firestore
        .collection('chamadas')
        .where('encontroId', isEqualTo: encontroId)
        .get();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }

    for (final c in chamadas) {
      batch.set(_firestore.collection('chamadas').doc(), {
        'encontroId': encontroId,
        'catequizandoId': c.catequizandoId,
        'presente': c.presente,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    await _carregarEncontro(encontroId);
  }

  Future<void> deletarPorEncontro(String encontroId) async {
    final existing = await _firestore
        .collection('chamadas')
        .where('encontroId', isEqualTo: encontroId)
        .get();
    if (existing.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    _cache.remove(encontroId);
  }

  Future<void> _carregarEncontro(String encontroId) async {
    final snapshot = await _firestore
        .collection('chamadas')
        .where('encontroId', isEqualTo: encontroId)
        .get();
    _cache[encontroId] = snapshot.docs
        .map((doc) => Chamada.fromMap(doc.id, doc.data()))
        .toList();
  }
}
