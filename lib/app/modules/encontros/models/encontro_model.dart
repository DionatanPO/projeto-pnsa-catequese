import 'frequencia_model.dart';

class Encontro {
  final String id;
  final DateTime data;
  final String descricao;
  final List<Frequencia> frequencias;

  Encontro({
    required this.id,
    required this.data,
    this.descricao = '',
    List<Frequencia>? frequencias,
  }) : frequencias = frequencias ?? [];
}
