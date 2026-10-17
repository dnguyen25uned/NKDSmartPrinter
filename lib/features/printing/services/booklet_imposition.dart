// Sắp xếp trang cho chế độ "In đóng sách" (Saddle-Stitch Imposition).
//
// Mỗi tờ giấy A4 nằm ngang chứa 2 trang trên 1 mặt. Gập đôi tờ giấy ở
// vạch giữa sẽ thành cuốn sách A5.
//
// Quy ước (gáy trái — chuẩn tiếng Việt/tiếng Anh), cuốn 8 trang:
// - Lượt 1 (mặt ngoài): Tờ 1 in [8 | 1], Tờ 2 in [6 | 3].
// - Lượt 2 (mặt trong): Tờ 2 in [4 | 5], Tờ 1 in [2 | 7].
//
// Lượt 2 in theo thứ tự tờ NGƯỢC với lượt 1, vì sau lượt 1 người dùng
// nạp lại cả xấp giấy mà không đảo thứ tự — tờ in sau cùng nằm trên
// cùng và được nạp vào máy trước. Gáy phải (Manga) là hình ảnh gương
// của gáy trái.

/// Gáy sách: trái (chuẩn VN/EN) hoặc phải (Manga).
enum BookletSpine { left, right }

/// Một mặt in của một tờ giấy: 2 vị trí trái/phải.
/// [left]/[right] là số trang, hoặc null nếu là trang trắng chèn thêm.
class BookletSide {
  const BookletSide({required this.left, required this.right});

  final int? left;
  final int? right;
}

class BookletImposition {
  const BookletImposition._();

  /// Tổng số trang sau khi làm tròn lên bội số của 4 (chèn trang trắng).
  static int paddedTotal(int totalPages) {
    if (totalPages < 1) return 0;
    return ((totalPages + 3) ~/ 4) * 4;
  }

  /// Số tờ giấy cần dùng.
  static int sheetCount(int totalPages) => paddedTotal(totalPages) ~/ 4;

  /// Một trang trong khoảng đã làm tròn có phải trang trắng chèn thêm?
  static bool isBlank(int page, int totalPages) => page > totalPages;

  /// Mặt ngoài của tờ [sheetIndex] (0-based).
  static BookletSide outerSide({
    required int sheetIndex,
    required int paddedTotal,
    required BookletSpine spine,
  }) {
    final left = spine == BookletSpine.left
        ? paddedTotal - 2 * sheetIndex
        : 2 * sheetIndex + 1;
    final right = spine == BookletSpine.left
        ? 2 * sheetIndex + 1
        : paddedTotal - 2 * sheetIndex;
    return BookletSide(left: left, right: right);
  }

  /// Mặt trong của tờ [sheetIndex] (0-based).
  static BookletSide innerSide({
    required int sheetIndex,
    required int paddedTotal,
    required BookletSpine spine,
  }) {
    final left = spine == BookletSpine.left
        ? 2 * sheetIndex + 2
        : paddedTotal - 2 * sheetIndex - 1;
    final right = spine == BookletSpine.left
        ? paddedTotal - 2 * sheetIndex - 1
        : 2 * sheetIndex + 2;
    return BookletSide(left: left, right: right);
  }

  /// Danh sách mặt ngoài cho lượt 1, theo thứ tự tờ 1..N.
  static List<BookletSide> outerPass({
    required int totalPages,
    required BookletSpine spine,
  }) {
    final padded = paddedTotal(totalPages);
    return List<BookletSide>.generate(
      sheetCount(totalPages),
      (i) => outerSide(sheetIndex: i, paddedTotal: padded, spine: spine),
    );
  }

  /// Danh sách mặt trong cho lượt 2, theo thứ tự tờ NGƯỢC (N..1) như
  /// giải thích ở đầu file — khớp với cách nạp lại cả xấp giấy.
  static List<BookletSide> innerPass({
    required int totalPages,
    required BookletSpine spine,
  }) {
    final padded = paddedTotal(totalPages);
    final sides = List<BookletSide>.generate(
      sheetCount(totalPages),
      (i) => innerSide(sheetIndex: i, paddedTotal: padded, spine: spine),
    );
    return sides.reversed.toList();
  }
}
