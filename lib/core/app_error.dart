/// Lỗi của ứng dụng.
///
/// [messageKey] là key bản địa hóa cho thông báo hiển thị cho người dùng.
/// [technicalDetail] CHỈ chứa thông tin kỹ thuật (mã lỗi, tên thao tác),
/// không bao giờ chứa nội dung tài liệu hay dữ liệu cá nhân.
/// [rawSystemMessage] là thông báo gốc từ Windows/driver (nếu có) — hiển
/// thị nguyên văn, không dịch, để người dùng đối chiếu với tài liệu hãng.
class AppError implements Exception {
  const AppError({
    required this.messageKey,
    this.technicalDetail,
    this.rawSystemMessage,
  });

  final String messageKey;
  final String? technicalDetail;
  final String? rawSystemMessage;

  @override
  String toString() => 'AppError($messageKey, technical=$technicalDetail)';
}

/// Tiện ích: gói một lỗi hệ thống thành [AppError] mà không rò rỉ dữ liệu.
AppError wrapSystemError(
  String messageKey,
  Object error, {
  String? technicalDetail,
}) {
  return AppError(
    messageKey: messageKey,
    technicalDetail: technicalDetail ?? error.runtimeType.toString(),
    rawSystemMessage: error.toString(),
  );
}
