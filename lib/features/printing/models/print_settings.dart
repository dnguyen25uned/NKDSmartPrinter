import 'package:pdf/pdf.dart' as pdfdoc;

import '../services/page_order.dart';
import '../services/booklet_imposition.dart';

/// Chế độ in.
enum PrintMode { singleSided, manualDuplex, booklet }

/// Khổ giấy in.
///
/// Khổ giấy là cài đặt thật, không phải nhãn trang trí: nó quyết định
/// khổ trang của file PDF từng lượt in ([PassPdfBuilder]) và khổ giấy
/// mà app yêu cầu Windows Print Spooler dùng cho lệnh in
/// ([PrintDispatcher] qua `Printing.directPrintPdf(format: ...)`).
/// Khổ mặc định A4 khớp với bản web.
enum PaperSize { a4, letter, a3, legal }

extension PaperSizeFormat on PaperSize {
  /// Khổ trang PDF tương ứng (đơn vị point, 1 inch = 72 point).
  pdfdoc.PdfPageFormat get format {
    switch (this) {
      case PaperSize.a4:
        return pdfdoc.PdfPageFormat.a4;
      case PaperSize.letter:
        return pdfdoc.PdfPageFormat.letter;
      case PaperSize.a3:
        return pdfdoc.PdfPageFormat.a3;
      case PaperSize.legal:
        return pdfdoc.PdfPageFormat.legal;
    }
  }
}

/// Cài đặt in cho một lệnh in.
class PrintSettings {
  PrintSettings({
    required this.printerName,
    this.mode = PrintMode.manualDuplex,
    this.copies = 1,
    this.useCustomRange = false,
    this.rangeText = '',
    this.firstSide = FirstSide.oddFirst,
    this.flipEdge = FlipEdge.longEdge,
    this.pass2Reversed = false,
    this.bookletSpine = BookletSpine.left,
    this.paperSize = PaperSize.a4,
    this.insertBlankPage = true,
  });

  String printerName;
  PrintMode mode;
  int copies;
  bool useCustomRange;
  String rangeText;
  FirstSide firstSide;
  FlipEdge flipEdge;
  bool pass2Reversed;
  BookletSpine bookletSpine;
  PaperSize paperSize;

  /// Chêm 1 trang trắng vào lượt 2 khi tổng số trang in là số lẻ,
  /// để mặt sau của tờ cuối cùng có một "mặt" tường minh trong kế
  /// hoạch (hiện là "—") thay vì để trống ngầm.
  bool insertBlankPage;

  PrintSettings copy() => PrintSettings(
        printerName: printerName,
        mode: mode,
        copies: copies,
        useCustomRange: useCustomRange,
        rangeText: rangeText,
        firstSide: firstSide,
        flipEdge: flipEdge,
        pass2Reversed: pass2Reversed,
        bookletSpine: bookletSpine,
        paperSize: paperSize,
        insertBlankPage: insertBlankPage,
      );
}
