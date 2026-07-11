class Matricula {
  final String id;
  final String catequizandoId;
  final String turmaId;
  final int ano;
  final DateTime dataMatricula;
  final String status;
  final DateTime? dataConclusao;
  final String? observacoes;

  Matricula({
    String? id,
    required this.catequizandoId,
    required this.turmaId,
    required this.ano,
    DateTime? dataMatricula,
    this.status = 'Ativa',
    this.dataConclusao,
    this.observacoes,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        dataMatricula = dataMatricula ?? DateTime.now();

  factory Matricula.fromMap(String id, Map<String, dynamic> map) {
    return Matricula(
      id: id,
      catequizandoId: map['catequizandoId'] as String? ?? '',
      turmaId: map['turmaId'] as String? ?? '',
      ano: map['ano'] as int? ?? DateTime.now().year,
      dataMatricula: (map['dataMatricula'] as dynamic)?.toDate() ?? DateTime.now(),
      status: map['status'] as String? ?? 'Ativa',
      dataConclusao: (map['dataConclusao'] as dynamic)?.toDate(),
      observacoes: map['observacoes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'catequizandoId': catequizandoId,
      'turmaId': turmaId,
      'ano': ano,
      'dataMatricula': dataMatricula,
      'status': status,
      'dataConclusao': dataConclusao,
      'observacoes': observacoes,
    };
  }
}
