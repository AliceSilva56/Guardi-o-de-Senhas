// lib/utils/app_pdf_colors.dart
import 'package:pdf/pdf.dart' as pdf;

/// Conversor + paleta em cima de PdfColor
class AppPdfColors {
  /// Aceita "#RRGGBB" ou "#AARRGGBB"
  static pdf.PdfColor fromHex(String hex) {
    var h = hex.replaceFirst('#', '');
    if (h.length == 6) {
      final r = int.parse(h.substring(0, 2), radix: 16);
      final g = int.parse(h.substring(2, 4), radix: 16);
      final b = int.parse(h.substring(4, 6), radix: 16);
      return pdf.PdfColor(r / 255, g / 255, b / 255);
    } else if (h.length == 8) {
      final a = int.parse(h.substring(0, 2), radix: 16);
      final r = int.parse(h.substring(2, 4), radix: 16);
      final g = int.parse(h.substring(4, 6), radix: 16);
      final b = int.parse(h.substring(6, 8), radix: 16);
      return pdf.PdfColor(r / 255, g / 255, b / 255, a / 255);
    } else {
      throw ArgumentError('Use #RRGGBB ou #AARRGGBB');
    }
  }

  // Paleta que você usou no PDF
  static final red50   = fromHex('#FFEBEE');
  static final red300  = fromHex('#E57373');
  static final red900  = fromHex('#B71C1C');

  static final blue700 = fromHex('#1976D2');

  static final grey300 = fromHex('#E0E0E0');
  static final grey600 = fromHex('#757575');
  static final white   = fromHex('#FFFFFF');
}
