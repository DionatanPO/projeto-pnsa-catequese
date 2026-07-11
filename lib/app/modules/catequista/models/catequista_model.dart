class Catequista {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String status;

  Catequista({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.status,
  });

  factory Catequista.fromMap(String id, Map<String, dynamic> map) {
    return Catequista(
      id: id,
      nome: map['nome'] as String? ?? '',
      email: map['email'] as String? ?? '',
      telefone: map['telefone'] as String? ?? '',
      status: (map['ativo'] as bool? ?? true) ? 'Ativo' : 'Inativo',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'role': 'catequista',
      'ativo': status == 'Ativo',
    };
  }
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
