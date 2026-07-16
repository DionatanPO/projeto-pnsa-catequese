import 'documento_anexado.dart';

class Catequizando {
  final String id;
  final String nome;
  final String sexo;
  final DateTime dataNascimento;

  final bool batizado;
  final String? localBatismo;
  final bool? fezPrimeiraEucaristia;
  final String? detalheEucaristia;
  final bool? fezCrisma;
  final String? detalheCrisma;

  final String responsavel;
  final String parentesco;
  final String telefone;
  final String cep;
  final String endereco;
  final String numero;
  final String bairro;

  final bool possuiRestricao;
  final String? detalheRestricao;
  final String? observacoes;

  final String status;
  final bool aceiteTermos;
  final String? assinaturaResponsavel;
  final String? dataAssinatura;
  final List<DocumentoAnexado> documentosAnexados;
  final String? driveFolderId;

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
    this.detalheEucaristia,
    this.fezCrisma,
    this.detalheCrisma,
    required this.responsavel,
    required this.parentesco,
    required this.telefone,
    this.cep = '',
    this.endereco = '',
    this.numero = '',
    this.bairro = '',
    this.possuiRestricao = false,
    this.detalheRestricao,
    this.observacoes,
    this.status = 'Em Andamento',
    this.aceiteTermos = false,
    this.assinaturaResponsavel,
    this.dataAssinatura,
    this.documentosAnexados = const [],
    this.driveFolderId,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory Catequizando.fromMap(String id, Map<String, dynamic> map) {
    return Catequizando(
      id: id,
      nome: map['nome'] as String? ?? '',
      sexo: map['sexo'] as String? ?? 'Masculino',
      dataNascimento: (map['dataNascimento'] as dynamic)?.toDate() ?? DateTime.now(),
      batizado: map['batizado'] as bool? ?? false,
      localBatismo: map['localBatismo'] as String?,
      fezPrimeiraEucaristia: map['fezPrimeiraEucaristia'] as bool?,
      detalheEucaristia: map['detalheEucaristia'] as String?,
      fezCrisma: map['fezCrisma'] as bool?,
      detalheCrisma: map['detalheCrisma'] as String?,
      responsavel: map['responsavel'] as String? ?? '',
      parentesco: map['parentesco'] as String? ?? '',
      telefone: map['telefone'] as String? ?? '',
      cep: map['cep'] as String? ?? '',
      endereco: map['endereco'] as String? ?? '',
      numero: map['numero'] as String? ?? '',
      bairro: map['bairro'] as String? ?? '',
      possuiRestricao: map['possuiRestricao'] as bool? ?? false,
      detalheRestricao: map['detalheRestricao'] as String?,
      observacoes: map['observacoes'] as String?,
      status: map['status'] as String? ?? 'Em Andamento',
      aceiteTermos: map['aceiteTermos'] as bool? ?? false,
      assinaturaResponsavel: map['assinaturaResponsavel'] as String?,
      dataAssinatura: (map['dataAssinatura'] as dynamic)?.toDate(),
documentosAnexados: (map['documentosAnexados'] as List<dynamic>?)
          ?.map((e) => DocumentoAnexado.fromMap(e as Map<String, dynamic>))
          .toList() ??
      [],
      driveFolderId: map['driveFolderId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'sexo': sexo,
      'dataNascimento': dataNascimento,
      'batizado': batizado,
      'localBatismo': localBatismo,
      'fezPrimeiraEucaristia': fezPrimeiraEucaristia,
      'detalheEucaristia': detalheEucaristia,
      'fezCrisma': fezCrisma,
      'detalheCrisma': detalheCrisma,
      'responsavel': responsavel,
      'parentesco': parentesco,
      'telefone': telefone,
      'cep': cep,
      'endereco': endereco,
      'numero': numero,
      'bairro': bairro,
      'possuiRestricao': possuiRestricao,
      'detalheRestricao': detalheRestricao,
      'observacoes': observacoes,
      'status': status,
      'aceiteTermos': aceiteTermos,
      'assinaturaResponsavel': assinaturaResponsavel,
      'dataAssinatura': dataAssinatura,
      'documentosAnexados': documentosAnexados.map((d) => d.toMap()).toList(),
      'driveFolderId': driveFolderId,
    };
  }

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
