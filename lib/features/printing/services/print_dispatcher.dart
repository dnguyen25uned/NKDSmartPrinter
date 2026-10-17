import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart' as pdfdoc;
import 'package:printing/printing.dart';

import '../../../core/app_error.dart';
import '../../../core/result.dart';

/// Thông tin máy in lấy từ Windows (qua package `printing`, dùng Print
/// Spooler/driver của Windows — KHÔNG gửi lệnh trực tiếp tới máy in).
class PrinterInfo {
  const PrinterInfo({
    required this.name,
    required this.isDefault,
    this.status,
  });

  final String name;
  final bool isDefault;

  /// Trạng thái mà Windows cung cấp (nếu có). Hiển thị nguyên văn,
  /// không dịch.
  final String? status;
}

/// Phát lệnh in qua Windows Print Spooler.
///
/// - Liệt kê máy in: [listPrinters].
/// - In một lượt (PDF bytes đã chuẩn bị sẵn): [printPass] dùng
///   `Printing.directPrintPdf` — in trực tiếp tới máy in đã chọn mà
///   không hiện hộp thoại hệ thống, để app điều khiển 2 lượt in và
///   chờ xác nhận lật giấy ở giữa. Lệnh vẫn đi qua spooler/driver.
/// - Mở hàng đợi in Windows: [openPrintQueue] (người dùng hủy lệnh in
///   từ cửa sổ hàng đợi của Windows).
class PrintDispatcher {
  PrintDispatcher();

  Future<Result<List<PrinterInfo>>> listPrinters() async {
    try {
      final printers = await Printing.listPrinters();
      final out = printers
          .map(
            (p) => PrinterInfo(
              name: p.name,
              isDefault: p.isDefault,
            ),
          )
          .toList();
      return Ok(out);
    } catch (e) {
      return Err(wrapSystemError('error_list_printers_failed', e));
    }
  }

  Future<Result<void>> printPass({
    required String printerName,
    required Uint8List pdfBytes,
    pdfdoc.PdfPageFormat? format,
  }) async {
    try {
      final ok = await Printing.directPrintPdf(
        printer: Printer(url: printerName),
        onLayout: (_) async => pdfBytes,
        // Khổ giấy mà app yêu cầu driver dùng cho lệnh in này
        // (khổ giấy đã chọn trong Cài đặt in). Không truyền =>
        // `PdfPageFormat.standard` — mặc định của package `printing`.
        format: format ?? pdfdoc.PdfPageFormat.standard,
      );
      if (!ok) {
        return Err(
          const AppError(
            messageKey: 'error_print_rejected',
            technicalDetail: 'directPrintPdf returned false',
          ),
        );
      }
      return const Ok(null);
    } catch (e) {
      return Err(
        wrapSystemError(
          'error_print_pass_failed',
          e,
          technicalDetail: 'directPrintPdf threw ${e.runtimeType}',
        ),
      );
    }
  }

  /// Mở cửa sổ hàng đợi in của Windows cho máy in [printerName].
  /// Chỉ hỗ trợ trên Windows; nền tảng khác trả về lỗi rõ ràng.
  Future<Result<void>> openPrintQueue(String printerName) async {
    if (!Platform.isWindows) {
      return Err(
        const AppError(messageKey: 'error_windows_only'),
      );
    }
    try {
      final result = await Process.run(
        'rundll32.exe',
        <String>[
          'printui.dll,PrintUIEntry',
          '/o',
          '/n',
          printerName,
        ],
      );
      if (result.exitCode != 0) {
        return Err(
          AppError(
            messageKey: 'error_open_queue_failed',
            technicalDetail: 'rundll32 exitCode=${result.exitCode}',
            rawSystemMessage: result.stderr.toString().trim().isEmpty
                ? null
                : result.stderr.toString().trim(),
          ),
        );
      }
      return const Ok(null);
    } catch (e) {
      return Err(wrapSystemError('error_open_queue_failed', e));
    }
  }
}
