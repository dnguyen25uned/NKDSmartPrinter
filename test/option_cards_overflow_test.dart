import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nkd_smart_printer/localization/strings.dart';
import 'package:nkd_smart_printer/theme/app_widgets.dart';

/// Hồi quy: thẻ chế độ in từng bị "BOTTOM OVERFLOWED BY 9.0 PIXELS"
/// do chiều cao cố định 68px trong khi nội dung (icon + tiêu đề + mô tả)
/// cao hơn. Test này pump đúng cấu trúc hàng thẻ với chuỗi thật ở cả
/// 2 ngôn ngữ, ở nhiều chiều rộng (kể cả hẹp), và fail nếu có lỗi tràn.
void main() {
  List<Object> drainExceptions(WidgetTester tester) {
    final errors = <Object>[];
    while (true) {
      final e = tester.takeException();
      if (e == null) break;
      errors.add(e);
    }
    return errors;
  }

  testWidgets(
      'Hàng thẻ chế độ in + lật giấy không tràn, VI + EN, nhiều chiều rộng',
      (tester) async {
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
                    // (2) Chế độ in: 3 thẻ — cùng cấu trúc như màn hình chính.
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // (5) 2 thẻ lật hai mặt.
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
                              showRadioDot: false,
                              borderRadius: 8,
                              iconInlineWithTitle: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Nút header: test riêng ở chiều rộng thực tế bên dưới.
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final errors = drainExceptions(tester);
        expect(
          errors,
          isEmpty,
          reason: 'Tràn layout ở locale $locale, rộng $width: $errors',
        );
      }
    }
  });

  testWidgets('Nút header không tràn ở chiều rộng thực tế, VI + EN',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final locale in [const Locale('vi'), const Locale('en')]) {
      final s = S(locale);
      tester.view.physicalSize = const Size(800, 200);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppHeaderButton(
                  onPressed: () {},
                  label: s.testPrint,
                  icon: Icons.science_outlined,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                AppHeaderButton(
                  onPressed: () {},
                  label: s.guidesTitle,
                  icon: Icons.shield_outlined,
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                AppHeaderButton(
                  onPressed: () {},
                  label: s.languageLabel,
                  icon: Icons.language_outlined,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final errors = drainExceptions(tester);
      expect(errors, isEmpty, reason: 'Tràn nút header ở locale $locale');
    }
  });
}
