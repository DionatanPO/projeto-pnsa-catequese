import 'package:flutter/services.dart' show rootBundle;
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

    final borderColor = PdfColor.fromHex('#9E9E9E');
    final textColor = PdfColor.fromHex('#2F4F4F');

    final textStyle = pw.TextStyle(font: font, color: textColor);

    final logoBytes = (await rootBundle.load('assets/images/logo.jpg')).buffer.asUint8List();
    final logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: borderColor, width: 2),
            ),
            child: pw.Container(
              margin: const pw.EdgeInsets.all(4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300, width: 1),
              ),
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 36),
                child: pw.Column(
                  children: [
                    // Cabeçalho Paroquial
                    pw.Image(logoImage, width: 64, height: 64),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'PARÓQUIA NOSSA SENHORA AUXILIADORA',
                      style: pw.TextStyle(font: fontBold, fontSize: 20, color: textColor, letterSpacing: 0.5),
                    ),
                    pw.Text('Iporá - GO', style: textStyle.copyWith(fontSize: 13, color: PdfColors.grey700)),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'PASTORAL CATEQUÉTICA',
                      style: pw.TextStyle(font: fontBold, fontSize: 14, color: borderColor, letterSpacing: 1.0),
                    ),

                    pw.Spacer(flex: 2),

                    // Título do Certificado
                    pw.Text(
                      'CERTIFICADO DE CADASTRO',
                      style: pw.TextStyle(font: fontBold, fontSize: 32, color: textColor, letterSpacing: 0.5),
                    ),
                    pw.SizedBox(height: 16),

                    pw.Text(
                      'Certificamos, para os devidos fins, que o(a) catequizando(a):',
                      style: textStyle.copyWith(fontSize: 14),
                    ),
                    pw.SizedBox(height: 14),

                    // Nome do Aluno Destacado
                    pw.Text(
                      catequizando.nome.toUpperCase(),
                      style: pw.TextStyle(font: fontBold, fontSize: 24, color: borderColor, letterSpacing: 0.5),
                    ),

                    pw.SizedBox(height: 14),
                    pw.Text(
                      'realizou seu cadastro no sistema da Pastoral Catequética em $formattedDate.',
                      textAlign: pw.TextAlign.center,
                      style: textStyle.copyWith(fontSize: 14),
                    ),

                    pw.Spacer(flex: 2),

                    // Detalhes Complementares
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetail('Turma', Get.find<MatriculaViewModel>().getNomeTurmaAtual(catequizando.id, Get.find<TurmaViewModel>().turmas) ?? '-', borderColor, font, fontBold),
                        _buildDetail('Responsável', catequizando.responsavel, borderColor, font, fontBold),
                      ],
                    ),

                    pw.Spacer(flex: 3),

                    // Assinatura e Data
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('____________________________________', style: textStyle.copyWith(color: PdfColors.grey500)),
                            pw.SizedBox(height: 4),
                            pw.Text('Secretaria Pastoral', style: textStyle.copyWith(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                        pw.Text('Iporá/GO, $formattedDate', style: textStyle.copyWith(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),

                    pw.SizedBox(height: 24),

                    // Autenticação de Rodapé
                    pw.Text(
                      'Documento autenticado e gerado automaticamente pelo sistema da PARÓQUIA NOSSA SENHORA AUXILIADORA – IPORÁ/GO.',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(font: font, fontSize: 7, fontStyle: pw.FontStyle.italic, color: PdfColors.grey500),
                    ),
                  ],
                ),
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
    final primaryColor = PdfColor.fromHex('#9E9E9E');

    final logoBytes = (await rootBundle.load('assets/images/logo.jpg')).buffer.asUint8List();
    final logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          children: [
            pw.Image(logoImage, width: 48, height: 48),
            pw.SizedBox(height: 8),
            pw.Text(
              'PARÓQUIA NOSSA SENHORA AUXILIADORA',
              style: pw.TextStyle(font: fontBold, fontSize: 16, color: primaryColor, letterSpacing: 0.5),
            ),
            pw.Text(
              'PASTORAL CATEQUÉTICA',
              style: pw.TextStyle(font: fontBold, fontSize: 12, color: primaryColor, letterSpacing: 0.8),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: primaryColor, thickness: 1),
            pw.SizedBox(height: 12),
          ],
        ),
        build: (context) => [
          pw.Text('Histórico de Matrículas', style: pw.TextStyle(font: fontBold, fontSize: 20, color: textColor)),
          pw.SizedBox(height: 4),
          pw.Text(catequizando.nome.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 14, color: primaryColor)),
          pw.SizedBox(height: 20),
          if (historico.isEmpty)
            pw.Text('Nenhum registro encontrado.', style: pw.TextStyle(font: font, fontSize: 11, color: textColor))
          else
            pw.Table.fromTextArray(
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.8),
              ),
              headerStyle: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(4)),
              ),
              cellStyle: pw.TextStyle(font: font, fontSize: 9, color: textColor),
              cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
          pw.Divider(color: PdfColors.grey300, thickness: 0.5),
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
    final primaryColor = PdfColor.fromHex('#9E9E9E');
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

    // Gerador de campos estruturado (estilo formulário administrativo)
    pw.Widget field(String label, String value) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8),
        padding: const pw.EdgeInsets.only(bottom: 3),
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label.toUpperCase(),
              style: pw.TextStyle(font: fontBold, fontSize: 8, color: primaryColor, letterSpacing: 0.5),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              value.isEmpty ? '-' : value,
              style: pw.TextStyle(font: font, fontSize: 11, color: textColor),
            ),
          ],
        ),
      );
    }

    pw.Widget sectionHeader(String title) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 14, bottom: 8),
        padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: pw.BoxDecoration(
          color: primaryColor,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          title,
          style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white, letterSpacing: 0.5),
        ),
      );
    }

    final logoBytes = (await rootBundle.load('assets/images/logo.jpg')).buffer.asUint8List();
    final logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          children: [
            pw.Image(logoImage, width: 48, height: 48),
            pw.SizedBox(height: 8),
            pw.Text(
              'PARÓQUIA NOSSA SENHORA AUXILIADORA',
              style: pw.TextStyle(font: fontBold, fontSize: 16, color: primaryColor, letterSpacing: 0.5),
            ),
            pw.Text(
              'PASTORAL CATEQUÉTICA',
              style: pw.TextStyle(font: fontBold, fontSize: 12, color: primaryColor, letterSpacing: 0.8),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: primaryColor, thickness: 1),
            pw.SizedBox(height: 10),
            pw.Text(
              'FICHA DE CADASTRO',
              style: pw.TextStyle(font: fontBold, fontSize: 18, color: textColor, letterSpacing: 0.5),
            ),
            pw.SizedBox(height: 12),
          ],
        ),
        build: (context) {
          return [
            sectionHeader('IDENTIFICAÇÃO'),
            field('Nome', catequizando.nome),
            pw.Row(
              children: [
                pw.Expanded(child: field('Sexo', catequizando.sexo)),
                pw.SizedBox(width: 16),
                pw.Expanded(child: field('Data de Nascimento', DateFormat('dd/MM/yyyy').format(catequizando.dataNascimento))),
              ],
            ),
            pw.Row(
              children: [
                pw.Expanded(child: field('Idade', '${idade()} anos')),
                pw.SizedBox(width: 16),
                pw.Expanded(child: field('Status', catequizando.status)),
              ],
            ),
            field('Turma', matriculaVm.getNomeTurmaAtual(catequizando.id, turmaVm.turmas) ?? '-'),

            sectionHeader('HISTÓRICO SACRAMENTAL'),
            field('Batizado', catequizando.batizado ? 'Sim' : 'Não'),
            if (catequizando.batizado) ...[
              field('Local do Batismo', catequizando.localBatismo ?? '-'),
              field('Primeira Eucaristia', catequizando.fezPrimeiraEucaristia == true ? 'Sim' : 'Não'),
            ],

            sectionHeader('CONTATOS E RESPONSÁVEIS'),
            pw.Row(
              children: [
                pw.Expanded(child: field('Responsável', catequizando.responsavel)),
                pw.SizedBox(width: 16),
                pw.Expanded(child: field('Parentesco', catequizando.parentesco)),
              ],
            ),
            field('Telefone', catequizando.telefone),
            pw.Row(
              children: [
                pw.Expanded(child: field('Endereço', catequizando.endereco)),
                pw.SizedBox(width: 16),
                pw.Expanded(child: field('Número', catequizando.numero)),
              ],
            ),
            pw.Row(
              children: [
                pw.Expanded(child: field('Bairro', catequizando.bairro)),
                pw.SizedBox(width: 16),
                pw.Expanded(child: field('CEP', catequizando.cep)),
              ],
            ),

            sectionHeader('SAÚDE E CUIDADOS'),
            field('Possui restrição de saúde', catequizando.possuiRestricao ? 'Sim' : 'Não'),
            if (catequizando.possuiRestricao)
              field('Detalhamento da Restrição', catequizando.detalheRestricao ?? '-'),

            if (withHistory) ...[
              pw.SizedBox(height: 18),
              pw.Text('Histórico de Matrículas', style: pw.TextStyle(font: fontBold, fontSize: 13, color: textColor)),
              pw.SizedBox(height: 8),
              _buildHistoricoWidget(catequizando, font, fontBold, primaryColor, textColor),
            ],

            pw.SizedBox(height: 24),
            pw.Divider(color: PdfColors.grey300, thickness: 0.5),
            pw.SizedBox(height: 6),
            pw.Text(
              'Documento gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}.',
              style: pw.TextStyle(font: font, fontSize: 8, fontStyle: pw.FontStyle.italic, color: PdfColors.grey600),
            ),
          ];
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
      return pw.Text('Nenhum registro encontrado.', style: pw.TextStyle(font: font, fontSize: 11, color: textColor));
    }

    return pw.Table.fromTextArray(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
        bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.8),
      ),
      headerStyle: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: primaryColor),
      cellStyle: pw.TextStyle(font: font, fontSize: 9, color: textColor),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
        pw.Text(label.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 8, color: color, letterSpacing: 0.5)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 12, color: color)),
      ],
    );
  }
}