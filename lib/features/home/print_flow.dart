import 'dart:typed_data';

import '../../core/app_error.dart';
import '../../core/result.dart';
import '../documents/models/document_item.dart';
import '../printing/models/print_settings.dart';
import '../printing/services/booklet_imposition.dart';
import '../printing/services/duplex_controller.dart';
import '../printing/services/page_order.dart';
import '../printing/services/page_range.dart';
import '../printing/services/pass_pdf_builder.dart';
import '../printing/services/print_dispatcher.dart';

/// Kế hoạch in: danh sách trang/mặt cho từng lượt + tổng số tờ giấy.
class PrintPlan {
  const PrintPlan({
    required this.pass1Pages,
    required this.pass2Pages,
    required this.pass1BookletSides,
    required this.pass2BookletSides,
    required this.isBooklet,
    required this.totalSheets,
  });

  /// Lượt 1 (in 1 mặt / 2 mặt thủ công): danh sách trang 1-based.
  /// Một mục `null` = một trang trắng tường minh (chỉ xuất hiện ở
  /// lượt 2 khi bật "chêm trang trắng" — lượt 1 không bao giờ có null).
  final List<int?> pass1Pages;

  /// Lượt 2 (chỉ 2 mặt thủ công / đóng sách). Null nếu in 1 mặt.
  /// Một mục `null` = mặt sau trắng tường minh của tờ cuối cùng khi
  /// tổng số trang in là số lẻ và bật "chêm trang trắng".
  final List<int?>? pass2Pages;

  /// Lượt 1 đóng sách: danh sách mặt (mỗi mặt = 1 tờ A4 ngang).
  final List<BookletSide> pass1BookletSides;

  /// Lượt 2 đóng sách (thứ tự tờ ngược — xem BookletImposition).
  final List<BookletSide> pass2BookletSides;

  final bool isBooklet;
  final int totalSheets;
}

/// Điều phối một lệnh in: tính kế hoạch, tạo PDF từng lượt, phát lệnh
/// qua spooler, điều khiển máy trạng thái 2 lượt (xác nhận lật giấy).
class PrintFlow {
  PrintFlow({
    required PrintDispatcher dispatcher,
    required PassPdfBuilder pdfBuilder,
  })  : _dispatcher = dispatcher,
        _pdfBuilder = pdfBuilder;

  final PrintDispatcher _dispatcher;
  final PassPdfBuilder _pdfBuilder;

  /// Tính kế hoạch in từ tài liệu + cài đặt. Không phát lệnh in.
  Result<PrintPlan> plan({
    required DocumentItem document,
    required PrintSettings settings,
  }) {
    final total = document.pageCount;
    if (total == null || total < 1) {
      return Err(
        const AppError(messageKey: 'error_document_no_pages'),
      );
    }
    List<int> selected;
    if (settings.useCustomRange) {
      final parsed = PageRange.parse(settings.rangeText, total);
      if (parsed is Err<List<int>>) return Err(parsed.error);
      selected = (parsed as Ok<List<int>>).value;
    } else {
      selected = PageRange.all(total);
    }
    if (selected.isEmpty) {
      return Err(
        const AppError(messageKey: 'error_page_range_empty'),
      );
    }
    switch (settings.mode) {
      case PrintMode.singleSided:
        final pages = PageOrder.applyCopies(selected, settings.copies);
        return Ok(
          PrintPlan(
            pass1Pages: List<int?>.of(pages),
            pass2Pages: null,
            pass1BookletSides: const [],
            pass2BookletSides: const [],
            isBooklet: false,
            totalSheets: pages.length,
          ),
        );
      case PrintMode.manualDuplex:
        final p1 = PageOrder.duplexPassPages(
          pages: selected,
          firstSide: settings.firstSide,
          firstPass: true,
        );
        // Lượt 2: tính theo thứ tự tự nhiên trước, rồi mới chêm trang
        // trắng + đảo ngược — để khi đảo ngược, trang trắng (mặt sau
        // của tờ cuối lượt 1) cũng đảo theo đúng vị trí trong dãy in.
        final p2Natural = PageOrder.duplexPassPages(
          pages: selected,
          firstSide: settings.firstSide,
          firstPass: false,
        );
        List<int?> p2 = List<int?>.of(p2Natural);
        // Tổng số trang IN (sau khi lọc theo phạm vi) lẻ => tờ cuối
        // chỉ có mặt trước; khi bật "chêm trang trắng", thêm một mặt
        // sau trắng tường minh để lượt 2 đủ mặt với lượt 1.
        if (settings.insertBlankPage && selected.length.isOdd) {
          p2.add(null);
        }
        if (settings.pass2Reversed) {
          p2 = p2.reversed.toList();
        }
        final p1c = PageOrder.applyCopies(p1, settings.copies);
        final p2c = PageOrder.applyCopies(p2, settings.copies);
        return Ok(
          PrintPlan(
            pass1Pages: List<int?>.of(p1c),
            pass2Pages: p2c,
            pass1BookletSides: const [],
            pass2BookletSides: const [],
            isBooklet: false,
            // Mỗi trang lượt 1 = 1 mặt của 1 tờ giấy.
            totalSheets: p1c.length,
          ),
        );
      case PrintMode.booklet:
        final outer = BookletImposition.outerPass(
          totalPages: total,
          spine: settings.bookletSpine,
        );
        final inner = BookletImposition.innerPass(
          totalPages: total,
          spine: settings.bookletSpine,
        );
        // Số bản: lặp lại từng mặt liên tiếp (mỗi mặt = 1 tờ).
        List<BookletSide> expand(List<BookletSide> sides) {
          if (settings.copies <= 1) return sides;
          final out = <BookletSide>[];
          for (final s in sides) {
            for (var i = 0; i < settings.copies; i++) {
              out.add(s);
            }
          }
          return out;
        }

        final outerC = expand(outer);
        final innerC = expand(inner);
        return Ok(
          PrintPlan(
            pass1Pages: const [],
            pass2Pages: const [],
            pass1BookletSides: outerC,
            pass2BookletSides: innerC,
            isBooklet: true,
            totalSheets: outerC.length,
          ),
        );
    }
  }

