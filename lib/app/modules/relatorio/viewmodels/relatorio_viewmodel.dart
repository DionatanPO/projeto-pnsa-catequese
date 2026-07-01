import 'package:get/get.dart';
import '../models/relatorio_model.dart';

class RelatorioViewModel extends GetxController {
  final RxList<RelatorioModel> relatorios = [
    RelatorioModel(
      titulo: 'Catequizandos por Turma',
      descricao: 'Distribuição dos catequizandos em cada turma',
      total: 142,
    ),
    RelatorioModel(
      titulo: 'Presenças por Mês',
      descricao: 'Frequência mensal dos catequizandos',
      total: 98,
    ),
    RelatorioModel(
      titulo: 'Catequistas por Turma',
      descricao: 'Relação de catequistas alocados por turma',
      total: 12,
    ),
    RelatorioModel(
      titulo: 'Turmas Ativas',
      descricao: 'Total de turmas em andamento',
      total: 8,
    ),
  ].obs;
}
