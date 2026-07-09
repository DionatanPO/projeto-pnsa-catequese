class Matricula {
  final String id;
  final String catequizandoId;
  final String turmaId;
  final int ano;
  final DateTime dataMatricula;
  final String status; // 'Ativa', 'Concluída', 'Transferida', 'Cancelada'
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
}
