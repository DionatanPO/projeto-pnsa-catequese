import '../models/coordenador_model.dart';

class CoordenadorRepository {
  final List<Coordenador> _mockData = [
    Coordenador(nome: 'Ana Silva', email: 'ana@pnsa.com', telefone: '(62) 99999-0001', area: 'Catequese Infantil', status: 'Ativo'),
    Coordenador(nome: 'Bruno Santos', email: 'bruno@pnsa.com', telefone: '(62) 99999-0002', area: 'Crisma', status: 'Ativo'),
    Coordenador(nome: 'Carla Oliveira', email: 'carla@pnsa.com', telefone: '(62) 99999-0003', area: 'Batismo', status: 'Inativo'),
  ];

  List<Coordenador> getAll() => List.unmodifiable(_mockData);

  Future<void> add(Coordenador coordenador) async {
    _mockData.add(coordenador);
  }

  Future<void> update(Coordenador coordenador) async {
    final idx = _mockData.indexWhere((x) => x.id == coordenador.id);
    if (idx != -1) {
      _mockData[idx] = coordenador;
    }
  }

  Future<void> remove(String id) async {
    _mockData.removeWhere((x) => x.id == id);
  }
}
