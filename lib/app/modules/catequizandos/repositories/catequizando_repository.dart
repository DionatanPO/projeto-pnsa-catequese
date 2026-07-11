import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/catequizando_model.dart';

class CatequizandoRepository {
  Future<List<Catequizando>> getAll() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('catequizandos')
        .orderBy('nome')
        .get();

    return snapshot.docs.map((doc) {
      return Catequizando.fromMap(doc.id, doc.data());
    }).toList();
  }

  Future<String> add(Catequizando catequizando) async {
    final ref = await FirebaseFirestore.instance
        .collection('catequizandos')
        .add(catequizando.toMap());
    return ref.id;
  }

  Future<void> update(Catequizando catequizando) async {
    await FirebaseFirestore.instance
        .collection('catequizandos')
        .doc(catequizando.id)
        .update(catequizando.toMap());
  }

  Future<void> remove(String id) async {
    await FirebaseFirestore.instance
        .collection('catequizandos')
        .doc(id)
        .delete();
  }
}
