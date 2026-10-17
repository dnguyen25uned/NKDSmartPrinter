// Thứ tự trang cho in một mặt / in hai mặt thủ công.
//
// Tất cả số trang đều 1-based. Các hàm này là thuần túy (pure) để dễ
// kiểm thử và tránh nhầm lẫn — in hai lượt sai thứ tự sẽ làm hỏng
// toàn bộ xấp giấy.

/// Lượt in đầu tiên bắt đầu bằng trang lẻ hay trang chẵn.
enum FirstSide { oddFirst, evenFirst }

/// Cạnh lật giấy khi nạp lại: cạnh dài (như sách thường) hay cạnh ngắn.
enum FlipEdge { longEdge, shortEdge }

class PageOrder {
  const PageOrder._();

  /// Trang lẻ trong [pages] (giữ nguyên thứ tự).
  static List<int> oddPages(List<int> pages) =>
      pages.where((p) => p.isOdd).toList();

  /// Trang chẵn trong [pages] (giữ nguyên thứ tự).
  static List<int> evenPages(List<int> pages) =>
      pages.where((p) => p.isEven).toList();

  /// Danh sách trang của MỘT lượt in hai mặt thủ công.
  ///
  /// [firstPass] = true -> lượt đầu (trang lẻ nếu [firstSide] là oddFirst,
  /// ngược lại trang chẵn). [firstPass] = false -> lượt còn lại.
  /// [pass2Reversed] chỉ áp dụng cho lượt 2: một số máy in nạp giấy từ
  /// đỉnh xấp giấy đã in (thay vì từ đáy khay), nên lượt 2 phải in theo
  /// thứ tự ngược để các mặt khớp nhau. Người dùng xác định bằng in thử.
  static List<int> duplexPassPages({
    required List<int> pages,
    required FirstSide firstSide,
    required bool firstPass,
    bool pass2Reversed = false,
  }) {
    final wantOdd = (firstPass && firstSide == FirstSide.oddFirst) ||
        (!firstPass && firstSide == FirstSide.evenFirst);
    final selected = wantOdd ? oddPages(pages) : evenPages(pages);
    if (!firstPass && pass2Reversed) {
      return selected.reversed.toList();
    }
    return selected;
  }

  /// Mở rộng danh sách trang theo số bản in: mỗi trang lặp lại [copies]
  /// lần liên tiếp (gom theo trang), để khi lật cả xấp giấy thì các bản
  /// in vẫn khớp mặt với nhau.
  ///
  /// Generic để dùng được cho cả danh sách trang thật (`int`) và danh
  /// sách có trang trắng tường minh (`int?`, null = trang trắng) của
  /// lượt 2 khi bật "chêm trang trắng".
  static List<T> applyCopies<T>(List<T> pages, int copies) {
    if (copies <= 1) return List<T>.of(pages);
    final out = <T>[];
    for (final p in pages) {
      for (var i = 0; i < copies; i++) {
        out.add(p);
      }
    }
    return out;
  }
}
