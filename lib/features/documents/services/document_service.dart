import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pdfx/pdfx.dart';

import '../../../core/app_error.dart';
import '../../../core/result.dart';
import '../models/document_item.dart';
import 'docx_converter.dart';

/// Quản lý danh sách tài liệu: thêm/xóa/sắp xếp, đếm trang, chuyển đổi
/// DOCX. Không tải tài liệu lên mạng. File tạm (PDF đã chuyển đổi) được
/// xóa khi xóa tài liệu hoặc khi đóng ứng dụng.
class DocumentService {
  DocumentService({
    required DocxConverter converter,
    required Directory tempDir,
  })  : _converter = converter,
        _tempDir = tempDir;

  final DocxConverter _converter;
  final Directory _tempDir;
  final List<DocumentItem> _items = [];
  int _seq = 0;

  List<DocumentItem> get items => List<DocumentItem>.unmodifiable(_items);

  static DocumentFormat formatOf(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    if (ext == '.pdf') return DocumentFormat.pdf;
    if (ext == '.docx') return DocumentFormat.docx;
    return DocumentFormat.unsupported;
  }

  /// Thêm một file. Trả về item đã tạo (kèm trạng thái/error nếu có).
  Future<DocumentItem> addFile(String filePath) async {
    final name = p.basename(filePath);
    final format = formatOf(filePath);
    final item = DocumentItem(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}_${_seq++}',
      filePath: filePath,
      fileName: name,
      format: format,
      status: DocumentStatus.error,
    );
    _items.add(item);
    if (format == DocumentFormat.unsupported) {
      item
        ..status = DocumentStatus.error
        ..errorMessageKey = 'error_format_unsupported';
      return item;
    }
    final file = File(filePath);
    if (!await file.exists()) {
      item
        ..status = DocumentStatus.error
        ..errorMessageKey = 'error_file_not_found';
      return item;
    }
    item.fileSizeBytes = await file.length();
    if (format == DocumentFormat.docx) {
      // DOCX cần chuyển đổi trước khi xem trước/in.
      item.status = DocumentStatus.needsConversion;
      return item;
    }
    final count = await _countPdfPages(filePath);
    if (count is Err<int>) {
      item
        ..status = DocumentStatus.error
        ..errorMessageKey = count.error.messageKey;
      return item;
    }
    item
      ..status = DocumentStatus.ready
      ..pageCount = (count as Ok<int>).value;
    return item;
  }

  /// Trạng thái LibreOffice trên máy (để hiển thị trước khi chuyển đổi).
  Future<LibreOfficeStatus> libreOfficeStatus() => _converter.locate();

  /// Engine chuyển DOCX → PDF dùng được (Word → LibreOffice → none).
  Future<DocxEngine> converterEngine() => _converter.availableEngine();

  /// Word có sẵn trên máy không.
  Future<bool> wordAvailable() => _converter.wordAvailable;

  /// Chuyển đổi một DOCX sang PDF (để xem trước/in). Cập nhật item.
  Future<Result<DocumentItem>> convertDocx(DocumentItem item) async {
    if (item.format != DocumentFormat.docx) {
      return Err(
        const AppError(messageKey: 'error_format_unsupported'),
      );
    }
    item.status = DocumentStatus.converting;
    final outDir = Directory(p.join(_tempDir.path, 'converted'));
    await outDir.create(recursive: true);
    final result = await _converter.convertToPdf(
      docxPath: item.filePath,
      outputDir: outDir,
    );
    if (result is Err<String>) {
      item
        ..status = DocumentStatus.error
        ..errorMessageKey = result.error.messageKey;
      return Err(result.error);
    }
    final pdfPath = (result as Ok<String>).value;
    final count = await _countPdfPages(pdfPath);
    if (count is Err<int>) {
      item
        ..status = DocumentStatus.error
        ..errorMessageKey = count.error.messageKey;
      return Err(count.error);
    }
    item
      ..status = DocumentStatus.ready
      ..convertedPdfPath = pdfPath
      ..pageCount = (count as Ok<int>).value;
    return Ok(item);
  }

  /// Xóa tài liệu khỏi danh sách và dọn file tạm của nó.
  Future<void> remove(DocumentItem item) async {
    _items.removeWhere((e) => e.id == item.id);
    final converted = item.convertedPdfPath;
    if (converted != null) {
      try {
        final f = File(converted);
        if (await f.exists()) await f.delete();
      } catch (_) {
        // Dọn file tạm thất bại: không chặn luồng chính.
      }
    }
  }

  /// Sắp xếp lại: di chuyển item từ [from] tới [to].
  void reorder(int from, int to) {
    if (from < 0 || from >= _items.length) return;
    if (to < 0 || to >= _items.length) return;
    final item = _items.removeAt(from);
    _items.insert(to, item);
  }

  /// Xóa toàn bộ file tạm đã chuyển đổi.
  Future<void> dispose() async {
    for (final item in _items) {
      final converted = item.convertedPdfPath;
      if (converted != null) {
        try {
          final f = File(converted);
          if (await f.exists()) await f.delete();
        } catch (_) {
          // Bỏ qua.
        }
      }
    }
    _items.clear();
  }

  Future<Result<int>> _countPdfPages(String pdfPath) async {
    try {
      final doc = await PdfDocument.openFile(pdfPath);
      final count = doc.pagesCount;
      await doc.close();
      return Ok(count);
    } catch (e) {
      return Err(wrapSystemError('error_pdf_unreadable', e));
    }
  }
}
