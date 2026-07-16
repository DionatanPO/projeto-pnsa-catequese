import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/catequista_model.dart';

class CatequistaRepository {
  Future<List<Catequista>> getAll() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'catequista')
        .get();

    return snapshot.docs.map((doc) {
      return Catequista.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    }).toList();
  }

  Future<void> add(Catequista c) async {
    await FirebaseFirestore.instance.collection('users').add(c.toMap());
  }

  Future<void> update(Catequista c) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(c.id)
        .update(c.toMap());
  }

}
