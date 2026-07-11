import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(uid, doc.data() as Map<String, dynamic>);
  }

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.id).set(user.toMap());
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }
}
