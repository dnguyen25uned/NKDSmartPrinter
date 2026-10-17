import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nkd_smart_printer/core/app_error.dart';
import 'package:nkd_smart_printer/core/result.dart';
import 'package:nkd_smart_printer/features/documents/services/docx_converter.dart';
import 'package:nkd_smart_printer/features/documents/services/word_converter.dart';

/// Word giả luôn báo có nhưng chuyển lỗi — để kiểm thử fallback.
class _FailingWordConverter extends WordConverter {
  @override
  Future<bool> get isAvailable async => true;

  @override
  Future<Result<String>> convertToPdf({
    required String docxPath,
    required Directory outputDir,
  }) async =>
      const Err(
        AppError(messageKey: 'error_docx_convert_failed'),
      );
}

/// Word giả luôn chuyển thành công (trả đường dẫn giả).
class _OkWordConverter extends WordConverter {
  @override
  Future<bool> get isAvailable async => true;

  @override
  Future<Result<String>> convertToPdf({
    required String docxPath,
    required Directory outputDir,
  }) async =>
      const Ok('/tmp/fake-word.pdf');
}

/// Kiểm thử đường chuyển đổi DOCX -> PDF: Word trước, LibreOffice
/// dự phòng. Test chuyển thật bỏ qua (skip) trên máy chưa có engine —
/// không fail oan.
void main() {
  test('Tìm thấy bản portable trong thư mục libreoffice/ cạnh app', () async {
    final tmp = await Directory.systemTemp.createTemp('ssp-lo-test-');
    try {
      // Giả lập bản portable: libreoffice/program/soffice(.exe).
      final sofficeName = Platform.isWindows ? 'soffice.exe' : 'soffice';
      final portable = File(
        '${tmp.path}/libreoffice/program/$sofficeName',
      );
      await portable.create(recursive: true);
      final converter = DocxConverter(
        appDirectory: tmp.path,
        includeSystemSearch: false,
      );
      final status = await converter.locate();
      expect(status.found, isTrue);
      expect(status.source, 'portable');
      expect(status.path, portable.path);
      expect(await converter.isAvailable, isTrue);
    } finally {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    }
  });

  test('Không tìm thấy khi không có bản portable và bỏ qua tìm kiếm hệ thống',
      () async {
    final tmp = await Directory.systemTemp.createTemp('ssp-lo-test-');
    try {
      final converter = DocxConverter(
        appDirectory: tmp.path,
        includeSystemSearch: false,
      );
      final status = await converter.locate();
      expect(status.found, isFalse);
      expect(status.source, 'none');
      expect(await converter.isAvailable, isFalse);
    } finally {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    }
  });

  test('Chuyển đổi báo lỗi rõ ràng khi không có engine nào', () async {
    final tmp = await Directory.systemTemp.createTemp('ssp-lo-test-');
    try {
      final converter = DocxConverter(
        appDirectory: tmp.path,
        includeSystemSearch: false,
      );
      final result = await converter.convertToPdf(
        docxPath: File('test/fixtures/sample.docx').absolute.path,
        outputDir: tmp,
      );
      expect(result, isA<Err<String>>());
      expect(
        (result as Err<String>).error.messageKey,
        'error_docx_needs_converter',
      );
    } finally {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    }
  });

  test('Word chuyển lỗi thì fallback LibreOffice, hết engine thì báo lỗi',
      () async {
    final tmp = await Directory.systemTemp.createTemp('ssp-lo-test-');
    try {
      final converter = DocxConverter(
        appDirectory: tmp.path,
        includeSystemSearch: false,
        wordConverter: _FailingWordConverter(),
      );
      expect(await converter.availableEngine(), DocxEngine.word);
      final result = await converter.convertToPdf(
        docxPath: File('test/fixtures/sample.docx').absolute.path,
        outputDir: tmp,
      );
      expect(result, isA<Err<String>>());
      expect(
        (result as Err<String>).error.messageKey,
        'error_docx_needs_converter',
      );
    } finally {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    }
  });

  test('Word chuyển thành công thì dùng kết quả Word, không gọi LibreOffice',
      () async {
    final tmp = await Directory.systemTemp.createTemp('ssp-lo-test-');
    try {
      final converter = DocxConverter(
        appDirectory: tmp.path,
        includeSystemSearch: false,
        wordConverter: _OkWordConverter(),
      );
      expect(await converter.availableEngine(), DocxEngine.word);
      final result = await converter.convertToPdf(
        docxPath: File('test/fixtures/sample.docx').absolute.path,
        outputDir: tmp,
      );
      expect(result, isA<Ok<String>>());
      expect((result as Ok<String>).value, '/tmp/fake-word.pdf');
    } finally {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    }
  });

  test('DOCX mẫu chuyển đổi thành PDF thật qua engine có sẵn', () async {
    final converter = DocxConverter();
    if (!await converter.isAvailable) {
      markTestSkipped('Không có engine chuyển đổi (Word/LibreOffice).');
    }

    final tmp = await Directory.systemTemp.createTemp('ssp-docx-test-');
    try {
      final docx = File('test/fixtures/sample.docx');
      expect(await docx.exists(), isTrue);

      final result = await converter.convertToPdf(
        docxPath: docx.absolute.path,
        outputDir: tmp,
      );
      expect(result, isA<Ok<String>>());
      final pdfPath = (result as Ok<String>).value;
      final pdf = File(pdfPath);
      expect(await pdf.exists(), isTrue);
      final bytes = await pdf.readAsBytes();
      // PDF thật phải bắt đầu bằng magic bytes %PDF và không rỗng.
      expect(bytes.length, greaterThan(1000));
      expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
    } finally {
      if (await tmp.exists()) await tmp.delete(recursive: true);
    }
  });
}
