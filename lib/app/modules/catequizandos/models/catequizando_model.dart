class Catequizando {
  final String nome;
  final String sexo;
  final DateTime dataNascimento;
  final String turmaNome;

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

  final bool aceiteTermos;
  final String? assinaturaResponsavel;
  final String? dataAssinatura;
  final List<String> documentosAnexados;

  Catequizando({
    required this.nome,
    this.sexo = 'Masculino',
    required this.dataNascimento,
    required this.turmaNome,
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
    this.aceiteTermos = false,
    this.assinaturaResponsavel,
    this.dataAssinatura,
    this.documentosAnexados = const [],
  });

  int get idade {
    final hoje = DateTime.now();
    int age = hoje.year - dataNascimento.year;
    if (hoje.month < dataNascimento.month ||
        (hoje.month == dataNascimento.month && hoje.day < dataNascimento.day)) {
      age--;
    }
    return age;
  }

  String get turma => turmaNome;
}
