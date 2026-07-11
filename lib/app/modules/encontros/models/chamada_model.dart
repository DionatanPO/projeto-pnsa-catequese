import 'package:cloud_firestore/cloud_firestore.dart';

class Chamada {
  final String id;
  final String encontroId;
  final String catequizandoId;
  final bool presente;

  Chamada({
    required this.id,
    required this.encontroId,
    required this.catequizandoId,
    this.presente = true,
  });

  factory Chamada.fromMap(String id, Map<String, dynamic> map) {
    return Chamada(
      id: id,
      encontroId: map['encontroId'] as String? ?? '',
      catequizandoId: map['catequizandoId'] as String? ?? '',
      presente: map['presente'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'encontroId': encontroId,
      'catequizandoId': catequizandoId,
      'presente': presente,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
