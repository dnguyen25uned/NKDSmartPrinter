import 'package:flutter_test/flutter_test.dart';
import 'package:nkd_smart_printer/core/result.dart';
import 'package:nkd_smart_printer/features/printing/services/page_range.dart';

void main() {
  group('PageRange.parse', () {
    test('tất cả các trang', () {
      expect(PageRange.all(5), [1, 2, 3, 4, 5]);
    });

    test('khoảng đơn + rời rạc, sắp xếp và khử trùng', () {
      final r = PageRange.parse('3,1-3,5', 10);
      expect(r, isA<Ok<List<int>>>());
      expect((r as Ok<List<int>>).value, [1, 2, 3, 5]);
    });

    test('khoảng đầy đủ', () {
      final r = PageRange.parse('1-3,5,8-10', 10);
      expect((r as Ok<List<int>>).value, [1, 2, 3, 5, 8, 9, 10]);
    });

    test('rỗng -> lỗi', () {
      expect(PageRange.parse('   ', 10), isA<Err<List<int>>>());
    });

    test('sai cú pháp -> lỗi', () {
      expect(PageRange.parse('1--3', 10), isA<Err<List<int>>>());
      expect(PageRange.parse('a-b', 10), isA<Err<List<int>>>());
      expect(PageRange.parse('3-1', 10), isA<Err<List<int>>>());
      expect(PageRange.parse('1-', 10), isA<Err<List<int>>>());
    });

    test('vượt giới hạn -> lỗi', () {
      expect(PageRange.parse('11', 10), isA<Err<List<int>>>());
      expect(PageRange.parse('1-11', 10), isA<Err<List<int>>>());
      expect(PageRange.parse('0', 10), isA<Err<List<int>>>());
    });

    test('tài liệu 0 trang -> lỗi', () {
      expect(PageRange.parse('1', 0), isA<Err<List<int>>>());
    });
  });
}
