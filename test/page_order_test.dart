import 'package:flutter_test/flutter_test.dart';
import 'package:nkd_smart_printer/features/printing/services/page_order.dart';

void main() {
  group('PageOrder.oddPages / evenPages', () {
    test('tách lẻ/chẵn giữ nguyên thứ tự', () {
      expect(PageOrder.oddPages([1, 2, 3, 4, 5]), [1, 3, 5]);
      expect(PageOrder.evenPages([1, 2, 3, 4, 5]), [2, 4]);
    });
  });

  group('PageOrder.duplexPassPages', () {
    const pages = [1, 2, 3, 4, 5, 6, 7, 8];

    test('lẻ trước: lượt 1 = lẻ, lượt 2 = chẵn', () {
      expect(
        PageOrder.duplexPassPages(
          pages: pages,
          firstSide: FirstSide.oddFirst,
          firstPass: true,
        ),
        [1, 3, 5, 7],
      );
      expect(
        PageOrder.duplexPassPages(
          pages: pages,
          firstSide: FirstSide.oddFirst,
          firstPass: false,
        ),
        [2, 4, 6, 8],
      );
    });

    test('chẵn trước: lượt 1 = chẵn, lượt 2 = lẻ', () {
      expect(
        PageOrder.duplexPassPages(
          pages: pages,
          firstSide: FirstSide.evenFirst,
          firstPass: true,
        ),
        [2, 4, 6, 8],
      );
      expect(
        PageOrder.duplexPassPages(
          pages: pages,
          firstSide: FirstSide.evenFirst,
          firstPass: false,
        ),
        [1, 3, 5, 7],
      );
    });

    test('lượt 2 ngược chiều khi pass2Reversed', () {
      expect(
        PageOrder.duplexPassPages(
          pages: pages,
          firstSide: FirstSide.oddFirst,
          firstPass: false,
          pass2Reversed: true,
        ),
        [8, 6, 4, 2],
      );
    });

    test('pass2Reversed không ảnh hưởng lượt 1', () {
      expect(
        PageOrder.duplexPassPages(
          pages: pages,
          firstSide: FirstSide.oddFirst,
          firstPass: true,
          pass2Reversed: true,
        ),
        [1, 3, 5, 7],
      );
    });

    test('phạm vi con: chỉ xét trang trong phạm vi', () {
      expect(
        PageOrder.duplexPassPages(
          pages: [3, 4, 5, 6],
          firstSide: FirstSide.oddFirst,
          firstPass: true,
        ),
        [3, 5],
      );
    });
  });

  group('PageOrder.applyCopies', () {
    test('copies = 1 giữ nguyên', () {
      expect(PageOrder.applyCopies([1, 3], 1), [1, 3]);
    });

    test('copies = 2 lặp từng trang liên tiếp (gom theo trang)', () {
      expect(PageOrder.applyCopies([1, 3, 5], 2), [1, 1, 3, 3, 5, 5]);
    });

    test('copies = 3', () {
      expect(PageOrder.applyCopies([2], 3), [2, 2, 2]);
    });
  });
}
