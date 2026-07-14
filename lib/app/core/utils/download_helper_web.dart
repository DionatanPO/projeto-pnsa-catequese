import 'dart:html' as html;
import 'dart:typed_data';

void downloadBytes(Uint8List bytes, String filename) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..target = 'download'
    ..download = filename;
  anchor.click();
  html.Url.revokeObjectUrl(url);
}
