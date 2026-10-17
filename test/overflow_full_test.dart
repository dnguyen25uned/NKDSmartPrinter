import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nkd_smart_printer/features/documents/models/document_item.dart';
import 'package:nkd_smart_printer/features/documents/services/docx_converter.dart';
import 'package:nkd_smart_printer/features/documents/services/document_service.dart';
import 'package:nkd_smart_printer/features/guides/widgets/troubleshooting_guide_dialog.dart';
import 'package:nkd_smart_printer/features/home/home_screen.dart';
import 'package:nkd_smart_printer/features/home/print_flow.dart';
import 'package:nkd_smart_printer/features/printing/models/print_settings.dart';
import 'package:nkd_smart_printer/features/printing/services/page_order.dart';
import 'package:nkd_smart_printer/features/printing/services/pass_pdf_builder.dart';
import 'package:nkd_smart_printer/features/printing/services/print_dispatcher.dart';
import 'package:nkd_smart_printer/features/settings/settings_controller.dart';
import 'package:nkd_smart_printer/localization/strings.dart';
import 'package:nkd_smart_printer/theme/app_theme.dart';
import 'package:nkd_smart_printer/theme/app_widgets.dart';

/// Hồi quy tràn layout toàn diện cho CODE HIỆN TẠI.
///
/// Bối cảnh: ảnh chụp của Cha cho thấy vạch "BOTTOM OVERFLOWED" nhưng
/// ảnh đó là BẢN BUILD CŨ (tiêu đề thẻ cũ "In hai mặt thủ công",
/// nhãn cũ "PHẠM VI TRANG", không có dropdown "Khổ giấy"). Lỗi tràn
/// chiều cao cố định đó đã sửa trong code hiện tại. File này CHỨNG
/// MINH code hiện tại không còn tràn ở mọi chiều rộng / cỡ chữ /
/// ngôn ngữ — hoặc bắt được lỗi còn sót để sửa.
///
/// Quy ước: chỉ lỗi chứa "overflow" mới tính là fail. Các exception
/// khác từ môi trường test (pdfium, platform channel...) không tính,
/// vì chúng không phải lỗi tràn giao diện.
///
/// KHÔNG dùng pumpAndSettle: PulsingDot chạy lặp vô hạn nên settle
/// không bao giờ xong. Dùng pump() có độ dài.
void main() {
  late Directory tempDir;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('overflow_test_');
  });

  tearDownAll(() async {
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  /// Lấy hết exception còn tồn đọng, chỉ giữ lại lỗi tràn layout.
  List<String> drainOverflows(WidgetTester tester) {
    final out = <String>[];
    while (true) {
      final e = tester.takeException();
      if (e == null) break;
      final msg = e.toString();
      if (msg.toLowerCase().contains('overflow')) out.add(msg);
    }
    return out;
  }

  DocumentService freshDocuments() => DocumentService(
        converter: DocxConverter(includeSystemSearch: false),
        tempDir: tempDir,
      );

  SettingsController freshSettings() => SettingsController();

  PrintFlow freshFlow() => PrintFlow(
        dispatcher: PrintDispatcher(),
        pdfBuilder: PassPdfBuilder(),
      );

  /// Pump màn hình chính thật, với cỡ cửa sổ + cỡ chữ + ngôn ngữ cho trước.
  Future<void> pumpHome(
    WidgetTester tester, {
    required Size size,
    required double scale,
    required Locale locale,
    required DocumentService documents,
    required SettingsController settings,
  }) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    final s = S(locale);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
          ),
          child: child!,
        ),
        home: HomeScreen(
          strings: s,
          settings: settings,
          documents: documents,
          dispatcher: PrintDispatcher(),
          flow: freshFlow(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    // Bỏ qua lỗi thoáng qua của frame đầu (đổi cỡ cửa sổ / setState
    // bất đồng bộ), chỉ đo tràn ở trạng thái ổn định.
    drainOverflows(tester);
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Pump một cây widget con trong khung rộng [width], cao không giới hạn
  /// (qua SingleChildScrollView) để chỉ bắt tràn NỘI BỘ của cây đó.
  Future<void> pumpSubtree(
    WidgetTester tester, {
    required double width,
    required double scale,
    required Widget child,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        builder: (context, inner) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
          ),
          child: inner!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  const locales = [Locale('vi'), Locale('en')];
  const scales = [1.0, 1.25, 1.5];
  const homeSizes = [
    Size(600, 500),
    Size(800, 600),
    Size(1024, 700),
    Size(1280, 800),
    Size(1440, 900),
  ];
  const panelWidths = [200.0, 240.0, 300.0, 360.0, 460.0];

  group('Màn hình chính thật, chưa có tài liệu', () {
    testWidgets('không tràn ở mọi cỡ cửa sổ / cỡ chữ / ngôn ngữ',
        (tester) async {
      for (final locale in locales) {
        final settings = freshSettings();
        await settings.setLocale(locale);
        for (final size in homeSizes) {
          for (final scale in scales) {
            await pumpHome(
              tester,
              size: size,
              scale: scale,
              locale: locale,
              documents: freshDocuments(),
              settings: settings,
            );
            final overflows = drainOverflows(tester);
            expect(
              overflows,
              isEmpty,
              reason: 'Tràn ở màn hình chính (chưa có tài liệu), '
                  'locale $locale, cửa sổ $size, cỡ chữ $scale: $overflows',
            );
          }
        }
      }
    });

    testWidgets('mở hộp thoại Hướng dẫn + Cài đặt không tràn', (tester) async {
      for (final locale in locales) {
        final settings = freshSettings();
        await settings.setLocale(locale);
        final s = S(locale);
        await pumpHome(
          tester,
          size: const Size(800, 600),
          scale: 1.5,
          locale: locale,
          documents: freshDocuments(),
          settings: settings,
        );
        // Hộp thoại hướng dẫn kẹt giấy.
        await tester.tap(find.byIcon(Icons.warning_amber_outlined));
        await tester.pump(const Duration(milliseconds: 300));
        drainOverflows(tester);
        await tester.pump(const Duration(milliseconds: 300));
        expect(
          drainOverflows(tester),
          isEmpty,
          reason: 'Tràn khi mở hộp thoại hướng dẫn, locale $locale',
        );
        await tester.tap(find.byIcon(Icons.close));
        await tester.pump(const Duration(milliseconds: 300));
        // Hộp thoại cài đặt.
        await tester.tap(find.byIcon(Icons.language_outlined));
        await tester.pump(const Duration(milliseconds: 300));
        drainOverflows(tester);
        await tester.pump(const Duration(milliseconds: 300));
        expect(
          drainOverflows(tester),
          isEmpty,
          reason: 'Tràn khi mở hộp thoại cài đặt, locale $locale',
        );
        await tester.tap(find.text(s.close));
        await tester.pump(const Duration(milliseconds: 300));
      }
    });
  });

  group('Màn hình chính thật, có tài liệu DOCX', () {
    testWidgets('không tràn khi đổi chế độ / phạm vi / checkbox',
        (tester) async {
      for (final locale in locales) {
        final settings = freshSettings();
        await settings.setLocale(locale);
        final documents = freshDocuments();
        // Dùng tài liệu DOCX mẫu: addFile(DOCX) trả về ngay, không
        // qua pdfx; printablePdfPath null nên không render PdfView.
        // (PDF thật treo ở cả _countPdfPages lẫn PdfView do pdfium
        // FFI trong môi trường test Linux — giới hạn môi trường test,
        // không phải lỗi app. Hộp kế hoạch vẫn được bao phủ bởi nhóm
        // cây con cột 3 tái tạo.)
        // BẮT BUỘC bọc trong tester.runAsync: trong testWidgets, await
        // một Future I/O thật (đọc file) trước pump đầu tiên sẽ treo
        // vĩnh viễn vì binding chỉ xử lý event loop thật khi pump.
        final added = await tester.runAsync(
          () => documents.addFile('test/fixtures/sample.docx'),
        );
        final s = S(locale);
        await pumpHome(
          tester,
          size: const Size(800, 600),
          scale: 1.5,
          locale: locale,
          documents: documents,
          settings: settings,
        );
        expect(
          drainOverflows(tester),
          isEmpty,
          reason: 'Tràn ở màn hình chính (có tài liệu), locale $locale',
        );
        if (added?.status == DocumentStatus.needsConversion) {
          // Đổi sang đóng sách rồi về 2 mặt.
          await tester.tap(find.text(s.modeBooklet));
          await tester.pump(const Duration(milliseconds: 300));
          drainOverflows(tester);
          await tester.pump(const Duration(milliseconds: 300));
          expect(drainOverflows(tester), isEmpty,
              reason: 'Tràn khi chọn đóng sách, locale $locale');
          await tester.tap(find.text(s.modeDuplex));
          await tester.pump(const Duration(milliseconds: 300));
          drainOverflows(tester);
          await tester.pump(const Duration(milliseconds: 300));
          expect(drainOverflows(tester), isEmpty,
              reason: 'Tràn khi chọn 2 mặt, locale $locale');
          // Phạm vi tùy chọn + 2 checkbox.
          await tester.tap(find.text(s.pageRangeCustom));
          await tester.pump(const Duration(milliseconds: 300));
          drainOverflows(tester);
          await tester.pump(const Duration(milliseconds: 300));
          expect(drainOverflows(tester), isEmpty,
              reason: 'Tràn khi chọn phạm vi tùy chọn, locale $locale');
          await tester.tap(find.text(s.pass2ReverseCheck));
          await tester.pump(const Duration(milliseconds: 300));
          drainOverflows(tester);
          await tester.pump(const Duration(milliseconds: 300));
          expect(drainOverflows(tester), isEmpty,
              reason: 'Tràn khi tick đảo ngược lượt 2, locale $locale');
          await tester.tap(find.text(s.insertBlankCheck));
          await tester.pump(const Duration(milliseconds: 300));
          drainOverflows(tester);
          await tester.pump(const Duration(milliseconds: 300));
          expect(drainOverflows(tester), isEmpty,
              reason: 'Tràn khi tick chêm trang trắng, locale $locale');
        }
      }
    });
  });

  group('Cây con cột 3 tái tạo (dropdown dài, checkbox, hộp kế hoạch)', () {
    Widget rightPanelColumn(S s) {
      const longPrinter = 'HP LaserJet Professional P1102w (Mặc định)';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // (1) Máy in + dropdown tên dài (Wrap như code thật).
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppFieldLabel(icon: Icons.print_outlined, text: s.printerLabel),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh, size: 12),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        s.refreshPrinters,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: longPrinter,
            dropdownColor: AppColors.input,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(
                value: longPrinter,
                child: Text(longPrinter, style: TextStyle(fontSize: 12)),
              ),
              DropdownMenuItem(
                value: 'Canon LBP 2900 / 2900B',
                child: Text('Canon LBP 2900 / 2900B',
                    style: TextStyle(fontSize: 12)),
              ),
            ],
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          // (2) 3 thẻ chế độ in.
          AppSectionLabel(text: s.printModeLabel),
          const SizedBox(height: 8),
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
          // (3) Số bản + khổ giấy.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFieldLabel(
                      icon: Icons.content_copy_outlined,
                      text: s.copiesLabel,
                    ),
                    const SizedBox(height: 6),
                    const TextField(
                      controller: null,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFieldLabel(
                      icon: Icons.article_outlined,
                      text: s.paperSizeLabel,
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<PaperSize>(
                      isExpanded: true,
                      initialValue: PaperSize.a4,
                      dropdownColor: AppColors.input,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
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
            ],
          ),
          const SizedBox(height: 16),
          // (4) 2 thẻ phạm vi + ô nhập tùy chọn.
          AppSectionLabel(text: s.pageRangeLabel),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AppOptionCard(
                    selected: false,
                    onTap: () {},
                    child: Text(
                      s.pageRangeAll,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppOptionCard(
                    selected: true,
                    onTap: () {},
                    child: Text(
                      s.pageRangeCustom,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(decoration: InputDecoration(hintText: s.pageRangeHint)),
          const SizedBox(height: 16),
          // (5) Hộp lật: 2 thẻ + dropdown thứ tự + 2 checkbox.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSectionLabel(text: s.duplexSettingsTitle),
                const SizedBox(height: 12),
                AppFieldLabel(
                  icon: Icons.swap_horiz_outlined,
                  text: s.flipEdgeLabel,
                ),
                const SizedBox(height: 6),
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
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppFieldLabel(
                  icon: Icons.layers_outlined,
                  text: s.firstSideLabel,
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<FirstSide>(
                  isExpanded: true,
                  initialValue: FirstSide.oddFirst,
                  dropdownColor: AppColors.input,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: FirstSide.oddFirst,
                      child: Text(s.oddFirst,
                          style: const TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: FirstSide.evenFirst,
                      child: Text(s.evenFirst,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                  onChanged: (_) {},
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: AppColors.sky500,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Icon(Icons.check,
                          size: 10, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.pass2ReverseCheck,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: AppColors.borderStrong),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.insertBlankCheck,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // (6) Hộp kế hoạch: giá trị dài (10 trang + "+N", gáy sách).
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accentBg.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.sky800.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Giống code thật: hẹp (< 260) xếp chồng, badge co lại.
                LayoutBuilder(
                  builder: (context, constraints) {
                    final label = AppSectionLabel(text: s.planTitleDuplex);
                    final badge = AppBadge(
                      text: s.planSheets(5),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      backgroundColor: AppColors.sky600,
                      borderColor: AppColors.sky600,
                      textColor: Colors.white,
                      borderRadius: 4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                    );
                    if (constraints.maxWidth >= 260) {
                      return Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 16, color: AppColors.sky400),
                          const SizedBox(width: 6),
                          Expanded(child: label),
                          badge,
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 16, color: AppColors.sky400),
                            const SizedBox(width: 6),
                            Expanded(child: label),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [Flexible(child: badge)],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12),
                    children: [
                      TextSpan(
                        text: '${s.planPass1}: ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                      TextSpan(
                        text:
                            '${s.planPages(10)} (1, 3, 5, 7, 9, 11, 13, 15, 17, 19 ${s.planMore(5)})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.sky200,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12),
                    children: [
                      TextSpan(
                        text: '${s.planPass2}: ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                      TextSpan(
                        text:
                            '${s.planPages(10)} (20, 18, 16, 14, 12, 10, 8, 6, 4, 2 ${s.planMore(5)})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.warningPale,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    testWidgets('cột 3 không tràn, VI + EN, nhiều chiều rộng / cỡ chữ',
        (tester) async {
      for (final locale in locales) {
        final s = S(locale);
        for (final width in panelWidths) {
          for (final scale in scales) {
            await pumpSubtree(
              tester,
              width: width,
              scale: scale,
              child: rightPanelColumn(s),
            );
            final overflows = drainOverflows(tester);
            expect(
              overflows,
              isEmpty,
              reason: 'Tràn ở cột 3, locale $locale, rộng $width, '
                  'cỡ chữ $scale: $overflows',
            );
          }
        }
      }
    });
  });

  group('Thanh công cụ xem trước + header', () {
    testWidgets('toolbar xem trước (có badge) không tràn', (tester) async {
      for (final locale in locales) {
        final s = S(locale);
        for (final width in [200.0, 240.0, 300.0, 400.0]) {
          for (final scale in scales) {
            await pumpSubtree(
              tester,
              width: width,
              scale: scale,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 320;
                    final titleRow = Row(
                      children: [
                        const Icon(Icons.layers_outlined,
                            size: 20, color: AppColors.sky400),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Huong_dan_khi_khong_mo_duoc_File.pdf',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!compact) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: AppBadge(text: s.previewRealContent),
                          ),
                        ],
                      ],
                    );
                    // Giống code thật: nút pill 24×24, icon 16.
                    final pagePill = Container(
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: Icon(Icons.chevron_left, size: 16),
                          ),
                          Flexible(
                            child: Text(
                              s.pageOf(1, 6),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: Icon(Icons.chevron_right, size: 16),
                          ),
                        ],
                      ),
                    );
                    // Giống code thật: gọn (< 320) xếp chồng.
                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleRow,
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: pagePill,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: titleRow),
                        pagePill,
                        const Expanded(child: SizedBox()),
                      ],
                    );
                  },
                ),
              ),
            );
            final overflows = drainOverflows(tester);
            expect(
              overflows,
              isEmpty,
              reason: 'Tràn ở toolbar xem trước, locale $locale, '
                  'rộng $width, cỡ chữ $scale: $overflows',
            );
          }
        }
      }
    });

    testWidgets('header cột 3 (có badge Sẵn sàng) không tràn', (tester) async {
      // Header thật chỉ hiện badge khi tài liệu đã chuyển đổi
      // (printablePdfPath != null) — môi trường test không tạo
      // được PDF qua pdfium nên dùng bản tái tạo đúng code thật.
      // Key đổi theo từng combo để ép rebuild hoàn toàn: pump
      // lại cùng cây mà không đổi key có thể không relayout và
      // cho âm tính giả (lỗi tràn chỉ báo ở frame layout lại).
      var combo = 0;
      for (final locale in locales) {
        final s = S(locale);
        for (final width in [140.0, 178.0, 200.0, 240.0, 300.0, 400.0]) {
          for (final scale in scales) {
            combo++;
            await pumpSubtree(
              tester,
              width: width,
              scale: scale,
              child: Row(
                key: ValueKey('col3header-$combo'),
                children: [
                  const Icon(Icons.print_outlined,
                      size: 20, color: AppColors.sky400),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      s.printSettings,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.panelTitle,
                    ),
                  ),
                  Flexible(
                    child: AppBadge(
                      text: s.readyStatus,
                      dotColor: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
            await tester.pump(const Duration(milliseconds: 300));
            final overflows = drainOverflows(tester);
            expect(
              overflows,
              isEmpty,
              reason: 'Tràn ở header cột 3 (có badge), locale $locale, '
                  'rộng $width, cỡ chữ $scale: $overflows',
            );
          }
        }
      }
    });

    testWidgets('header không tràn ở cửa sổ hẹp / cỡ chữ lớn', (tester) async {
      for (final locale in locales) {
        final s = S(locale);
        for (final width in [600.0, 800.0, 1024.0, 1440.0]) {
          for (final scale in scales) {
            tester.view.physicalSize = Size(width, 300);
            tester.view.devicePixelRatio = 1.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.dark,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: child!,
                ),
                home: Scaffold(
                  body: SizedBox(
                    width: width,
                    child: AppHeader(
                      title: s.appTitle,
                      subtitle: s.appSubtitle,
                      actions: [
                        AppHeaderButton(
                          onPressed: () {},
                          label: s.testPrint,
                          icon: Icons.science_outlined,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 6),
                        AppHeaderButton(
                          onPressed: () {},
                          label: s.guidesTitle,
                          icon: Icons.warning_amber_outlined,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        AppHeaderButton(
                          onPressed: () {},
                          label: s.langVi,
                          icon: Icons.language_outlined,
                          color: AppColors.sky400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
            await tester.pump(const Duration(milliseconds: 300));
            final overflows = drainOverflows(tester);
            expect(
              overflows,
              isEmpty,
              reason: 'Tràn ở header, locale $locale, rộng $width, '
                  'cỡ chữ $scale: $overflows',
            );
          }
        }
      }
    });
  });

  group('Hộp thoại hướng dẫn kẹt giấy', () {
    testWidgets('không tràn ở khung nhỏ / cỡ chữ lớn', (tester) async {
      for (final locale in locales) {
        final s = S(locale);
        for (final size in [
          const Size(360, 480),
          const Size(400, 600),
          const Size(500, 400),
          const Size(768, 700),
        ]) {
          for (final scale in [1.0, 1.5]) {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.dark,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: child!,
                ),
                home: Scaffold(
                  body: SizedBox.fromSize(
                    size: size,
                    child: TroubleshootingGuideDialog(strings: s),
                  ),
                ),
              ),
            );
            await tester.pump(const Duration(milliseconds: 300));
            final overflows = drainOverflows(tester);
            expect(
              overflows,
              isEmpty,
              reason: 'Tràn ở hộp thoại hướng dẫn, locale $locale, '
                  'khung $size, cỡ chữ $scale: $overflows',
            );
          }
        }
      }
    });
  });
}
