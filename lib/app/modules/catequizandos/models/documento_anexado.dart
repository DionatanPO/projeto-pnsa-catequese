class DocumentoAnexado {
  final String nome;
  final String extensao;
  final int tamanho;
  final String? driveFileId;
  final String? webViewLink;
  final String? downloadLink;

  DocumentoAnexado({
    required this.nome,
    this.extensao = '',
    this.tamanho = 0,
    this.driveFileId,
    this.webViewLink,
    this.downloadLink,
  });

  factory DocumentoAnexado.fromMap(Map<String, dynamic> map) {
    return DocumentoAnexado(
      nome: map['nome'] as String? ?? '',
      extensao: map['extensao'] as String? ?? '',
      tamanho: map['tamanho'] as int? ?? 0,
      driveFileId: map['driveFileId'] as String?,
      webViewLink: map['webViewLink'] as String?,
      downloadLink: map['downloadLink'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'extensao': extensao,
      'tamanho': tamanho,
      'driveFileId': driveFileId,
      'webViewLink': webViewLink,
      'downloadLink': downloadLink,
    };
  }

  String get descricao {
    final ext = extensao.isNotEmpty ? extensao.toUpperCase() : 'DESCONHECIDO';
    final tam = _formatBytes(tamanho);
    return '$nome ($ext, $tam)';
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  DocumentoAnexado copyWith({
    String? nome,
    String? extensao,
    int? tamanho,
    String? driveFileId,
    String? webViewLink,
    String? downloadLink,
  }) {
    return DocumentoAnexado(
      nome: nome ?? this.nome,
      extensao: extensao ?? this.extensao,
      tamanho: tamanho ?? this.tamanho,
      driveFileId: driveFileId ?? this.driveFileId,
      webViewLink: webViewLink ?? this.webViewLink,
      downloadLink: downloadLink ?? this.downloadLink,
    );
  }
}