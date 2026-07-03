import 'package:get/get.dart';
import '../models/coordenador_model.dart';

class CoordenadorViewModel extends GetxController {
  final Rx<CoordenadorModel> data = CoordenadorModel(
    totalCoordenadores: 3,
    coordenadores: [
      Coordenador(nome: 'Ana Silva', email: 'ana@pnsa.com', telefone: '(62) 99999-0001', area: 'Catequese Infantil'),
      Coordenador(nome: 'Bruno Santos', email: 'bruno@pnsa.com', telefone: '(62) 99999-0002', area: 'Crisma'),
      Coordenador(nome: 'Carla Oliveira', email: 'carla@pnsa.com', telefone: '(62) 99999-0003', area: 'Batismo'),
    ],
  ).obs;

  final RxString searchQuery = ''.obs;

  List<Coordenador> get filteredCoordenadores {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return data.value.coordenadores;
    return data.value.coordenadores.where((c) =>
      c.nome.toLowerCase().contains(query) ||
      c.area.toLowerCase().contains(query)
    ).toList();
  }

  void setSearch(String value) => searchQuery.value = value;

  void addCoordenador(Coordenador c) {
    data.update((val) {
      if (val == null) return;
      val.coordenadores.add(c);
    });
  }

  void updateCoordenador(Coordenador c) {
    data.update((val) {
      if (val == null) return;
      final idx = val.coordenadores.indexWhere((x) => x.id == c.id);
      if (idx != -1) {
        val.coordenadores[idx] = c;
      }
    });
  }

  void removeCoordenador(String id) {
    data.update((val) {
      if (val == null) return;
      val.coordenadores.removeWhere((x) => x.id == id);
    });
  }
}
