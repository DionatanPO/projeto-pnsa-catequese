import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/turma_model.dart';

class TurmaRepository {
  bool _seeded = false;

  Future<List<TurmaModel>> getAll() async {
    if (!_seeded) {
      await _seedIfEmpty();
      _seeded = true;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('turmas')
        .orderBy('nome')
        .get();

    return snapshot.docs.map((doc) {
      return TurmaModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  Future<void> _seedIfEmpty() async {
    final existing = await FirebaseFirestore.instance.collection('turmas').count().get();
    if (existing.count! > 0) return;

    final turmas = [
      {'nome': 'Cordeirinhos 4 anos', 'ano': 2026, 'etapa': 'Cordeirinhos', 'diaHorario': 'Sábado, 09:00', 'localSala': '', 'status': 'Ativa', 'catequista': 'A definir', 'observacoes': 'Primeiros passos na oração, o amor de Jesus pelos pequeninos e a criação.', 'totalCatequizandos': 0},
      {'nome': 'Cordeirinhos 04 a 08 anos', 'ano': 2026, 'etapa': 'Cordeirinhos', 'diaHorario': 'Domingo, 10:00', 'localSala': '', 'status': 'Ativa', 'catequista': 'A definir', 'observacoes': 'Grupo de integração: vivência comunitária e musicalização litúrgica.', 'totalCatequizandos': 0},
      {'nome': 'Cordeirinhos 05 anos (Seg)', 'ano': 2026, 'etapa': 'Cordeirinhos', 'diaHorario': 'Segunda, 14:00', 'localSala': '', 'status': 'Ativa', 'catequista': 'A definir', 'observacoes': 'O bom Pastor, a família e a oração do Pai-Nosso.', 'totalCatequizandos': 0},
      {'nome': 'Cordeirinhos 05 anos (Ter)', 'ano': 2026, 'etapa': 'Cordeirinhos', 'diaHorario': 'Terça, 14:00', 'localSala': '', 'status': 'Ativa', 'catequista': 'A definir', 'observacoes': 'O bom Pastor, a família e a oração do Pai-Nosso.', 'totalCatequizandos': 0},
      {'nome': 'Cordeirinhos 06 anos', 'ano': 2026, 'etapa': 'Cordeirinhos', 'diaHorario': 'Sábado, 10:30', 'localSala': '', 'status': 'Ativa', 'catequista': 'A definir', 'observacoes': 'Os Mandamentos do Amor e o exemplo dos Santos.', 'totalCatequizandos': 0},
      {'nome': 'Cordeirinhos 06 e 07 anos', 'ano': 2026, 'etapa': 'Cordeirinhos', 'diaHorario': 'Sábado, 10:30', 'localSala': '', 'status': 'Ativa', 'catequista': 'A definir', 'observacoes': 'A Bíblia como história de amor e os amigos de Jesus.', 'totalCatequizandos': 0},
      {'nome': 'Cordeirinhos 07 anos', 'ano': 2026, 'etapa': 'Cordeirinhos', 'diaHorario': 'Sábado, 10:30', 'localSala': '', 'status': 'Ativa', 'catequista': 'A definir', 'observacoes': 'O nascimento, a vida e a missão de Jesus.', 'totalCatequizandos': 0},
      {'nome': 'Cordeirinhos 08 anos (Seg)', 'ano': 2026, 'etapa': 'Cordeirinhos', 'diaHorario': 'Segunda, 16:00', 'localSala': '', 'status': 'Ativa', 'catequista': 'A definir', 'observacoes': 'Introdução aos sacramentos e a importância da Missa.', 'totalCatequizandos': 0},
      {'nome': 'Cordeirinhos 08 anos (Ter)', 'ano': 2026, 'etapa': 'Cordeirinhos', 'diaHorario': 'Terça, 16:00', 'localSala': '', 'status': 'Ativa', 'catequista': 'A definir', 'observacoes': 'Introdução aos sacramentos e a importância da Missa.', 'totalCatequizandos': 0},
      {'nome': 'Primeira Eucaristia 1', 'ano': 2026, 'etapa': 'Iniciação Eucarística', 'diaHorario': 'Sábado, 08:30', 'localSala': '', 'status': 'Ativa', 'catequista': 'A definir', 'observacoes': 'Iniciação à vida de oração, estudo dos Mandamentos e o perdão (Confissão).', 'totalCatequizandos': 0},
      {'nome': 'Primeira Eucaristia 2', 'ano': 2026, 'etapa': 'Iniciação Eucarística', 'diaHorario': 'Sábado, 08:30', 'localSala': '', 'status': 'Ativa', 'catequista': 'A definir', 'observacoes': 'Preparação final para o encontro com Jesus Eucarístico (Missa e comunhão).', 'totalCatequizandos': 0},
      {'nome': 'Perseverança', 'ano': 2026, 'etapa': 'Perseverança', 'diaHorario': 'Domingo, 09:30', 'localSala': '', 'status': 'Ativa', 'catequista': 'A definir', 'observacoes': 'Fortalecimento do vínculo com a paróquia após a Eucaristia e serviço missionário.', 'totalCatequizandos': 0},
      {'nome': 'Crisma 1', 'ano': 2026, 'etapa': 'Crisma', 'diaHorario': 'Domingo, 18:00', 'localSala': '', 'status': 'Ativa', 'catequista': 'A definir', 'observacoes': 'O Espírito Santo, o Credo e a identidade do cristão na sociedade.', 'totalCatequizandos': 0},
      {'nome': 'Crisma 2', 'ano': 2026, 'etapa': 'Crisma', 'diaHorario': 'Domingo, 18:00', 'localSala': '', 'status': 'Ativa', 'catequista': 'A definir', 'observacoes': 'O compromisso missionário, os dons do Espírito e a vida em comunidade.', 'totalCatequizandos': 0},
      {'nome': 'Catequese de Adultos', 'ano': 2026, 'etapa': 'Catequese de Adultos', 'diaHorario': 'Quarta-feira, 20:00', 'localSala': '', 'status': 'Ativa', 'catequista': 'A definir', 'observacoes': 'Formação doutrinária básica para quem busca os Sacramentos de Iniciação ou deseja retomar a vida na fé.', 'totalCatequizandos': 0},
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (final t in turmas) {
      final ref = FirebaseFirestore.instance.collection('turmas').doc();
      batch.set(ref, t);
    }
    await batch.commit();
  }

  Future<bool> existsByName(String name, {String? excludeId}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('turmas')
        .where('nome', isEqualTo: name)
        .get();

    if (excludeId != null) {
      return snapshot.docs.any((doc) => doc.id != excludeId);
    }
    return snapshot.docs.isNotEmpty;
  }

  Future<void> add(TurmaModel turma) async {
    await FirebaseFirestore.instance.collection('turmas').add(turma.toMap());
  }

  Future<void> update(TurmaModel turma) async {
    await FirebaseFirestore.instance
        .collection('turmas')
        .doc(turma.id)
        .update(turma.toMap());
  }

  Future<void> remove(String id) async {
    await FirebaseFirestore.instance.collection('turmas').doc(id).delete();
  }
}
