import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart' as pdfdoc;
import 'package:nkd_smart_printer/core/result.dart';
import 'package:nkd_smart_printer/features/documents/models/document_item.dart';
import 'package:nkd_smart_printer/features/home/print_flow.dart';
import 'package:nkd_smart_printer/features/printing/models/print_settings.dart';
import 'package:nkd_smart_printer/features/printing/services/pass_pdf_builder.dart';
import 'package:nkd_smart_printer/features/printing/services/print_dispatcher.dart';
import 'package:nkd_smart_printer/localization/strings.dart';
import 'package:nkd_smart_printer/theme/app_widgets.dart';

/// Cài đặt cột 3 (Cấu hình in ấn): khổ giấy thật + checkbox chêm
/// trang trắng trong kế hoạch in hai mặt.
void main() {
  PrintFlow flow() => PrintFlow(
        dispatcher: PrintDispatcher(),
        pdfBuilder: PassPdfBuilder(),
      );

  DocumentItem doc(int pages) => DocumentItem(
        id: 't',
        filePath: '/tmp/x.pdf',
        fileName: 'x.pdf',
        format: DocumentFormat.pdf,
        status: DocumentStatus.ready,
        pageCount: pages,
      );

  PrintSettings duplex({
    PaperSize paperSize = PaperSize.a4,
    bool insertBlankPage = false,
    bool pass2Reversed = false,
    bool useCustomRange = false,
    String rangeText = '',
    int copies = 1,
  }) =>
      PrintSettings(
        printerName: 'Test',
        mode: PrintMode.manualDuplex,
        paperSize: paperSize,
        insertBlankPage: insertBlankPage,
        pass2Reversed: pass2Reversed,
        useCustomRange: useCustomRange,
        rangeText: rangeText,
        copies: copies,
      );

  group('PaperSize', () {
    test('ánh xạ đúng khổ trang PDF của package pdf', () {
      expect(PaperSize.a4.format.width, pdfdoc.PdfPageFormat.a4.width);
      expect(PaperSize.a4.format.height, pdfdoc.PdfPageFormat.a4.height);
      expect(
        PaperSize.letter.format.width,
        pdfdoc.PdfPageFormat.letter.width,
      );
      expect(
        PaperSize.letter.format.height,
        pdfdoc.PdfPageFormat.letter.height,
      );
      expect(PaperSize.a3.format.width, pdfdoc.PdfPageFormat.a3.width);
      expect(PaperSize.a3.format.height, pdfdoc.PdfPageFormat.a3.height);
      expect(
        PaperSize.legal.format.width,
        pdfdoc.PdfPageFormat.legal.width,
      );
      expect(
        PaperSize.legal.format.height,
        pdfdoc.PdfPageFormat.legal.height,
      );
    });

    test(
        'PrintSettings mặc định A4, đảo ngược lượt 2 + chêm trang trắng; '
        'copy giữ nguyên', () {
      final s = PrintSettings(printerName: 'P');
      expect(s.paperSize, PaperSize.a4);
      expect(s.pass2Reversed, isTrue);
      expect(s.insertBlankPage, isTrue);
      final changed = s.copy()
        ..paperSize = PaperSize.legal
        ..pass2Reversed = false
        ..insertBlankPage = false;
      final copied = changed.copy();
      expect(copied.paperSize, PaperSize.legal);
      expect(copied.pass2Reversed, isFalse);
      expect(copied.insertBlankPage, isFalse);
    });
  });

  group('PrintFlow.plan — checkbox chêm trang trắng', () {
    PrintPlan okPlan(DocumentItem d, PrintSettings st) {
      final result = flow().plan(document: d, settings: st);
      expect(result, isA<Ok<PrintPlan>>());
      return (result as Ok<PrintPlan>).value;
    }

    test('mặc định mới: tài liệu 5 trang, lượt 2 đảo ngược + trang trắng', () {
      // Không truyền cờ nào — dùng đúng mặc định của PrintSettings.
      final plan = okPlan(doc(5), PrintSettings(printerName: 'Test'));
      expect(plan.pass1Pages, [1, 3, 5]);
      expect(plan.pass2Pages, [null, 4, 2]);
      expect(plan.totalSheets, 3);
    });

    test('tài liệu 5 trang, bật checkbox: lượt 2 có null ở CUỐI', () {
      final plan = okPlan(doc(5), duplex(insertBlankPage: true));
      expect(plan.pass1Pages, [1, 3, 5]);
      expect(plan.pass2Pages, [2, 4, null]);
      expect(plan.totalSheets, 3);
    });

    test('bật checkbox + đảo ngược lượt 2: trang trắng lên ĐẦU lượt 2', () {
      final plan = okPlan(
        doc(5),
        duplex(insertBlankPage: true, pass2Reversed: true),
      );
      expect(plan.pass2Pages, [null, 4, 2]);
    });

    test('tắt checkbox: lượt 2 không có trang trắng (hành vi cũ)', () {
      final plan = okPlan(doc(5), duplex(insertBlankPage: false));
      expect(plan.pass2Pages, [2, 4]);
      expect(plan.pass2Pages!.contains(null), isFalse);
    });

    test('tài liệu chẵn trang, bật checkbox: không chêm trang trắng', () {
      final plan = okPlan(doc(6), duplex(insertBlankPage: true));
      expect(plan.pass2Pages, [2, 4, 6]);
    });

    test('phạm vi tùy chọn 1-5 (5 trang in, lẻ), bật checkbox: có null', () {
      final plan = okPlan(
        doc(6),
        duplex(
          insertBlankPage: true,
          useCustomRange: true,
          rangeText: '1-5',
        ),
      );
      expect(plan.pass1Pages, [1, 3, 5]);
      expect(plan.pass2Pages, [2, 4, null]);
    });

    test('số bản 2 + bật checkbox: trang trắng lặp theo từng bản', () {
      final plan = okPlan(
        doc(5),
        duplex(insertBlankPage: true, copies: 2),
      );
      expect(plan.pass1Pages, [1, 1, 3, 3, 5, 5]);
      expect(plan.pass2Pages, [2, 2, 4, 4, null, null]);
      expect(plan.totalSheets, 6);
    });

    test('in một mặt: không có lượt 2, không có trang trắng', () {
      final plan = okPlan(
        doc(5),
        PrintSettings(
          printerName: 'Test',
          mode: PrintMode.singleSided,
          insertBlankPage: true,
        ),
      );
      expect(plan.pass2Pages, isNull);
      expect(plan.pass1Pages.contains(null), isFalse);
    });
  });

  group('Widget — hàng thẻ cột 3 với tham số mới không tràn', () {
    testWidgets(
        'thẻ chế độ in (padding 8, override booklet) + thẻ lật '
        '(padding 8, icon 14), VI + EN, nhiều chiều rộng', (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final locale in [const Locale('vi'), const Locale('en')]) {
        final s = S(locale);
        for (final width in [240.0, 300.0, 460.0]) {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1.0;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      // Thẻ chế độ in — đúng tham số như màn hình chính.
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: AppOptionCard(
                                selected: true,
                                onTap: () {},
                                icon: Icons.menu_book_outlined,
                                title: s.modeDuplex,
                                description: s.modeDuplexDesc,
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppOptionCard(
                                selected: false,
                                onTap: () {},
                                icon: Icons.bookmark_outline,
                                title: s.modeBooklet,
                                description: s.modeBookletDesc,
                                padding: const EdgeInsets.all(8),
                                titleWeight: FontWeight.w700,
                                unselectedTitleColor: const Color(0xFFA5B4FC),
                                unselectedIconColor: const Color(0xFF818CF8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppOptionCard(
                                selected: false,
                                onTap: () {},
                                icon: Icons.description_outlined,
                                title: s.modeSingle,
                                description: s.modeSingleDesc,
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Thẻ lật giấy — đúng tham số như màn hình chính.
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: AppOptionCard(
                                selected: true,
                                onTap: () {},
                                icon: Icons.book_outlined,
                                title: s.flipLong,
                                description: s.flipLongDesc,
                                padding: const EdgeInsets.all(8),
                                iconSize: 14,
                                showRadioDot: false,
                                borderRadius: 8,
                                iconInlineWithTitle: true,
                                selectedColor: const Color(0xFF0C4A6E)
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppOptionCard(
                                selected: false,
                                onTap: () {},
                                icon: Icons.calendar_today_outlined,
                                title: s.flipShort,
                                description: s.flipShortDesc,
                                padding: const EdgeInsets.all(8),
                                iconSize: 14,
                                showRadioDot: false,
                                borderRadius: 8,
                                iconInlineWithTitle: true,
                                selectedColor: const Color(0xFF0C4A6E)
                                    .withValues(alpha: 0.4),
                                unselectedIconColor: const Color(0xFFFBBF24),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Hàng thẻ phạm vi in — nhãn dài "Trang tùy chọn…".
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: AppOptionCard(
                                selected: true,
                                onTap: () {},
                                child: Text(
                                  s.pageRangeAll,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppOptionCard(
                                selected: false,
                                onTap: () {},
                                child: Text(
                                  s.pageRangeCustom,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Dropdown khổ giấy (trạng thái đóng) render được.
                      DropdownButtonFormField<PaperSize>(
                        initialValue: PaperSize.a4,
                        items: PaperSize.values.map((size) {
                          return DropdownMenuItem(
                            value: size,
                            child: Text(
                              switch (size) {
                                PaperSize.a4 => s.paperSizeA4,
                                PaperSize.letter => s.paperSizeLetter,
                                PaperSize.a3 => s.paperSizeA3,
                                PaperSize.legal => s.paperSizeLegal,
                              },
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          // Mô tả thẻ lật hiển thị ở cả 2 ngôn ngữ.
          expect(find.text(s.flipLongDesc), findsOneWidget);
          expect(find.text(s.flipShortDesc), findsOneWidget);
          Object? error;
          while (true) {
            final e = tester.takeException();
            if (e == null) break;
            error ??= e;
          }
          expect(error, isNull,
              reason: 'Tràn layout ở locale $locale, rộng $width');
        }
      }
    });
  });
}
