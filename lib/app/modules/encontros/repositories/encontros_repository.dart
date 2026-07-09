import 'package:get/get.dart';
import '../models/encontro_model.dart';

class EncontrosRepository {
  final List<Encontro> _mockData = () {
    final turmasIds = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
    final descricoes = [
      'Encontro de abertura - Apresentação do cronograma',
      'Oração do Pai Nosso',
      'Ave Maria e o Rosário',
      'Os Mandamentos da Lei de Deus',
      'Os Sacramentos da Igreja',
      'A vida de Jesus Cristo',
      'O Espírito Santo na nossa vida',
      'A Santa Missa explicada',
      'O Batismo: porta dos sacramentos',
      'A Eucaristia: fonte e ápice da vida cristã',
      'A Confissão: sacramento da misericórdia',
      'Os Santos e a Igreja',
      'A Quaresma e a Semana Santa',
      'A Páscoa do Senhor',
      'Maria, Mãe da Igreja',
      'O Advento e o Natal',
      'A Igreja: povo de Deus',
      'Vocação e missão do cristão',
      'A Palavra de Deus na vida',
      'Encontro de encerramento e confraternização',
      'Preparação para a Primeira Eucaristia',
      'Retiro espiritual dos catequizandos',
      'Visita à Igreja Matriz',
      'A Campanha da Fraternidade',
      'Dia da Família na catequese',
      'A oração na vida do cristão',
      'Os dons do Espírito Santo',
      'Os frutos do Espírito Santo',
      'As bem-aventuranças',
      'O mandamento do amor',
    ];

    final encontros = <Encontro>[];
    var idx = 0;
    for (final turmaId in turmasIds) {
      for (var mes = 2; mes <= 11; mes++) {
        if (idx >= 80) break;
        final dia = 1 + (idx % 25);
        encontros.add(Encontro(
          id: '${turmaId}_2026-${mes.toString().padLeft(2, '0')}-${dia.toString().padLeft(2, '0')}T00:00:00.000',
          data: DateTime(2026, mes, dia),
          descricao: descricoes[idx % descricoes.length],
        ));
        idx++;
      }
      if (idx >= 80) break;
    }
    return encontros;
  }();

  List<Encontro> getAll() => List.unmodifiable(_mockData);

  Future<void> add(Encontro encontro) async {
    _mockData.add(encontro);
  }

  Future<void> update(Encontro encontro) async {
    final idx = _mockData.indexWhere((e) => e.id == encontro.id);
    if (idx != -1) {
      _mockData[idx] = encontro;
    }
  }

  Future<void> remove(Encontro encontro) async {
    _mockData.remove(encontro);
  }

  List<Encontro> encontrosDaTurma(String turmaId) {
    return _mockData.where((e) => e.id.startsWith(turmaId)).toList();
  }

  Encontro? encontroDoDia(String turmaId, DateTime data) {
    return _mockData.firstWhereOrNull(
      (e) => e.id.startsWith(turmaId) && e.data == data,
    );
  }

  Future<Encontro> criarOuObterEncontro(String turmaId, DateTime data) async {
    final existing = encontroDoDia(turmaId, data);
    if (existing != null) return existing;
    final novo = Encontro(
      id: '${turmaId}_${data.toIso8601String()}',
      data: data,
    );
    _mockData.add(novo);
    return novo;
  }
}
