import 'package:get/get.dart';
import '../models/encontro_model.dart';
import '../models/frequencia_model.dart';

class EncontrosRepository {
  final List<Encontro> _mockData = [
    Encontro(
      id: '1_2026-06-28T00:00:00.000',
      data: DateTime(2026, 6, 28),
      descricao: 'Encontro de abertura - Apresentação do cronograma',
      frequencias: [
        Frequencia(catequizandoId: '1', presente: true),
        Frequencia(catequizandoId: '2', presente: true),
        Frequencia(catequizandoId: '3', presente: false),
      ],
    ),
    Encontro(
      id: '1_2026-07-05T00:00:00.000',
      data: DateTime(2026, 7, 5),
      descricao: 'Oração do Pai Nosso',
      frequencias: [
        Frequencia(catequizandoId: '1', presente: true),
        Frequencia(catequizandoId: '2', presente: false),
        Frequencia(catequizandoId: '3', presente: true),
      ],
    ),
  ];

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
