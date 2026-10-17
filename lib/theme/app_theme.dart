import 'package:flutter/material.dart';

/// Bảng màu giao diện tối theo design brief (slate + sky).
/// Mọi màu dùng trong app đều lấy từ đây để đồng nhất.
class AppColors {
  AppColors._();

  // Nền & panel.
  static const background = Color(0xFF020617); // slate-950
  static const panel = Color(0xFF0F172A); // slate-900
  static const input = Color(0xFF1E293B); // slate-800
  static const hover = Color(0xFF334155); // slate-700

  // Viền.
  static const border = Color(0xFF1E293B); // primary border
  static const borderStrong = Color(0xFF334155); // secondary border

  // Chữ.
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFFE2E8F0);
  static const textSecondary2 = Color(0xFFCBD5E1);
  static const textMuted = Color(0xFF94A3B8);
  static const textFaint = Color(0xFF64748B);
  static const textFaint2 = Color(0xFF475569);

  // Accent sky.
  static const sky600 = Color(0xFF0284C7);
  static const sky700 = Color(0xFF0369A1);
  static const sky800 = Color(0xFF075985);
  static const sky500 = Color(0xFF0EA5E9);
  static const sky400 = Color(0xFF38BDF8);
  static const sky300 = Color(0xFF7DD3FC);
  static const sky200 = Color(0xFFBAE6FD);
  static const blue600 = Color(0xFF2563EB);
  static const blue500 = Color(0xFF3B82F6);
  static const cyan500 = Color(0xFF06B6D4);
  static const accentBg = Color(0xFF082F49); // light accent bg (sky-950)
  static const accentBgSoft = Color(0xFF0C4A6E); // sky-900-ish

  // Trạng thái.
  static const success = Color(0xFF34D399);
  static const successSoft = Color(0xFF6EE7B7);
  static const successBg = Color(0xFF022C22);
  static const successBorder = Color(0xFF065F46); // emerald-800
  static const warning = Color(0xFFFBBF24);
  static const warningSoft = Color(0xFFFCD34D);
  static const warningPale = Color(0xFFFDE68A);
  static const error = Color(0xFFFB7185);
  static const errorSoft = Color(0xFFFDA4AF);
  static const errorPale = Color(0xFFFECDD3);
  static const rose950 = Color(0xFF4C0519);
  static const rose800 = Color(0xFF9F1239);
  static const teal400 = Color(0xFF2DD4BF);
  static const bookletAccent = Color(0xFF818CF8); // indigo-400
  static const bookletAccentSoft = Color(0xFFA5B4FC); // indigo-300

  // Viền riêng chế độ đóng sách (đo từ ảnh tham chiếu — chỉ dùng
  // cho UI đóng sách, không dùng cho UI 2 mặt / 1 mặt).
  static const bookletBorderOuter = Color(0xFF2F2497);
  static const bookletBorderSelected = Color(0xFF7C86FF);
  static const bookletBorderUnselected = Color(0xFF314158);
  static const bookletBorderInner = Color(0xFF292672);

  // Gradient nút chính.
  static const primaryGradient = [sky600, blue600];
  static const primaryGradientHover = [sky500, blue500];
  static const logoGradient = [sky600, cyan500];
}

/// Kiểu chữ dùng chung: sans hệ thống; mono cho badge/zoom/nhãn trang.
class AppText {
  AppText._();

  static const _monoFamily = 'Consolas';
  static const _monoFallback = ['Courier New', 'monospace'];

  static const panelTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const sectionLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.sky300,
    letterSpacing: 1.2,
  );

  static const fieldLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary2,
  );

  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const monoBadge = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    fontFamily: _monoFamily,
    fontFamilyFallback: _monoFallback,
  );

  static const monoLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary2,
    fontFamily: _monoFamily,
    fontFamilyFallback: _monoFallback,
  );
}

/// Theme tối toàn app.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final scheme = ColorScheme.dark(
      primary: AppColors.sky500,
      onPrimary: Colors.white,
      secondary: AppColors.sky400,
      onSecondary: Colors.white,
      surface: AppColors.panel,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.borderStrong,
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
      fontFamily: null, // Sans hệ thống (Segoe UI trên Windows).
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: AppText.panelTitle,
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: AppText.body,
        bodyMedium: AppText.body,
        bodySmall: AppText.bodySmall,
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary2,
        ),
        labelSmall: AppText.caption,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary2,
        size: 20,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: AppText.body,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.input,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        labelStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.textMuted,
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textFaint,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.sky500,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.textSecondary,
        iconColor: AppColors.textMuted,
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        textColor: AppColors.textSecondary,
        collapsedTextColor: AppColors.textSecondary2,
        iconColor: AppColors.textMuted,
        collapsedIconColor: AppColors.textMuted,
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.sky500;
          }
          return AppColors.textFaint;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.sky500;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.borderStrong),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.sky500;
          }
          return AppColors.hover;
        }),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.sky300,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.sky600,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.input,
          disabledForegroundColor: AppColors.textFaint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.input,
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textSecondary2,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.input,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderStrong),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.sky500,
        linearTrackColor: AppColors.input,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.hover),
        trackColor: WidgetStateProperty.all(Colors.transparent),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.panel,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
    );
  }
}
