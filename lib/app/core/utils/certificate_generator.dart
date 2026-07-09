import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:get/get.dart';
import '../../modules/catequizandos/models/catequizando_model.dart';
import '../../modules/matricula/models/matricula_model.dart';
import '../../modules/matricula/viewmodels/matricula_viewmodel.dart';
import '../../modules/turma/viewmodels/turma_viewmodel.dart';

class CertificateGenerator {
  static Future<void> generate(Catequizando catequizando) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.latoRegular();
    final fontBold = await PdfGoogleFonts.latoBold();

    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);

    final borderColor = PdfColor.fromHex('#8B0000');
    final textColor = PdfColor.fromHex('#2F4F4F');

    final textStyle = pw.TextStyle(font: font, color: textColor);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: borderColor, width: 2),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(40),
              child: pw.Column(
                children: [
                  pw.Text('PARÓQUIA NOSSA SENHORA AUXILIADORA',
                      style: pw.TextStyle(font: fontBold, fontSize: 24, color: textColor)),
                  pw.Text('Iporá - GO', style: textStyle.copyWith(fontSize: 16)),
                  pw.SizedBox(height: 10),
                  pw.Text('PASTORAL CATEQUÉTICA',
                      style: pw.TextStyle(font: fontBold, fontSize: 18, color: borderColor)),

                  pw.Spacer(),

                  pw.Text('CERTIFICADO DE CADASTRO',
                      style: pw.TextStyle(font: fontBold, fontSize: 36, color: textColor)),
                  pw.SizedBox(height: 20),

                  pw.Text('Certificamos, para os devidos fins, que o(a) catequizando(a):',
                      style: textStyle.copyWith(fontSize: 16)),
                  pw.SizedBox(height: 20),

                  pw.Text(catequizando.nome.toUpperCase(),
                      style: pw.TextStyle(font: fontBold, fontSize: 28, color: borderColor)),

                  pw.SizedBox(height: 20),
                  pw.Text(
                      'realizou seu cadastro no sistema da Pastoral Catequética em $formattedDate.',
                      textAlign: pw.TextAlign.center,
                      style: textStyle.copyWith(fontSize: 16)),

                  pw.Spacer(),

                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetail('Turma', Get.find<MatriculaViewModel>().getNomeTurmaAtual(catequizando.id, Get.find<TurmaViewModel>().turmas) ?? '', borderColor, font, fontBold),
                      _buildDetail('Responsável', catequizando.responsavel, borderColor, font, fontBold),
                    ],
                  ),

                  pw.Spacer(),

                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        children: [
                          pw.Text('__________________________', style: textStyle),
                          pw.Text('Secretaria Pastoral', style: textStyle.copyWith(fontSize: 12)),
                        ],
                      ),
                      pw.Text('Iporá/GO, $formattedDate', style: textStyle.copyWith(fontSize: 12)),
                    ],
                  ),

                  pw.SizedBox(height: 30),

                  pw.Text(
                    'Documento autenticado e gerado automaticamente pelo sistema da PARÓQUIA NOSSA SENHORA AUXILIADORA – IPORÁ/GO.',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: font, fontSize: 8, fontStyle: pw.FontStyle.italic, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'certificado_${catequizando.nome.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<void> generateHistorico(
    Catequizando catequizando,
    List<({Matricula matricula, String? turmaNome})> historico,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.latoRegular();
    final fontBold = await PdfGoogleFonts.latoBold();
    final textColor = PdfColor.fromHex('#2F4F4F');
    final primaryColor = PdfColor.fromHex('#8B0000');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          children: [
            pw.Text('PARÓQUIA NOSSA SENHORA AUXILIADORA',
                style: pw.TextStyle(font: fontBold, fontSize: 18, color: primaryColor)),
            pw.Text('PASTORAL CATEQUÉTICA',
                style: pw.TextStyle(font: fontBold, fontSize: 14, color: primaryColor)),
            pw.SizedBox(height: 8),
            pw.Divider(color: primaryColor),
            pw.SizedBox(height: 12),
          ],
        ),
        build: (context) => [
          pw.Text('Histórico de Matrículas',
              style: pw.TextStyle(font: fontBold, fontSize: 22, color: textColor)),
          pw.SizedBox(height: 4),
          pw.Text(catequizando.nome.toUpperCase(),
              style: pw.TextStyle(font: fontBold, fontSize: 16, color: primaryColor)),
          pw.SizedBox(height: 20),
          if (historico.isEmpty)
            pw.Text('Nenhum registro encontrado.',
                style: pw.TextStyle(font: font, fontSize: 12, color: textColor))
          else
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: primaryColor),
              cellStyle: pw.TextStyle(font: font, fontSize: 10, color: textColor),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
              },
              headers: ['Turma', 'Ano', 'Status', 'Período'],
              data: historico.map((item) {
                final m = item.matricula;
                final periodo = m.dataConclusao != null
                    ? '${DateFormat('dd/MM/yyyy').format(m.dataMatricula)} a ${DateFormat('dd/MM/yyyy').format(m.dataConclusao!)}'
                    : '${DateFormat('dd/MM/yyyy').format(m.dataMatricula)} - presente';
                return [
                  item.turmaNome ?? 'Turma removida',
                  m.ano.toString(),
                  m.status,
                  periodo,
                ];
              }).toList(),
            ),
          pw.SizedBox(height: 30),
          pw.Divider(color: PdfColor.fromHex('#8B00004D')),
          pw.SizedBox(height: 8),
          pw.Text(
            'Documento gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}.',
            style: pw.TextStyle(font: font, fontSize: 8, fontStyle: pw.FontStyle.italic, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'historico_${catequizando.nome.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<void> generateFicha(
    Catequizando catequizando, {
    bool withHistory = false,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.latoRegular();
    final fontBold = await PdfGoogleFonts.latoBold();
    final primaryColor = PdfColor.fromHex('#8B0000');
    final textColor = PdfColor.fromHex('#2F4F4F');

    final matriculaVm = Get.find<MatriculaViewModel>();
    final turmaVm = Get.find<TurmaViewModel>();

    int idade() {
      final hoje = DateTime.now();
      int age = hoje.year - catequizando.dataNascimento.year;
      if (hoje.month < catequizando.dataNascimento.month ||
          (hoje.month == catequizando.dataNascimento.month &&
              hoje.day < catequizando.dataNascimento.day)) {
        age--;
      }
      return age;
    }

    pw.Widget field(String label, String value) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(font: fontBold, fontSize: 9, color: primaryColor)),
          pw.SizedBox(height: 2),
          pw.Text(value.isEmpty ? '-' : value,
              style: pw.TextStyle(font: font, fontSize: 12, color: textColor)),
          pw.SizedBox(height: 6),
        ],
      );
    }

    pw.Widget sectionHeader(String title) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: pw.BoxDecoration(
          color: primaryColor,
          borderRadius: pw.BorderRadius.circular(3),
        ),
        child: pw.Text(title,
            style: pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColors.white)),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          children: [
            pw.Text('PARÓQUIA NOSSA SENHORA AUXILIADORA',
                style: pw.TextStyle(font: fontBold, fontSize: 18, color: primaryColor)),
            pw.Text('PASTORAL CATEQUÉTICA',
                style: pw.TextStyle(font: fontBold, fontSize: 14, color: primaryColor)),
            pw.SizedBox(height: 6),
            pw.Divider(color: primaryColor),
            pw.SizedBox(height: 8),
            pw.Text('FICHA DE CADASTRO',
                style: pw.TextStyle(font: fontBold, fontSize: 20, color: textColor)),
            pw.SizedBox(height: 16),
          ],
        ),
        build: (context) {
          final widgets = <pw.Widget>[
            sectionHeader('IDENTIFICAÇÃO'),
            pw.SizedBox(height: 8),
            field('Nome', catequizando.nome),
            pw.Row(
              children: [
                pw.Expanded(child: field('Sexo', catequizando.sexo)),
                pw.SizedBox(width: 24),
                pw.Expanded(child: field('Data de Nascimento',
                    DateFormat('dd/MM/yyyy').format(catequizando.dataNascimento))),
              ],
            ),
            pw.Row(
              children: [
                pw.Expanded(child: field('Idade', '${idade()} anos')),
                pw.SizedBox(width: 24),
                pw.Expanded(child: field('Status', catequizando.status)),
              ],
            ),
            field('Turma',
                matriculaVm.getNomeTurmaAtual(catequizando.id, turmaVm.turmas) ?? '-'),

            pw.SizedBox(height: 16),
            sectionHeader('HISTÓRICO SACRAMENTAL'),
            pw.SizedBox(height: 8),
            field('Batizado', catequizando.batizado ? 'Sim' : 'Não'),
            if (catequizando.batizado) ...[
              field('Local do Batismo', catequizando.localBatismo ?? '-'),
              field('Primeira Eucaristia',
                  catequizando.fezPrimeiraEucaristia == true ? 'Sim' : 'Não'),
            ],

            pw.SizedBox(height: 16),
            sectionHeader('CONTATOS E RESPONSÁVEIS'),
            pw.SizedBox(height: 8),
            field('Responsável', catequizando.responsavel),
            field('Parentesco', catequizando.parentesco),
            field('Telefone', catequizando.telefone),
            pw.Row(
              children: [
                pw.Expanded(child: field('Endereço', catequizando.endereco)),
                pw.SizedBox(width: 24),
                pw.Expanded(child: field('Número', catequizando.numero)),
              ],
            ),
            pw.Row(
              children: [
                pw.Expanded(child: field('Bairro', catequizando.bairro)),
                pw.SizedBox(width: 24),
                pw.Expanded(child: field('CEP', catequizando.cep)),
              ],
            ),

            pw.SizedBox(height: 16),
            sectionHeader('SAÚDE E CUIDADOS'),
            pw.SizedBox(height: 8),
            field('Possui restrição', catequizando.possuiRestricao ? 'Sim' : 'Não'),
            if (catequizando.possuiRestricao)
              field('Detalhamento', catequizando.detalheRestricao ?? '-'),

            if (withHistory) ...[
              pw.SizedBox(height: 28),
              pw.Text('Histórico de Matrículas',
                  style: pw.TextStyle(font: fontBold, fontSize: 16, color: textColor)),
              pw.SizedBox(height: 12),
              _buildHistoricoWidget(catequizando, font, fontBold, primaryColor, textColor),
            ],

            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColor.fromHex('#8B00004D')),
            pw.SizedBox(height: 6),
            pw.Text(
              'Documento gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}.',
              style: pw.TextStyle(font: font, fontSize: 8, fontStyle: pw.FontStyle.italic, color: PdfColors.grey600),
            ),
          ];
          return widgets;
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'ficha_${catequizando.nome.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _buildHistoricoWidget(
    Catequizando catequizando,
    pw.Font font,
    pw.Font fontBold,
    PdfColor primaryColor,
    PdfColor textColor,
  ) {
    final matriculaVm = Get.find<MatriculaViewModel>();
    final turmaVm = Get.find<TurmaViewModel>();

    final historico = matriculaVm.getHistoricoComTurma(
      catequizando.id,
      turmaVm.turmas,
    );

    if (historico.isEmpty) {
      return pw.Text('Nenhum registro encontrado.',
          style: pw.TextStyle(font: font, fontSize: 12, color: textColor));
    }

    return pw.Table.fromTextArray(
      headerStyle: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: primaryColor),
      cellStyle: pw.TextStyle(font: font, fontSize: 10, color: textColor),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
      },
      headers: ['Turma', 'Ano', 'Status', 'Período'],
      data: historico.map((item) {
        final m = item.matricula;
        final periodo = m.dataConclusao != null
            ? '${DateFormat('dd/MM/yyyy').format(m.dataMatricula)} a ${DateFormat('dd/MM/yyyy').format(m.dataConclusao!)}'
            : '${DateFormat('dd/MM/yyyy').format(m.dataMatricula)} - presente';
        return [
          item.turmaNome ?? 'Turma removida',
          m.ano.toString(),
          m.status,
          periodo,
        ];
      }).toList(),
    );
  }

  static pw.Widget _buildDetail(String label, String value, PdfColor color, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Text(label.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 10, color: color)),
        pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 14, color: color)),
      ],
    );
  }
}
