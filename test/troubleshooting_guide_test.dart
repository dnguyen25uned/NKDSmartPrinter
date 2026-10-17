import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nkd_smart_printer/features/guides/widgets/troubleshooting_guide_dialog.dart';
import 'package:nkd_smart_printer/localization/strings.dart';

void main() {
  test('Lệnh hàng đợi in và chuỗi khởi động lại Spooler đúng', () {
    expect(kOpenQueueCommand, 'control printers');
    expect(
      kSpoolerRestartCommands,
      'net stop spooler\n'
      'del %systemroot%\\System32\\spool\\PRINTERS\\* /Q\n'
      'net start spooler',
    );
    // Nút Copy chép đúng payload: lệnh mở hàng đợi + chuỗi 3 lệnh Spooler.
    expect(kSpoolerRestartCommands.split('\n'), hasLength(3));
    expect(kSpoolerRestartCommands, contains('net stop spooler'));
    expect(kSpoolerRestartCommands, contains('net start spooler'));
  });

  testWidgets('Dialog hướng dẫn có đủ 3 phần, VI + EN', (tester) async {
    for (final locale in [const Locale('vi'), const Locale('en')]) {
      final strings = S(locale);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TroubleshootingGuideDialog(strings: strings),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Tiêu đề + 3 phần.
      expect(find.text(strings.troubleshootTitle), findsOneWidget);
      expect(find.text(strings.troubleshootJamTitle), findsOneWidget);
      expect(find.text(strings.troubleshootQueueTitle), findsOneWidget);
      expect(find.text(strings.troubleshootErrorsTitle), findsOneWidget);
      // 6 ô an toàn kẹt giấy.
      for (var i = 1; i <= 6; i++) {
        expect(
          find.text(strings.troubleshootJamCellTitle(i)),
          findsOneWidget,
        );
      }
      // Lệnh hiển thị đúng.
      expect(find.text(kOpenQueueCommand), findsOneWidget);
      // 3 dòng mã lỗi.
      for (var i = 1; i <= 3; i++) {
        expect(find.text(strings.troubleshootErrorCode(i)), findsOneWidget);
      }
      // Chân dialog chỉ có 1 nút Đóng.
      expect(find.text(strings.close), findsOneWidget);
    }
  });

  testWidgets('Nút Copy đổi trạng thái đã sao chép sau khi bấm',
      (tester) async {
    // Clipboard trong test: mock kênh platform để setData không throw.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (methodCall) async {
      if (methodCall.method == 'Clipboard.setData' ||
          methodCall.method == 'Clipboard.getData') {
        return null;
      }
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    final strings = S(const Locale('vi'));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TroubleshootingGuideDialog(strings: strings),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // 2 nút Sao chép (1 cho control printers, 1 cho chuỗi Spooler).
    expect(find.text(strings.troubleshootCopy), findsNWidgets(2));
    await tester.ensureVisible(find.text(strings.troubleshootCopy).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.troubleshootCopy).first);
    await tester.pump();
    expect(find.text(strings.troubleshootCopied), findsOneWidget);
  });
}
