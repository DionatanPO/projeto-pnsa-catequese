import 'package:get/get.dart';
import '../../catequizandos/models/catequizando_model.dart';
import '../../turma/models/turma_model.dart';
import '../../encontros/viewmodels/encontros_viewmodel.dart';
import '../../matricula/viewmodels/matricula_viewmodel.dart';

class StatusCount {
  final String status;
  final int count;
  final double percent;

  StatusCount({
    required this.status,
    required this.count,
    required this.percent,
  });
}

class TurmaEtapaCount {
  final String etapa;
  final int totalTurmas;
  final int totalAlunos;

  TurmaEtapaCount({
    required this.etapa,
    required this.totalTurmas,
    required this.totalAlunos,
  });
}

class EncontrosTurmaCount {
  final String turmaNome;
  final int totalEncontros;
  final int totalPresencas;
  final double mediaPresenca;

  EncontrosTurmaCount({
    required this.turmaNome,
    required this.totalEncontros,
    required this.totalPresencas,
    required this.mediaPresenca,
  });
}

class FaixaEtariaCount {
  final String faixa;
  final int masculino;
  final int feminino;
  final int total;

  FaixaEtariaCount({
    required this.faixa,
    required this.masculino,
    required this.feminino,
    required this.total,
  });
}

class RelatorioViewModel extends GetxController {
  final RxList<StatusCount> statusCounts = <StatusCount>[].obs;
  final RxList<TurmaEtapaCount> turmasPorEtapa = <TurmaEtapaCount>[].obs;
  final RxList<EncontrosTurmaCount> encontrosRealizados = <EncontrosTurmaCount>[].obs;
  final RxList<FaixaEtariaCount> faixaEtaria = <FaixaEtariaCount>[].obs;

  final RxInt tabIndex = 0.obs;

  void loadStatusReport(List<Catequizando> catequizandos) {
    final total = catequizandos.length;
    statusCounts.value = Catequizando.statusOptions.map((s) {
      final count = catequizandos.where((c) => c.status == s).length;
      return StatusCount(
        status: s,
        count: count,
        percent: total > 0 ? count / total : 0,
      );
    }).toList();
  }

  void loadTurmasPorEtapaReport(
    List<TurmaModel> turmas,
    MatriculaViewModel matriculaVm,
  ) {
    final etapas = <String, int>{};
    final alunos = <String, int>{};

    for (final t in turmas) {
      etapas[t.etapa] = (etapas[t.etapa] ?? 0) + 1;
      alunos[t.etapa] = (alunos[t.etapa] ?? 0) + matriculaVm.totalAlunosNaTurma(t.id);
    }

    turmasPorEtapa.value = etapas.entries.map((e) {
      return TurmaEtapaCount(
        etapa: e.key,
        totalTurmas: e.value,
        totalAlunos: alunos[e.key] ?? 0,
      );
    }).toList()
      ..sort((a, b) => a.etapa.compareTo(b.etapa));
  }

  void loadEncontrosReport(
    List<TurmaModel> turmas,
    EncontrosViewModel encontrosVm,
  ) {
    encontrosRealizados.value = turmas.map((t) {
      final encontros = encontrosVm.encontrosDaTurma(t.id);
      int totalPresencas = 0;
      for (final e in encontros) {
        totalPresencas += e.frequencias.where((f) => f.presente).length;
      }
      final totalEncontros = encontros.length;
      return EncontrosTurmaCount(
        turmaNome: t.nome,
        totalEncontros: totalEncontros,
        totalPresencas: totalPresencas,
        mediaPresenca: totalEncontros > 0 ? totalPresencas / totalEncontros : 0,
      );
    }).toList()
      ..sort((a, b) => b.totalEncontros.compareTo(a.totalEncontros))
      ..sort((a, b) {
        if (a.totalEncontros != b.totalEncontros) return b.totalEncontros.compareTo(a.totalEncontros);
        return a.turmaNome.compareTo(b.turmaNome);
      });
  }

  void loadFaixaEtariaReport(List<Catequizando> catequizandos) {
    final faixas = <String, int>{};
    final masc = <String, int>{};
    final fem = <String, int>{};

    String faixa(int idade) {
      if (idade <= 6) return '0-6 anos';
      if (idade <= 10) return '7-10 anos';
      if (idade <= 13) return '11-13 anos';
      if (idade <= 17) return '14-17 anos';
      return '18+ anos';
    }

    for (final c in catequizandos) {
      final f = faixa(c.idade);
      faixas[f] = (faixas[f] ?? 0) + 1;
      if (c.sexo == 'Masculino') {
        masc[f] = (masc[f] ?? 0) + 1;
      } else {
        fem[f] = (fem[f] ?? 0) + 1;
      }
    }

    final ordem = ['0-6 anos', '7-10 anos', '11-13 anos', '14-17 anos', '18+ anos'];
    faixaEtaria.value = ordem.where((f) => faixas.containsKey(f)).map((f) {
      return FaixaEtariaCount(
        faixa: f,
        masculino: masc[f] ?? 0,
        feminino: fem[f] ?? 0,
        total: faixas[f] ?? 0,
      );
    }).toList();
  }
}
