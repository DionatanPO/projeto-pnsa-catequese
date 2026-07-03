import 'package:get/get.dart';
import '../models/catequista_model.dart';
import '../repositories/catequista_repository.dart';

class CatequistaViewModel extends GetxController {
  final CatequistaRepository _repository;

  final Rx<CatequistaModel> data = CatequistaModel().obs;
  final RxString searchQuery = ''.obs;

  CatequistaViewModel({CatequistaRepository? repository})
      : _repository = repository ?? CatequistaRepository() {
    _loadData();
  }

  void _loadData() {
    final list = _repository.getAll();
    data.value = CatequistaModel(
      totalTurmas: 8,
      totalCatequizandos: 142,
      totalCatequistas: list.length,
      catequistas: list,
    );
  }

  List<Catequista> get filteredCatequistas {
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return data.value.catequistas;
    return data.value.catequistas.where((c) =>
      c.nome.toLowerCase().contains(query)
    ).toList();
  }

  void setSearch(String value) => searchQuery.value = value;

  Future<void> addCatequista(Catequista c) async {
    await _repository.add(c);
    _loadData();
  }

  Future<void> updateCatequista(Catequista c) async {
    await _repository.update(c);
    _loadData();
  }

  Future<void> removeCatequista(String id) async {
    await _repository.remove(id);
    _loadData();
  }
}
