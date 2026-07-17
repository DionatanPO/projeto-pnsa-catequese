import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../modules/relatorio/viewmodels/relatorio_viewmodel.dart';
import 'pdf_document_header.dart';

class RelatorioGenerator {
  static Future<void> generate(RelatorioViewModel vm) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.latoRegular();
    final fontBold = await PdfGoogleFonts.latoBold();
    final primaryColor = PdfColor.fromHex('#9E9E9E');
    final textColor = PdfColor.fromHex('#2F4F4F');
    const greyColor = PdfColors.grey600;
    final now = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    final statusItems = vm.statusCounts;
    final etapasItems = vm.turmasPorEtapa;
    final encontrosItems = vm.encontrosRealizados;
    final faixaItems = vm.faixaEtaria;

    pw.Widget sectionHeader(String title) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: pw.BoxDecoration(
          color: primaryColor,
          borderRadius: pw.BorderRadius.circular(3),
        ),
        child: pw.Text(title,
            style: pw.TextStyle(font: fontBold, fontSize: 13, color: PdfColors.white)),
      );
    }

    pw.Widget footer() {
      return pw.Column(
        children: [
          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 4),
          pw.Text(
            'Relatório gerado em $now.',
            style: pw.TextStyle(font: font, fontSize: 8, fontStyle: pw.FontStyle.italic, color: greyColor),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'PARÓQUIA NOSSA SENHORA AUXILIADORA – IPORÁ/GO',
            style: pw.TextStyle(font: font, fontSize: 8, fontStyle: pw.FontStyle.italic, color: greyColor),
          ),
        ],
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
            buildPdfHeader(
              logoImage: logoImage,
              font: font,
              fontBold: fontBold,
              primaryColor: primaryColor,
              textColor: textColor,
              subtitle: 'RELATÓRIO GERENCIAL',
              showSubtitle: true,
              landscape: false,
            ),
            pw.Divider(color: primaryColor),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (context) => pw.Text(
          'Página ${context.pageNumber}',
          style: pw.TextStyle(font: font, fontSize: 8, color: greyColor),
          textAlign: pw.TextAlign.center,
        ),
        build: (context) {
          final children = <pw.Widget>[];

          children.add(sectionHeader('1. DISTRIBUIÇÃO POR STATUS'));
          children.add(pw.SizedBox(height: 10));

          final totalStatus = statusItems.fold(0, (sum, s) => sum + s.count);
          children.add(pw.Text('Total de catequizandos: $totalStatus',
              style: pw.TextStyle(font: font, fontSize: 10, color: textColor)));
          children.add(pw.SizedBox(height: 8));

          children.add(pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: primaryColor),
            cellStyle: pw.TextStyle(font: font, fontSize: 10, color: textColor),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
            },
            headers: ['Status', 'Quantidade', 'Percentual'],
            data: statusItems.map((s) => [
              s.status,
              s.count.toString(),
              '${(s.percent * 100).toStringAsFixed(0)}%',
            ]).toList(),
          ));

          children.add(pw.SizedBox(height: 24));

          children.add(sectionHeader('2. TURMAS POR ETAPA'));
          children.add(pw.SizedBox(height: 10));

          final totalTurmas = etapasItems.fold(0, (sum, i) => sum + i.totalTurmas);
          final totalAlunos = etapasItems.fold(0, (sum, i) => sum + i.totalAlunos);
          children.add(pw.Text('Total de turmas: $totalTurmas | Total de alunos: $totalAlunos',
              style: pw.TextStyle(font: font, fontSize: 10, color: textColor)));
          children.add(pw.SizedBox(height: 8));

          children.add(pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: primaryColor),
            cellStyle: pw.TextStyle(font: font, fontSize: 10, color: textColor),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
            },
            headers: ['Etapa', 'Turmas', 'Alunos'],
            data: etapasItems.map((e) => [
              e.etapa,
              e.totalTurmas.toString(),
              e.totalAlunos.toString(),
            ]).toList(),
          ));

          children.add(pw.SizedBox(height: 24));

          children.add(sectionHeader('3. ENCONTROS REALIZADOS'));
          children.add(pw.SizedBox(height: 10));

          final totalEncontros = encontrosItems.fold(0, (sum, i) => sum + i.totalEncontros);
          children.add(pw.Text('Total de encontros: $totalEncontros',
              style: pw.TextStyle(font: font, fontSize: 10, color: textColor)));
          children.add(pw.SizedBox(height: 8));

          children.add(pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: primaryColor),
            cellStyle: pw.TextStyle(font: font, fontSize: 10, color: textColor),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
            },
            headers: ['Turma', 'Encontros', 'Média Presenças'],
            data: encontrosItems.map((e) => [
              e.turmaNome,
              e.totalEncontros.toString(),
              e.mediaPresenca.toStringAsFixed(0),
            ]).toList(),
          ));

          children.add(pw.SizedBox(height: 24));

          children.add(sectionHeader('4. DISTRIBUIÇÃO POR FAIXA ETÁRIA'));
          children.add(pw.SizedBox(height: 10));

          final totalFaixa = faixaItems.fold(0, (sum, i) => sum + i.total);
          children.add(pw.Text('Total de catequizandos: $totalFaixa',
              style: pw.TextStyle(font: font, fontSize: 10, color: textColor)));
          children.add(pw.SizedBox(height: 8));

          children.add(pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: primaryColor),
            cellStyle: pw.TextStyle(font: font, fontSize: 10, color: textColor),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
            },
            headers: ['Faixa Etária', 'Masculino', 'Feminino', 'Total'],
            data: faixaItems.map((f) => [
              f.faixa,
              f.masculino.toString(),
              f.feminino.toString(),
              f.total.toString(),
            ]).toList(),
          ));

          children.add(pw.SizedBox(height: 20));
          children.add(footer());

          return children;
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'relatorio_gerencial_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf',
    );
  }
}
