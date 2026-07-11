import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../turma/models/turma_model.dart';
import '../viewmodels/encontros_viewmodel.dart';
import 'encontro_form.dart';

void showNovoEncontroDialog(BuildContext context, EncontrosViewModel encontrosVm, {RxList<TurmaModel>? turmas}) {
  final todosTurmas = turmas ?? <TurmaModel>[].obs;

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: EncontroForm(encontrosVm: encontrosVm, turmas: todosTurmas),
    ),
  );
}
