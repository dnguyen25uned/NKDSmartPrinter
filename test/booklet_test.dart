import 'package:flutter_test/flutter_test.dart';
import 'package:nkd_smart_printer/features/printing/services/booklet_imposition.dart';

void main() {
  group('BookletImposition.paddedTotal / sheetCount', () {
    test('làm tròn lên bội số của 4', () {
      expect(BookletImposition.paddedTotal(1), 4);
      expect(BookletImposition.paddedTotal(4), 4);
      expect(BookletImposition.paddedTotal(5), 8);
      expect(BookletImposition.paddedTotal(8), 8);
      expect(BookletImposition.paddedTotal(9), 12);
    });

    test('số tờ = tổng đã làm tròn / 4', () {
      expect(BookletImposition.sheetCount(8), 2);
      expect(BookletImposition.sheetCount(5), 2);
      expect(BookletImposition.sheetCount(12), 3);
    });

    test('trang trắng = trang vượt quá tổng thật', () {
      expect(BookletImposition.isBlank(6, 5), isTrue);
      expect(BookletImposition.isBlank(5, 5), isFalse);
    });
  });

  group('BookletImposition — ví dụ mẫu trong spec, cuốn 8 trang, gáy trái', () {
    test('lượt 1 (mặt ngoài): Tờ 1 [8|1], Tờ 2 [6|3]', () {
      final outer = BookletImposition.outerPass(
        totalPages: 8,
        spine: BookletSpine.left,
      );
      expect(outer.length, 2);
      expect(outer[0].left, 8);
      expect(outer[0].right, 1);
      expect(outer[1].left, 6);
      expect(outer[1].right, 3);
    });

    test('lượt 2 (mặt trong, thứ tự tờ ngược): Tờ 2 [4|5], Tờ 1 [2|7]', () {
      final inner = BookletImposition.innerPass(
        totalPages: 8,
        spine: BookletSpine.left,
      );
      expect(inner.length, 2);
      expect(inner[0].left, 4);
      expect(inner[0].right, 5);
      expect(inner[1].left, 2);
      expect(inner[1].right, 7);
    });

    test('mọi trang thật xuất hiện đúng 1 lần trong cả 2 lượt', () {
      final outer = BookletImposition.outerPass(
        totalPages: 8,
        spine: BookletSpine.left,
      );
      final inner = BookletImposition.innerPass(
        totalPages: 8,
        spine: BookletSpine.left,
      );
      final all = <int>[];
      for (final s in [...outer, ...inner]) {
        all.addAll([s.left!, s.right!]);
      }
      all.sort();
      expect(all, [1, 2, 3, 4, 5, 6, 7, 8]);
    });
  });

  group('BookletImposition — gáy phải (Manga) là hình gương của gáy trái', () {
    test('cuốn 8 trang, gáy phải: lượt 1 Tờ 1 [1|8], Tờ 2 [3|6]', () {
      final outer = BookletImposition.outerPass(
        totalPages: 8,
        spine: BookletSpine.right,
      );
      expect(outer[0].left, 1);
      expect(outer[0].right, 8);
      expect(outer[1].left, 3);
      expect(outer[1].right, 6);
    });

    test('cuốn 8 trang, gáy phải: lượt 2 Tờ 2 [5|4], Tờ 1 [7|2]', () {
      final inner = BookletImposition.innerPass(
        totalPages: 8,
        spine: BookletSpine.right,
      );
      expect(inner[0].left, 5);
      expect(inner[0].right, 4);
      expect(inner[1].left, 7);
      expect(inner[1].right, 2);
    });
  });

  group('BookletImposition — trang trắng chèn thêm', () {
    test('cuốn 5 trang -> làm tròn 8, các vị trí >5 là trang trắng', () {
      final outer = BookletImposition.outerPass(
        totalPages: 5,
        spine: BookletSpine.left,
      );
      final inner = BookletImposition.innerPass(
        totalPages: 5,
        spine: BookletSpine.left,
      );
      final all = <int>[];
      for (final s in [...outer, ...inner]) {
        all.addAll([s.left!, s.right!]);
      }
      // Các vị trí 6,7,8 là trang trắng chèn thêm.
      expect(all.where((p) => p > 5).length, 3);
      // Trang thật 1..5 mỗi trang đúng 1 lần.
      final real = all.where((p) => p <= 5).toList()..sort();
      expect(real, [1, 2, 3, 4, 5]);
    });
  });
}
