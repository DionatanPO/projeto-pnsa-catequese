import 'package:get/get.dart';
import '../models/catequizando_model.dart';
import '../repositories/catequizando_repository.dart';

class CatequizandoViewModel extends GetxController {
  final CatequizandoRepository _repository;

  final RxList<Catequizando> catequizandos = <Catequizando>[].obs;
  final RxString searchQuery = ''.obs;

  CatequizandoViewModel({CatequizandoRepository? repository})
      : _repository = repository ?? CatequizandoRepository() {
    _loadData();
  }

  void _loadData() {
    catequizandos.value = _repository.getAll();
  }

  List<Catequizando> get filteredCatequizandos {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return catequizandos;
    return catequizandos.where((a) =>
      a.nome.toLowerCase().contains(query) ||
      a.turmaNome.toLowerCase().contains(query) ||
      a.responsavel.toLowerCase().contains(query)
    ).toList();
  }

  void setSearch(String value) {
    searchQuery.value = value;
  }

  Future<void> addCatequizando(Catequizando c) async {
    await _repository.add(c);
    _loadData();
  }

  Future<void> updateCatequizando(Catequizando c) async {
    await _repository.update(c);
    _loadData();
  }

  Future<void> removeCatequizando(String id) async {
    await _repository.remove(id);
    _loadData();
  }
}
