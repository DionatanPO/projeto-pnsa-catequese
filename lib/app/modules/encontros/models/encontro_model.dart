class Encontro {
  final String id;
  final String turmaId;
  final DateTime data;
  final String descricao;

  Encontro({
    required this.id,
    required this.turmaId,
    required this.data,
    this.descricao = '',
  });

  factory Encontro.fromMap(String id, Map<String, dynamic> map) {
    return Encontro(
      id: id,
      turmaId: map['turmaId'] as String? ?? '',
      data: (map['data'] as dynamic) is String
          ? DateTime.parse(map['data'] as String)
          : (map['data'] as dynamic)?.toDate() ?? DateTime.now(),
      descricao: map['descricao'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'turmaId': turmaId,
      'data': data,
      'descricao': descricao,
    };
  }
}
