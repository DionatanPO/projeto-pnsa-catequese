import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';
import '../../turma/models/turma_model.dart';
import '../models/catequizando_model.dart';
import '../viewmodels/catequizando_viewmodel.dart';
import '../views/catequizando_form.dart';

void showEditarCatequizandoBottomSheet(BuildContext context, CatequizandoViewModel vm,
    {required Catequizando catequizando, List<TurmaModel> turmas = const []}) {
  final isWide = MediaQuery.of(context).size.width >= 600;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        maxWidth: isWide ? 640 : double.infinity,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: CatequizandoForm(
              catequizando: catequizando,
              vm: vm,
              turmas: turmas,
              matriculaVm: Get.find<MatriculaViewModel>(),
              width: isWide ? 600 : double.infinity,
              onSave: (dados, turmaId) async {},
            ),
          ),
        ],
      ),
    ),
  );
}