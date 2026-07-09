import '../models/turma_model.dart';

class TurmaRepository {
  final List<TurmaModel> _mockData = [];

  TurmaRepository() {
    _loadMockData();
  }

  void _loadMockData() {
    if (_mockData.isNotEmpty) return;

    _mockData.addAll([
      TurmaModel(id: '1', nome: 'Cordeirinhos 4 anos', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Sábado, 09:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Primeiros passos na oração, o amor de Jesus pelos pequeninos e a criação.'),
      TurmaModel(id: '2', nome: 'Cordeirinhos 04 a 08 anos', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Domingo, 10:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Grupo de integração: vivência comunitária e musicalização litúrgica.'),
      TurmaModel(id: '3', nome: 'Cordeirinhos 05 anos (Seg)', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Segunda, 14:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'O bom Pastor, a família e a oração do Pai-Nosso.'),
      TurmaModel(id: '4', nome: 'Cordeirinhos 05 anos (Ter)', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Terça, 14:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'O bom Pastor, a família e a oração do Pai-Nosso.'),
      TurmaModel(id: '5', nome: 'Cordeirinhos 06 anos', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Sábado, 10:30', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Os Mandamentos do Amor e o exemplo dos Santos.'),
      TurmaModel(id: '6', nome: 'Cordeirinhos 06 e 07 anos', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Sábado, 10:30', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'A Bíblia como história de amor e os amigos de Jesus.'),
      TurmaModel(id: '7', nome: 'Cordeirinhos 07 anos', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Sábado, 10:30', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'O nascimento, a vida e a missão de Jesus.'),
      TurmaModel(id: '8', nome: 'Cordeirinhos 08 anos (Seg)', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Segunda, 16:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Introdução aos sacramentos e a importância da Missa.'),
      TurmaModel(id: '9', nome: 'Cordeirinhos 08 anos (Ter)', ano: 2026, etapa: 'Cordeirinhos', diaHorario: 'Terça, 16:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Introdução aos sacramentos e a importância da Missa.'),
      TurmaModel(id: '10', nome: 'Primeira Eucaristia 1', ano: 2026, etapa: 'Iniciação Eucarística', diaHorario: 'Sábado, 08:30', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Iniciação à vida de oração, estudo dos Mandamentos e o perdão (Confissão).'),
      TurmaModel(id: '11', nome: 'Primeira Eucaristia 2', ano: 2026, etapa: 'Iniciação Eucarística', diaHorario: 'Sábado, 08:30', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Preparação final para o encontro com Jesus Eucarístico (Missa e comunhão).'),
      TurmaModel(id: '12', nome: 'Perseverança', ano: 2026, etapa: 'Perseverança', diaHorario: 'Domingo, 09:30', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'Fortalecimento do vínculo com a paróquia após a Eucaristia e serviço missionário.'),
      TurmaModel(id: '13', nome: 'Crisma 1', ano: 2026, etapa: 'Crisma', diaHorario: 'Domingo, 18:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'O Espírito Santo, o Credo e a identidade do cristão na sociedade.'),
      TurmaModel(id: '14', nome: 'Crisma 2', ano: 2026, etapa: 'Crisma', diaHorario: 'Domingo, 18:00', localSala: '', capacidade: 25, status: 'Ativa', catequista: 'A definir', observacoes: 'O compromisso missionário, os dons do Espírito e a vida em comunidade.'),
      TurmaModel(id: '15', nome: 'Catequese de Adultos', ano: 2026, etapa: 'Catequese de Adultos', diaHorario: 'Quarta-feira, 20:00', localSala: '', capacidade: 30, status: 'Ativa', catequista: 'A definir', observacoes: 'Formação doutrinária básica para quem busca os Sacramentos de Iniciação ou deseja retomar a vida na fé.'),
    ]);

    final etapas = [
      ('Cordeirinhos', ['Cordeirinhos']),
      ('Iniciação Eucarística', ['Iniciação Eucarística']),
      ('Perseverança', ['Perseverança']),
      ('Crisma', ['Crisma']),
      ('Catequese de Adultos', ['Catequese de Adultos']),
    ];
    final dias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    final horarios = ['08:00', '09:00', '10:00', '14:00', '15:00', '16:00', '18:00', '19:30', '20:00'];
    final anos = [2025, 2026];
    final statusList = ['Ativa', 'Ativa', 'Ativa', 'Concluída', 'Suspensa'];
    final catequistasMock = [
      'Ana Clara Silva', 'Carlos Eduardo Pereira', 'Fernanda Oliveira Martins',
      'Juliana Costa Mendes', 'Marcelo Henrique Gomes', 'Patrícia Aparecida Moreira',
      'Thiago Martins Correia', 'A definir',
    ];

    var counter = 16;
    for (final ano in anos) {
      for (var e = 0; e < etapas.length; e++) {
        final etapa = etapas[e].$1;
        final qtd = e == 0 ? 6 : e == 4 ? 2 : 4;
        for (var i = 0; i < qtd; i++) {
          final dia = dias[(counter + i) % dias.length];
          final horario = horarios[(counter + i * 3) % horarios.length];
          final status = ano == 2025 ? (i == 0 ? 'Concluída' : statusList[(counter + i) % statusList.length]) : 'Ativa';
          final sufixo = qtd > 1 ? ' (${i + 1})' : '';
          _mockData.add(TurmaModel(
            id: counter.toString(),
            nome: '$etapa$sufixo',
            ano: ano,
            etapa: etapa,
            diaHorario: '$dia, $horario',
            localSala: '',
            capacidade: 20 + (counter % 15),
            status: status,
            catequista: catequistasMock[(counter + i) % catequistasMock.length],
            observacoes: null,
          ));
          counter++;
        }
      }
    }
  }

  List<TurmaModel> getAll() => List.unmodifiable(_mockData);

  Future<void> add(TurmaModel turma) async {
    _mockData.add(turma);
  }

  Future<void> update(TurmaModel turma) async {
    final idx = _mockData.indexWhere((t) => t.id == turma.id);
    if (idx != -1) {
      _mockData[idx] = turma;
    }
  }

  Future<void> remove(String id) async {
    _mockData.removeWhere((t) => t.id == id);
  }
}
