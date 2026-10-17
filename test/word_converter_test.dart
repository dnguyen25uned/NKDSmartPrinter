import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nkd_smart_printer/core/result.dart';
import 'package:nkd_smart_printer/features/documents/services/word_converter.dart';

/// Kiểm thử WordConverter. Trên máy không phải Windows, Word không
/// thể có nên các test assert thẳng false / lỗi rõ ràng. Trên Windows,
/// chỉ kiểm tra hàm chạy không ném exception (Word có hay không tùy
/// máy chạy test).
void main() {
  test('isAvailable không ném exception và trả bool', () async {
    final converter = WordConverter();
    final available = await converter.isAvailable;
    expect(available, isA<bool>());
    if (!Platform.isWindows) {
      expect(available, isFalse);
    }
  });

  test('convertToPdf trên máy không-Windows báo Word không có', () async {
    if (Platform.isWindows) {
      markTestSkipped('Chỉ chạy trên máy không-Windows.');
    }
    final tmp = await Directory.systemTemp.createTemp('ssp-word-test-');
    try {
      final converter = WordConverter();
      final result = await converter.convertToPdf(
        docxPath: File('test/fixtures/sample.docx').absolute.path,
        outputDir: tmp,
      );
      expect(result, isA<Err<String>>());
      expect(
        (result as Err<String>).error.messageKey,
        'error_word_unavailable',
      );
    } finally {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    }
  });
}