  /// Tạo máy trạng thái 2 lượt cho kế hoạch [plan]. Hàm in của lượt
  /// [pass] (1 hoặc 2) tự tạo PDF lượt đó rồi phát lệnh qua spooler.
  DuplexController createController({
    required DocumentItem document,
    required PrintSettings settings,
    required PrintPlan plan,
  }) {
    final pdfPath = document.printablePdfPath;
    return DuplexController(
      printPass: (pass) async {
        if (pdfPath == null) {
          throw const AppError(messageKey: 'error_file_not_found');
        }
        final bytes = await _buildPassPdf(
          pdfPath: pdfPath,
          settings: settings,
          plan: plan,
          pass: pass,
        );
        final sent = await _dispatcher.printPass(
          printerName: settings.printerName,
          pdfBytes: bytes,
          format: settings.paperSize.format,
        );
        if (sent is Err<void>) throw sent.error;
      },
    );
  }

  /// In thử 2 trang đầu (không qua máy trạng thái 2 lượt).
  Future<Result<void>> printTest({
    required DocumentItem document,
    required PrintSettings settings,
  }) async {
    final pdfPath = document.printablePdfPath;
    if (pdfPath == null) {
      return Err(
        const AppError(messageKey: 'error_file_not_found'),
      );
    }
    final total = document.pageCount ?? 0;
    final pages = total >= 2 ? [1, 2] : [1];
    final built = await _pdfBuilder.build(
      sourcePdfPath: pdfPath,
      pages: pages,
      pageFormat: settings.paperSize.format,
    );
    if (built is Err<Uint8List>) return Err(built.error);
    return _dispatcher.printPass(
      printerName: settings.printerName,
      pdfBytes: (built as Ok<Uint8List>).value,
      format: settings.paperSize.format,
    );
  }

  Future<Uint8List> _buildPassPdf({
    required String pdfPath,
    required PrintSettings settings,
    required PrintPlan plan,
    required int pass,
  }) async {
    if (plan.isBooklet) {
      final sides = pass == 1 ? plan.pass1BookletSides : plan.pass2BookletSides;
      final built = await _pdfBuilder.buildBookletPassPdf(
        sourcePdfPath: pdfPath,
        sides: sides,
        pageFormat: settings.paperSize.format,
      );
      if (built is Err<Uint8List>) throw built.error;
      return (built as Ok<Uint8List>).value;
    }
    final pages = pass == 1 ? plan.pass1Pages : (plan.pass2Pages ?? const []);
    final built = await _pdfBuilder.build(
      sourcePdfPath: pdfPath,
      pages: pages,
      pageFormat: settings.paperSize.format,
    );
    if (built is Err<Uint8List>) throw built.error;
    return (built as Ok<Uint8List>).value;
  }
}
