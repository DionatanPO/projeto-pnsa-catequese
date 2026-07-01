class Catequista {
  final String nome;
  final String email;
  final String telefone;
  final String turma;

  Catequista({
    required this.nome,
    required this.email,
    required this.telefone,
    required this.turma,
  });
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
