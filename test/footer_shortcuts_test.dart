import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nkd_smart_printer/features/documents/services/document_service.dart';
import 'package:nkd_smart_printer/features/documents/services/docx_converter.dart';
import 'package:nkd_smart_printer/features/home/home_screen.dart';
import 'package:nkd_smart_printer/features/home/print_flow.dart';
import 'package:nkd_smart_printer/features/printing/services/pass_pdf_builder.dart';
import 'package:nkd_smart_printer/features/printing/services/print_dispatcher.dart';
import 'package:nkd_smart_printer/features/settings/settings_controller.dart';
import 'package:nkd_smart_printer/localization/strings.dart';
import 'package:nkd_smart_printer/theme/app_theme.dart';
import 'package:nkd_smart_printer/theme/app_widgets.dart';

/// Footer mới (thông tin + pill tác giả/SĐT) và phím tắt Ctrl+P / Esc.
///
/// Lưu ý: thư mục tạm tạo trong setUpAll (ngoài vùng fake-async của
/// testWidgets) — tạo thư mục bằng I/O thật trong thân test sẽ treo vì
/// binding chỉ xử lý event loop thật khi pump.
void main() {
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('footer_test_');
  });

  tearDownAll(() async {
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  const authorText = 'Tác giả: Thiếu tá QNCN Nguyễn Kim Đạt';
  const phoneText = 'SĐT hỗ trợ: 035 929 6446';

  Future<void> pumpFooter(
    WidgetTester tester, {
    required Locale locale,
    required double width,
  }) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = Size(width, 600);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: AppFooter(infoText: S(locale).footerInfo),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('AppFooter', () {
    testWidgets('hiện đủ phần trái + pill tác giả/SĐT (VI)', (tester) async {
      await pumpFooter(tester, locale: const Locale('vi'), width: 1440);
      expect(find.text(S(const Locale('vi')).footerInfo), findsOneWidget);
      expect(find.text(authorText), findsOneWidget);
      expect(find.text(phoneText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hiện đủ phần trái + pill tác giả/SĐT (EN)', (tester) async {
      await pumpFooter(tester, locale: const Locale('en'), width: 1440);
      expect(find.text(S(const Locale('en')).footerInfo), findsOneWidget);
      // Pill tác giả/SĐT giống nhau ở cả 2 ngôn ngữ.
      expect(find.text(authorText), findsOneWidget);
      expect(find.text(phoneText), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('không tràn ở chiều rộng hẹp (320px, VI + EN)', (tester) async {
      for (final locale in [const Locale('vi'), const Locale('en')]) {
        await pumpFooter(tester, locale: locale, width: 320);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Phím tắt', () {
    testWidgets('Esc đóng dialog đang mở', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const AlertDialog(
                    content: Text('DIALOG'),
                  ),
                ),
                child: const Text('OPEN'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();
      expect(find.text('DIALOG'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('DIALOG'), findsNothing);
    });

    testWidgets('Ctrl+P không làm gì khi chưa có tài liệu in được',
        (tester) async {
      final documents = DocumentService(
        converter: DocxConverter(includeSystemSearch: false),
        tempDir: tempDir,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: HomeScreen(
            strings: S(const Locale('vi')),
            settings: SettingsController(),
            documents: documents,
            dispatcher: PrintDispatcher(),
            flow: PrintFlow(
              dispatcher: PrintDispatcher(),
              pdfBuilder: PassPdfBuilder(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      // Xả exception thoáng qua của frame đầu (như file overflow test),
      // rồi mới đo: sau phím tắt không được có exception mới.
      while (tester.takeException() != null) {}
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      // Không dùng pumpAndSettle ở đây: màn hình chính có chấm nhấp nháy
      // (animation lặp vô hạn) nên pumpAndSettle sẽ treo tới timeout.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      // Không có tài liệu in được: không mở dialog xác nhận in, không lỗi.
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
