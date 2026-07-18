import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_service.dart';
import '../models/coordenador_model.dart';

class CoordenadorRepository {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

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
    final uid = await _authService.createAccount(
      coordenador.email,
      AuthService.defaultPassword,
    );

    final user = UserModel(
      id: uid,
      nome: coordenador.nome,
      email: coordenador.email,
      telefone: coordenador.telefone,
      area: coordenador.area,
      role: 'coordenador',
      ativo: coordenador.status == 'Ativo',
    );
    await _userService.createUser(user);
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

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
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
