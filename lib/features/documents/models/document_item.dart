/// Định dạng tài liệu.
enum DocumentFormat { pdf, docx, unsupported }

/// Trạng thái xử lý của một tài liệu.
enum DocumentStatus {
  /// Sẵn sàng xem trước/in (PDF gốc hoặc DOCX đã chuyển đổi).
  ready,

  /// DOCX chưa chuyển đổi — cần LibreOffice để xem trước/in.
  needsConversion,

  /// Đang chuyển đổi DOCX sang PDF.
  converting,

  /// Lỗi (không đọc được, không chuyển đổi được...).
  error,
}

/// Một tài liệu trong danh sách làm việc.
class DocumentItem {
  DocumentItem({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.format,
    required this.status,
    this.pageCount,
    this.fileSizeBytes,
    this.errorMessageKey,
    this.convertedPdfPath,
  });

  final String id;
  final String filePath;
  final String fileName;
  final DocumentFormat format;
  DocumentStatus status;
  int? pageCount;

  /// Kích thước file gốc (byte) — hiển thị trong thẻ tài liệu.
  int? fileSizeBytes;

  /// Key bản địa hóa của lỗi (nếu status == error).
  String? errorMessageKey;

  /// Đường dẫn PDF đã chuyển đổi (chỉ dùng cho DOCX).
  String? convertedPdfPath;

  /// Đường dẫn file dùng để xem trước/in: PDF gốc hoặc PDF đã chuyển đổi.
  String? get printablePdfPath =>
      format == DocumentFormat.docx ? convertedPdfPath : filePath;

  DocumentItem copyWith({
    DocumentStatus? status,
    int? pageCount,
    int? fileSizeBytes,
    String? errorMessageKey,
    String? convertedPdfPath,
  }) {
    return DocumentItem(
      id: id,
      filePath: filePath,
      fileName: fileName,
      format: format,
      status: status ?? this.status,
      pageCount: pageCount ?? this.pageCount,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      errorMessageKey: errorMessageKey ?? this.errorMessageKey,
      convertedPdfPath: convertedPdfPath ?? this.convertedPdfPath,
    );
  }
}
