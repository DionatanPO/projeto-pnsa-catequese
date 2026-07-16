import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../turma/models/turma_model.dart';
import '../viewmodels/encontros_viewmodel.dart';
import '../widgets/novo_encontro_bottom_sheet.dart';

void showNovoEncontroDialog(BuildContext context, EncontrosViewModel encontrosVm, {RxList<TurmaModel>? turmas}) {
  final todosTurmas = turmas ?? <TurmaModel>[].obs;
  NovoEncontroBottomSheet.show(context, encontrosVm, todosTurmas);
}
