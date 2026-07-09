class Catequizando {
  final String id;
  final String nome;
  final String sexo;
  final DateTime dataNascimento;

  final bool batizado;
  final String? localBatismo;
  final bool? fezPrimeiraEucaristia;

  final String responsavel;
  final String parentesco;
  final String telefone;
  final String cep;
  final String endereco;
  final String numero;
  final String bairro;

  final bool possuiRestricao;
  final String? detalheRestricao;

  final String status;
  final bool aceiteTermos;
  final String? assinaturaResponsavel;
  final String? dataAssinatura;
  final List<String> documentosAnexados;

  static const List<String> statusOptions = [
    'Em Andamento',
    'Formado',
    'Desistente',
    'Transferido',
    'Inativo',
  ];

  Catequizando({
    String? id,
    required this.nome,
    this.sexo = 'Masculino',
    required this.dataNascimento,
    this.batizado = false,
    this.localBatismo,
    this.fezPrimeiraEucaristia,
    required this.responsavel,
    required this.parentesco,
    required this.telefone,
    this.cep = '',
    this.endereco = '',
    this.numero = '',
    this.bairro = '',
    this.possuiRestricao = false,
    this.detalheRestricao,
    this.status = 'Em Andamento',
    this.aceiteTermos = false,
    this.assinaturaResponsavel,
    this.dataAssinatura,
    this.documentosAnexados = const [],
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  int get idade {
    final hoje = DateTime.now();
    int age = hoje.year - dataNascimento.year;
    if (hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
      age--;
    }
    return age;
  }
}
