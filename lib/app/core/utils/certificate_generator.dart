import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../modules/catequizandos/models/catequizando_model.dart';

class CertificateGenerator {
  static Future<void> generate(Catequizando catequizando) async {
    final pdf = pw.Document();

    // Carrega uma fonte com suporte completo a caracteres
    final font = await PdfGoogleFonts.latoRegular();
    final fontBold = await PdfGoogleFonts.latoBold();

    final now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(now);
    final birthDate = DateFormat('dd/MM/yyyy').format(catequizando.dataNascimento);

    // Paleta de Cores: Clássica e Eclesiástica
    final borderColor = PdfColor.fromHex('#8B0000'); // Vermelho Eclesiástico (Dark Red)
    final textColor = PdfColor.fromHex('#2F4F4F'); // Dark Slate Gray (Texto profissional)

    // Estilo base
    final textStyle = pw.TextStyle(font: font, color: textColor);
    final boldStyle = pw.TextStyle(font: fontBold, color: textColor);
    final boldColoredStyle = pw.TextStyle(font: fontBold, color: borderColor);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape, // Orientação paisagem para certificados
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
                  // Cabeçalho institucional
                  pw.Text('PARÓQUIA NOSSA SENHORA AUXILIADORA',
                      style: pw.TextStyle(font: fontBold, fontSize: 24, color: textColor)),
                  pw.Text('Iporá - GO', style: textStyle.copyWith(fontSize: 16)),
                  pw.SizedBox(height: 10),
                  pw.Text('PASTORAL CATEQUÉTICA',
                      style: pw.TextStyle(font: fontBold, fontSize: 18, color: borderColor)),
                  
                  pw.Spacer(),

                  // Título
                  pw.Text('CERTIFICADO DE CADASTRO',
                      style: pw.TextStyle(font: fontBold, fontSize: 36, color: textColor)),
                  pw.SizedBox(height: 20),
                  
                  // Texto do Certificado
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
                  
                  // Detalhes extras
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetail('Turma', catequizando.turmaNome, borderColor, font, fontBold),
                      _buildDetail('Responsável', catequizando.responsavel, borderColor, font, fontBold),
                    ],
                  ),
                  
                  pw.Spacer(),
                  
                  // Assinatura e Data
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
                  
                  // Rodapé Autenticação
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

  static pw.Widget _buildDetail(String label, String value, PdfColor color, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Text(label.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 10, color: color)),
        pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 14, color: color)),
      ],
    );
  }
}
