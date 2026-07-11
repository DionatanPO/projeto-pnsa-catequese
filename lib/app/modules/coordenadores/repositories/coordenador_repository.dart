import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/user_service.dart';
import '../models/coordenador_model.dart';

class CoordenadorRepository {
  final UserService _userService = UserService();

  Future<List<Coordenador>> getAll() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'coordenador')
        .get();

    return snapshot.docs.map((doc) {
      final user = UserModel.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
      return _toCoordenador(user);
    }).toList();
  }

  Future<void> add(Coordenador coordenador) async {
    final user = UserModel(
      id: '',
      nome: coordenador.nome,
      email: coordenador.email,
      telefone: coordenador.telefone,
      area: coordenador.area,
      role: 'coordenador',
      ativo: coordenador.status == 'Ativo',
    );
    await FirebaseFirestore.instance.collection('users').add(user.toMap());
  }

  Future<void> update(Coordenador coordenador) async {
    await _userService.updateUser(coordenador.id, {
      'nome': coordenador.nome,
      'email': coordenador.email,
      'telefone': coordenador.telefone,
      'area': coordenador.area,
      'ativo': coordenador.status == 'Ativo',
    });
  }

  Future<void> remove(String id) async {
    await _userService.updateUser(id, {'ativo': false});
  }

  Coordenador _toCoordenador(UserModel user) {
    return Coordenador(
      id: user.id,
      nome: user.nome,
      email: user.email,
      telefone: user.telefone,
      area: user.area,
      status: user.ativo ? 'Ativo' : 'Inativo',
    );
  }
}
