class TurmaModel {
  final String id;
  final String nome;
  final int ano;
  final String etapa;
  final String diaHorario;
  final String localSala;
  final String status;
  final int totalCatequizandos;
  final String catequista;
  final String? observacoes;

  TurmaModel({
    required this.id,
    required this.nome,
    required this.ano,
    required this.etapa,
    required this.diaHorario,
    required this.localSala,
    required this.status,
    this.totalCatequizandos = 0,
    required this.catequista,
    this.observacoes,
  });

  factory TurmaModel.fromMap(String id, Map<String, dynamic> map) {
    return TurmaModel(
      id: id,
      nome: map['nome'] as String? ?? '',
      ano: map['ano'] as int? ?? DateTime.now().year,
      etapa: map['etapa'] as String? ?? '',
      diaHorario: map['diaHorario'] as String? ?? '',
      localSala: map['localSala'] as String? ?? '',
      status: map['status'] as String? ?? 'Ativa',
      totalCatequizandos: map['totalCatequizandos'] as int? ?? 0,
      catequista: map['catequista'] as String? ?? '',
      observacoes: map['observacoes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'ano': ano,
      'etapa': etapa,
      'diaHorario': diaHorario,
      'localSala': localSala,
      'status': status,
      'totalCatequizandos': totalCatequizandos,
      'catequista': catequista,
      'observacoes': observacoes,
    };
  }
}
