class Catequista {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String status;

  Catequista({
    String? id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.status,
  }) : id = id ?? DateTime.now().toString();
}

class CatequistaModel {
  final int totalTurmas;
  final int totalCatequizandos;
  final int totalCatequistas;
  final List<Catequista> catequistas;

  CatequistaModel({
    this.totalTurmas = 0,
    this.totalCatequizandos = 0,
    this.totalCatequistas = 0,
    this.catequistas = const [],
  });
}
