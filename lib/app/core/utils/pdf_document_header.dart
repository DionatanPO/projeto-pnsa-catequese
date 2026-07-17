import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

pw.Widget buildPdfHeader({
  required pw.MemoryImage logoImage,
  required pw.Font font,
  required pw.Font fontBold,
  required PdfColor primaryColor,
  required PdfColor textColor,
  String? subtitle,
  bool showSubtitle = true,
  bool landscape = false,
}) {
  final logoSize = landscape ? 64.0 : 48.0;
  final titleSize = landscape ? 20.0 : 16.0;
  final pastoralSize = landscape ? 14.0 : 12.0;
  final infoSize = landscape ? 11.0 : 9.0;

  final textColumn = pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'PARÓQUIA NOSSA SENHORA AUXILIADORA',
        style: pw.TextStyle(font: fontBold, fontSize: titleSize, color: textColor, letterSpacing: 0.5),
      ),
      pw.SizedBox(height: 6),
      pw.Text(
        'PASTORAL CATEQUÉTICA',
        style: pw.TextStyle(font: fontBold, fontSize: pastoralSize, color: primaryColor, letterSpacing: 1.0),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'Praça da Matriz, Centro, Iporá-GO  |  (64) 3674-3149',
        style: pw.TextStyle(font: font, fontSize: infoSize, color: PdfColors.grey600),
      ),
      pw.Text(
        'Av. Pará, 491 - Centro, Iporá-GO, 76200-000  |  auxiliadoraipora@gmail.com',
        style: pw.TextStyle(font: font, fontSize: infoSize, color: PdfColors.grey600),
      ),
    ],
  );

  return pw.Column(
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Image(logoImage, width: logoSize, height: logoSize),
          pw.SizedBox(width: landscape ? 16 : 12),
          pw.Expanded(child: textColumn),
        ],
      ),
      pw.SizedBox(height: landscape ? 8 : 8),
      if (showSubtitle && subtitle != null) ...[
        pw.SizedBox(height: landscape ? 6 : 10),
        pw.Text(
          subtitle,
          style: pw.TextStyle(font: fontBold, fontSize: landscape ? 22 : 18, color: textColor, letterSpacing: 0.5),
        ),
        pw.SizedBox(height: landscape ? 0 : 12),
      ],
    ],
  );
}
