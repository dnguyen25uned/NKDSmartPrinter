import 'dart:typed_data';

import 'package:pdf/pdf.dart' as pdfdoc;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart';

import '../../../core/app_error.dart';
import '../../../core/result.dart';
import 'booklet_imposition.dart';

/// Tạo file PDF cho MỘT lượt in từ danh sách trang của tài liệu gốc.
///
/// Cách làm: render từng trang gốc thành ảnh (Pdfium, 300 DPI) rồi ghép
/// lại thành PDF mới bằng package `pdf`. In ấn ra giấy là đầu ra raster
/// nên cách này giữ đúng nội dung, màu sắc, bố cục của trang gốc.
/// Xem trước trong app vẫn dùng render vector gốc của Pdfium (không qua
/// bước này), nên không ảnh hưởng độ trung thực của xem trước.
///
/// [sourcePdfPath] là PDF gốc (hoặc PDF đã chuyển đổi từ DOCX).
/// [pages] là số trang 1-based theo thứ tự cần in.
class PassPdfBuilder {
  PassPdfBuilder({this.renderDpi = 300});

  /// Độ phân giải render (DPI). 300 DPI là chuẩn in thông thường.
  final double renderDpi;

  /// Render một trang PDF thành ảnh PNG.
  Future<Result<Uint8List>> renderPageImage({
    required PdfDocument doc,
    required int pageNum,
  }) async {
    try {
      final page = await doc.getPage(pageNum);
      try {
        final img = await page.render(
          width: page.width * renderDpi / 72,
          height: page.height * renderDpi / 72,
          format: PdfPageImageFormat.png,
        );
        if (img == null) {
          return Err(
            const AppError(
              messageKey: 'error_render_page_failed',
              technicalDetail: 'pdfx render returned null',
            ),
          );
        }
        return Ok(img.bytes);
      } finally {
        await page.close();
      }
    } catch (e) {
      return Err(wrapSystemError('error_render_page_failed', e));
    }
  }

  Future<Result<Uint8List>> build({
    required String sourcePdfPath,
    required List<int?> pages,
    pdfdoc.PdfPageFormat? pageFormat,
  }) async {
    try {
      final doc = await PdfDocument.openFile(sourcePdfPath);
      try {
        final pdf = pw.Document();
        for (final pageNum in pages) {
          if (pageNum == null) {
            // Trang trắng tường minh (mặt sau của tờ cuối khi tổng
            // số trang in lẻ + bật "chêm trang trắng").
            pdf.addPage(
              pw.Page(
                pageFormat: pageFormat ?? pdfdoc.PdfPageFormat.a4,
                build: (context) => pw.Container(),
              ),
            );
            continue;
          }
          final rendered = await renderPageImage(doc: doc, pageNum: pageNum);
          if (rendered is Err<Uint8List>) {
            return Err(rendered.error);
          }
          final bytes = (rendered as Ok<Uint8List>).value;
          if (pageFormat != null) {
            // Khổ giấy đã chọn: trang in mang đúng khổ đó, ảnh trang
            // gốc vừa khít vào trong (contain, căn giữa) — không méo.
            pdf.addPage(
              pw.Page(
                pageFormat: pageFormat,
                build: (context) => pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(bytes),
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),
            );
            continue;
          }
          // Không chỉ định khổ giấy: giữ đúng khổ trang của tài liệu
          // gốc (hành vi cũ).
          final page = await doc.getPage(pageNum);
          final w = page.width;
          final h = page.height;
          await page.close();
          pdf.addPage(
            pw.Page(
              pageFormat: pdfdoc.PdfPageFormat(w, h),
              build: (context) => pw.Image(pw.MemoryImage(bytes)),
            ),
          );
        }
        return Ok(await pdf.save());
      } finally {
        await doc.close();
      }
    } catch (e) {
      return Err(wrapSystemError('error_build_pass_pdf_failed', e));
    }
  }

  /// Tạo PDF cho MỘT lượt in đóng sách: mỗi mặt trong [sides] thành
  /// 1 trang nằm ngang theo khổ giấy đã chọn. Dùng cho cả lượt 1
  /// (mặt ngoài) và lượt 2 (mặt trong, thứ tự tờ ngược — xem
  /// BookletImposition).
  ///
  /// [pageFormat] là khổ giấy DỌC (vd A4 đứng); builder tự xoay ngang.
  /// Không truyền => A4 ngang (hành vi cũ).
  Future<Result<Uint8List>> buildBookletPassPdf({
    required String sourcePdfPath,
    required List<BookletSide> sides,
    pdfdoc.PdfPageFormat? pageFormat,
  }) async {
    try {
      final doc = await PdfDocument.openFile(sourcePdfPath);
      try {
        final pdf = pw.Document();
        final format = (pageFormat ?? pdfdoc.PdfPageFormat.a4).landscape;
        final halfWidth = format.width / 2;
        for (final side in sides) {
          Uint8List? leftBytes;
          Uint8List? rightBytes;
          if (side.left != null) {
            final r = await renderPageImage(doc: doc, pageNum: side.left!);
            if (r is Err<Uint8List>) return Err(r.error);
            leftBytes = (r as Ok<Uint8List>).value;
          }
          if (side.right != null) {
            final r = await renderPageImage(doc: doc, pageNum: side.right!);
            if (r is Err<Uint8List>) return Err(r.error);
            rightBytes = (r as Ok<Uint8List>).value;
          }
          pdf.addPage(
            pw.Page(
              pageFormat: format,
              build: (context) {
                return pw.Stack(
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: halfWidth,
                          height: format.height,
                          child: leftBytes == null
                              ? pw.Container()
                              : pw.Image(
                                  pw.MemoryImage(leftBytes),
                                  fit: pw.BoxFit.contain,
                                ),
                        ),
                        pw.Container(
                          width: halfWidth,
                          height: format.height,
                          child: rightBytes == null
                              ? pw.Container()
                              : pw.Image(
                                  pw.MemoryImage(rightBytes),
                                  fit: pw.BoxFit.contain,
                                ),
                        ),
                      ],
                    ),
                    pw.Positioned(
                      left: halfWidth,
                      top: 0,
                      child: pw.CustomPaint(
                        size: pdfdoc.PdfPoint(1, format.height),
                        painter: (canvas, size) {
                          canvas
                            ..setStrokeColor(
                              const pdfdoc.PdfColor(0.5, 0.5, 0.5),
                            )
                            ..setLineWidth(0.5);
                          var y = 0.0;
                          while (y < size.y) {
                            final y2 = (y + 6).clamp(0.0, size.y);
                            canvas.drawLine(0, y, 0, y2);
                            y += 10;
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }
        return Ok(await pdf.save());
      } finally {
        await doc.close();
      }
    } catch (e) {
      return Err(wrapSystemError('error_build_pass_pdf_failed', e));
    }
  }
}
