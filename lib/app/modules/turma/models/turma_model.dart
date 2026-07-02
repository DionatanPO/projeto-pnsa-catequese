class TurmaModel {
  final String id;
  final String nome;
  final int ano;
  final String etapa;
  final String diaHorario;
  final String localSala;
  final int capacidade;
  final String status; // 'Ativa', 'Concluída', 'Suspensa'
  final int totalCatequizandos; // Pode ser derivado, mas mantendo para compatibilidade
  final String catequista;
  final String? observacoes;

  TurmaModel({
    required this.id,
    required this.nome,
    required this.ano,
    required this.etapa,
    required this.diaHorario,
    required this.localSala,
    required this.capacidade,
    required this.status,
    this.totalCatequizandos = 0,
    required this.catequista,
    this.observacoes,
  });
}
