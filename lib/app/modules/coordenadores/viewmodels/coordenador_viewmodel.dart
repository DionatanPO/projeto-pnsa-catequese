import 'package:get/get.dart';
import '../models/coordenador_model.dart';
import '../repositories/coordenador_repository.dart';

class CoordenadorViewModel extends GetxController {
  final CoordenadorRepository _repository;

  final Rx<CoordenadorModel> data = CoordenadorModel().obs;
  final RxString searchQuery = ''.obs;

  CoordenadorViewModel({CoordenadorRepository? repository})
      : _repository = repository ?? CoordenadorRepository() {
    _loadData();
  }

  void _loadData() {
    final list = _repository.getAll();
    data.value = CoordenadorModel(
      totalCoordenadores: list.length,
      coordenadores: list,
    );
  }

  List<Coordenador> get filteredCoordenadores {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return data.value.coordenadores;
    return data.value.coordenadores.where((c) =>
      c.nome.toLowerCase().contains(query) ||
      c.area.toLowerCase().contains(query)
    ).toList();
  }

  void setSearch(String value) => searchQuery.value = value;

  Future<void> addCoordenador(Coordenador c) async {
    await _repository.add(c);
    _loadData();
  }

  Future<void> updateCoordenador(Coordenador c) async {
    await _repository.update(c);
    _loadData();
  }

  Future<void> removeCoordenador(String id) async {
    await _repository.remove(id);
    _loadData();
  }
}
