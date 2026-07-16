class Catequista {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String status;
  final String dataNascimento;
  final String logradouro;
  final String numero;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;
  final bool casado;

  Catequista({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.status,
    this.dataNascimento = '',
    this.logradouro = '',
    this.numero = '',
    this.bairro = '',
    this.cidade = '',
    this.estado = '',
    this.cep = '',
    this.casado = false,
  });

  factory Catequista.fromMap(String id, Map<String, dynamic> map) {
    return Catequista(
      id: id,
      nome: map['nome'] as String? ?? '',
      email: map['email'] as String? ?? '',
      telefone: map['telefone'] as String? ?? '',
      status: (map['ativo'] as bool? ?? true) ? 'Ativo' : 'Inativo',
      dataNascimento: map['dataNascimento'] as String? ?? '',
      logradouro: map['logradouro'] as String? ?? '',
      numero: map['numero'] as String? ?? '',
      bairro: map['bairro'] as String? ?? '',
      cidade: map['cidade'] as String? ?? '',
      estado: map['estado'] as String? ?? '',
      cep: map['cep'] as String? ?? '',
      casado: map['casado'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'role': 'catequista',
      'ativo': status == 'Ativo',
      'dataNascimento': dataNascimento,
      'logradouro': logradouro,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'casado': casado,
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
