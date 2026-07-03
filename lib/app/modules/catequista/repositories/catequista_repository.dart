import '../models/catequista_model.dart';

class CatequistaRepository {
  final List<Catequista> _mockData = [
    Catequista(nome: 'Maria José Silva', email: 'maria@pnsa.com', telefone: '(62) 99901-0001', status: 'Ativo'),
    Catequista(nome: 'João Pedro Santos', email: 'joao@pnsa.com', telefone: '(62) 99901-0002', status: 'Ativo'),
    Catequista(nome: 'Ana Clara Oliveira', email: 'ana@pnsa.com', telefone: '(62) 99901-0003', status: 'Ativo'),
    Catequista(nome: 'Carlos Eduardo Lima', email: 'carlos@pnsa.com', telefone: '(62) 99901-0004', status: 'Ativo'),
    Catequista(nome: 'Lucia Aparecida Souza', email: 'lucia@pnsa.com', telefone: '(62) 99901-0005', status: 'Inativo'),
    Catequista(nome: 'Pedro Henrique Costa', email: 'pedro@pnsa.com', telefone: '(62) 99901-0006', status: 'Ativo'),
    Catequista(nome: 'Rita de Cássia Pereira', email: 'rita@pnsa.com', telefone: '(62) 99901-0007', status: 'Ativo'),
    Catequista(nome: 'Antônio Carlos Gomes', email: 'antonio@pnsa.com', telefone: '(62) 99901-0008', status: 'Inativo'),
    Catequista(nome: 'Cristina Almeida', email: 'cristina@pnsa.com', telefone: '(62) 99901-0009', status: 'Ativo'),
    Catequista(nome: 'Fernando José Martins', email: 'fernando@pnsa.com', telefone: '(62) 99901-0010', status: 'Ativo'),
    Catequista(nome: 'Teresa Cristina Rocha', email: 'teresa@pnsa.com', telefone: '(62) 99901-0011', status: 'Ativo'),
    Catequista(nome: 'Paulo Sérgio Barbosa', email: 'paulo@pnsa.com', telefone: '(62) 99901-0012', status: 'Ativo'),
  ];

  List<Catequista> getAll() => List.unmodifiable(_mockData);

  Future<void> add(Catequista catequista) async {
    _mockData.add(catequista);
  }

  Future<void> update(Catequista catequista) async {
    final idx = _mockData.indexWhere((x) => x.id == catequista.id);
    if (idx != -1) {
      _mockData[idx] = catequista;
    }
  }

  Future<void> remove(String id) async {
    _mockData.removeWhere((x) => x.id == id);
  }
}
