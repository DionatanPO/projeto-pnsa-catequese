import 'package:get/get.dart';
import '../models/catequista_model.dart';

class CatequistaViewModel extends GetxController {
  final Rx<CatequistaModel> data = CatequistaModel(
    totalTurmas: 8,
    totalCatequizandos: 142,
    totalCatequistas: 12,
    catequistas: [
      Catequista(nome: 'Maria José Silva', email: 'maria@pnsa.com', telefone: '(62) 99901-0001', turma: '1ª Eucaristia - A', status: 'Ativo'),
      Catequista(nome: 'João Pedro Santos', email: 'joao@pnsa.com', telefone: '(62) 99901-0002', turma: '1ª Eucaristia - B', status: 'Ativo'),
      Catequista(nome: 'Ana Clara Oliveira', email: 'ana@pnsa.com', telefone: '(62) 99901-0003', turma: '2ª Eucaristia - A', status: 'Ativo'),
      Catequista(nome: 'Carlos Eduardo Lima', email: 'carlos@pnsa.com', telefone: '(62) 99901-0004', turma: '2ª Eucaristia - B', status: 'Ativo'),
      Catequista(nome: 'Lucia Aparecida Souza', email: 'lucia@pnsa.com', telefone: '(62) 99901-0005', turma: 'Crisma - A', status: 'Inativo'),
      Catequista(nome: 'Pedro Henrique Costa', email: 'pedro@pnsa.com', telefone: '(62) 99901-0006', turma: 'Crisma - B', status: 'Ativo'),
      Catequista(nome: 'Rita de Cássia Pereira', email: 'rita@pnsa.com', telefone: '(62) 99901-0007', turma: 'Batismo', status: 'Ativo'),
      Catequista(nome: 'Antônio Carlos Gomes', email: 'antonio@pnsa.com', telefone: '(62) 99901-0008', turma: 'Perseverança', status: 'Inativo'),
      Catequista(nome: 'Cristina Almeida', email: 'cristina@pnsa.com', telefone: '(62) 99901-0009', turma: '1ª Eucaristia - A', status: 'Ativo'),
      Catequista(nome: 'Fernando José Martins', email: 'fernando@pnsa.com', telefone: '(62) 99901-0010', turma: '1ª Eucaristia - B', status: 'Ativo'),
      Catequista(nome: 'Teresa Cristina Rocha', email: 'teresa@pnsa.com', telefone: '(62) 99901-0011', turma: 'Crisma - A', status: 'Ativo'),
      Catequista(nome: 'Paulo Sérgio Barbosa', email: 'paulo@pnsa.com', telefone: '(62) 99901-0012', turma: '2ª Eucaristia - A', status: 'Ativo'),
    ],
  ).obs;

  final RxString searchQuery = ''.obs;

  List<Catequista> get filteredCatequistas {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return data.value.catequistas;
    return data.value.catequistas.where((c) =>
      c.nome.toLowerCase().contains(query) ||
      c.turma.toLowerCase().contains(query)
    ).toList();
  }

  void setSearch(String value) => searchQuery.value = value;

  void addCatequista(Catequista c) {
    data.update((val) {
      if (val == null) return;
      val.catequistas.add(c);
    });
  }

  void updateCatequista(Catequista c) {
    data.update((val) {
      if (val == null) return;
      final idx = val.catequistas.indexWhere((x) => x.id == c.id);
      if (idx != -1) {
        val.catequistas[idx] = c;
      }
    });
  }

  void removeCatequista(String id) {
    data.update((val) {
      if (val == null) return;
      val.catequistas.removeWhere((x) => x.id == id);
    });
  }
}
