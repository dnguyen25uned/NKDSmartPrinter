import '../../../core/app_error.dart';
import '../../../core/result.dart';

/// Phân tích phạm vi trang do người dùng nhập, ví dụ: "1-3,5,8-10".
///
/// Trả về danh sách số trang (1-based) đã sắp xếp, không trùng.
/// Trang ngoài [1, totalPages] hoặc cú pháp sai -> [Err].
class PageRange {
  const PageRange._();

  static Result<List<int>> parse(String input, int totalPages) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return Err(
        const AppError(messageKey: 'error_page_range_empty'),
      );
    }
    if (totalPages < 1) {
      return Err(
        const AppError(messageKey: 'error_document_no_pages'),
      );
    }
    final pages = <int>{};
    for (final part in trimmed.split(',')) {
      final p = part.trim();
      if (p.isEmpty) {
        return Err(
          const AppError(messageKey: 'error_page_range_syntax'),
        );
      }
      if (p.contains('-')) {
        final bounds = p.split('-');
        if (bounds.length != 2) {
          return Err(
            const AppError(messageKey: 'error_page_range_syntax'),
          );
        }
        final start = int.tryParse(bounds[0].trim());
        final end = int.tryParse(bounds[1].trim());
        if (start == null || end == null || start < 1 || end < start) {
          return Err(
            const AppError(messageKey: 'error_page_range_syntax'),
          );
        }
        if (end > totalPages) {
          return Err(
            const AppError(
              messageKey: 'error_page_range_out_of_bounds',
            ),
          );
        }
        for (var i = start; i <= end; i++) {
          pages.add(i);
        }
      } else {
        final n = int.tryParse(p);
        if (n == null || n < 1 || n > totalPages) {
          return Err(
            const AppError(
              messageKey: 'error_page_range_out_of_bounds',
            ),
          );
        }
        pages.add(n);
      }
    }
    final sorted = pages.toList()..sort();
    return Ok(sorted);
  }

  /// Phạm vi "tất cả các trang".
  static List<int> all(int totalPages) =>
      List<int>.generate(totalPages, (i) => i + 1);
}
