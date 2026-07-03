class Coordenador {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String area;

  Coordenador({
    String? id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.area,
  }) : id = id ?? DateTime.now().toString();
}

class CoordenadorModel {
  final int totalCoordenadores;
  final List<Coordenador> coordenadores;

  CoordenadorModel({
    this.totalCoordenadores = 0,
    this.coordenadores = const [],
  });
}
