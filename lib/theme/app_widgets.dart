import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Decoration chung của mọi panel: nền slate-900, bo 16px,
/// viền 1px, bóng lớn.
BoxDecoration panelDecoration() => BoxDecoration(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );

/// Panel chuẩn: bo 16px, viền 1px, hàng tiêu đề + divider,
/// nội dung cuộn bên trong. `footer` (nếu có) cố định ở đáy panel.
class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.header,
    required this.child,
    this.footer,
    this.contentPadding = const EdgeInsets.all(16),
    this.headerPadding = const EdgeInsets.all(16),
  });

  final Widget header;
  final Widget child;
  final Widget? footer;
  final EdgeInsets contentPadding;
  final EdgeInsets headerPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: headerPadding,
            child: header,
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: contentPadding,
              child: child,
            ),
          ),
          if (footer != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: footer!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Tiêu đề panel: icon 20px + chữ 14px semibold.
class AppPanelTitle extends StatelessWidget {
  const AppPanelTitle({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.sky400),
        const SizedBox(width: 8),
        Text(text, style: AppText.panelTitle),
      ],
    );
  }
}

/// Thanh header cao 57px: logo + tên app + subtitle trái,
/// cụm nút công cụ phải.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 57),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        border: const Border(
          bottom: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo: ảnh NKD 36px bo 12, cùng ảnh với icon file .exe
          // (assets/app_logo.png). Giữ bóng đổ cũ để nổi trên header.
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sky500.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/app_logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Tiêu đề co lại + ellipsis khi cửa sổ hẹp/cỡ chữ lớn,
          // để header không bao giờ tràn ngang (lỗi RIGHT OVERFLOWED).
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Tiêu đề chiếm hết chỗ còn lại, nút bấm dồn về phải.
          // Mỗi nút AppHeaderButton được bọc Flexible (loose) để khi
          // cửa sổ hẹp, nút co lại + nhãn ellipsis thay vì tràn ngang.
          ...actions.map(
            (a) => a is AppHeaderButton
                ? Flexible(fit: FlexFit.loose, child: a)
                : a,
          ),
        ],
      ),
    );
  }
}

/// Nút công cụ ở header: cao tối thiểu 32 (không cố định — tránh
/// tràn khi chữ/icon cao hơn), bo 8, viền 1px, chữ 12px semibold
/// + icon 14px cùng màu nhấn.
class AppHeaderButton extends StatelessWidget {
  const AppHeaderButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.color,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final c = enabled ? color : AppColors.textFaint;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 32),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.input,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderStrong),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: c),
              const SizedBox(width: 6),
              // Nhãn co lại + ellipsis khi nút bị bóp hẹp (cửa sổ hẹp).
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Footer mỏng ~41px, chữ 11px muted, chỉ tên app.
/// Chân trang: trái là thông tin trạng thái/phím tắt (ellipsis khi hẹp),
/// phải là pill tác giả + SĐT hỗ trợ (nội dung giống nhau ở cả 2 ngôn ngữ).
class AppFooter extends StatelessWidget {
  const AppFooter({super.key, required this.infoText});

  final String infoText;

  static const _authorText = 'Tác giả: Thiếu tá QNCN Nguyễn Kim Đạt';
  static const _phoneText = 'SĐT hỗ trợ: 035 929 6446';

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 41),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              infoText,
              style: AppText.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.borderStrong),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: AppColors.success,
                  ),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _authorText,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: AppColors.success,
                  ),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _phoneText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nút chính: full-width, gradient sky, chữ trắng bold 14px,
/// bo 12px, bóng sky nhẹ. Hỗ trợ trạng thái disabled.
/// Hover (chuột): gradient chuyển sang sky-500 → blue-500 như bản web.
class AppPrimaryButton extends StatefulWidget {
  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: enabled
                ? (_hovering
                    ? AppColors.primaryGradientHover
                    : AppColors.primaryGradient)
                : [AppColors.input, AppColors.input],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.sky500.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 16,
                      color: enabled ? Colors.white : AppColors.textFaint,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: enabled ? Colors.white : AppColors.textFaint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút phụ: nền slate-800, bo 8px, chữ 12px semibold.
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: enabled ? AppColors.input : AppColors.panel,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderStrong),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color:
                      enabled ? AppColors.textSecondary2 : AppColors.textFaint,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      enabled ? AppColors.textSecondary : AppColors.textFaint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nút sky: nền sky-600, chữ trắng 12px medium, bo 8px.
class AppSkyButton extends StatelessWidget {
  const AppSkyButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: enabled ? AppColors.sky600 : AppColors.input,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: enabled ? Colors.white : AppColors.textFaint,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: enabled ? Colors.white : AppColors.textFaint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thẻ lựa chọn: được chọn = nền sky-950/80 + viền sky-500 + ring sky +
/// chữ sky-200; chưa chọn = nền slate-800/80 + viền slate-700 + chữ
/// slate-400.
///
/// Hai dạng hiển thị:
/// - Dạng thẻ (web): truyền `icon` + `title` (+ `description`) — icon góc
///   trái + chấm radio góc phải, tiêu đề 12px semibold, mô tả 10px.
/// - Dạng đơn giản: chỉ truyền `child` — chấm radio + nội dung trên
///   một hàng (dùng cho thẻ phạm vi trang).
class AppOptionCard extends StatelessWidget {
  const AppOptionCard({
    super.key,
    required this.selected,
    required this.onTap,
    this.child,
    this.icon,
    this.title,
    this.description,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 10,
    ),
    this.selectedColor,
    this.unselectedTitleColor,
    this.unselectedIconColor,
    this.selectedBorderColor,
    this.unselectedBorderColor,
    this.titleWeight = FontWeight.w600,
    this.iconSize = 16,
    this.showRadioDot = true,
    this.borderRadius = 12,
    this.iconInlineWithTitle = false,
  }) : assert(child != null || title != null,
            'AppOptionCard cần child hoặc title.');

  final bool selected;
  final VoidCallback onTap;
  final Widget? child;
  final IconData? icon;
  final String? title;
  final String? description;

  /// Đệm trong thẻ (mặc định 12/10 — thẻ chế độ in / lật giấy của
  /// bản web dùng 8).
  final EdgeInsets padding;

  /// Màu nền khi được chọn (mặc định sky-950 80% — thẻ lật giấy của
  /// bản web dùng sky-900 40%).
  final Color? selectedColor;

  /// Màu tiêu đề khi CHƯA chọn (mặc định slate-400 — thẻ Đóng sách
  /// của bản web dùng indigo-300).
  final Color? unselectedTitleColor;

  /// Màu icon khi CHƯA chọn (mặc định slate-400 — thẻ Đóng sách của
  /// bản web dùng indigo-400, thẻ lật cạnh ngắn dùng amber-400).
  final Color? unselectedIconColor;

  /// Màu viền khi ĐƯỢC chọn (mặc định sky-500 — thẻ Đóng sách dùng
  /// #7C86FF đo từ ảnh tham chiếu). Cũng là màu vòng halo khi chọn.
  final Color? selectedBorderColor;

  /// Màu viền khi CHƯA chọn (mặc định slate-700 — thẻ Đóng sách dùng
  /// #314158 đo từ ảnh tham chiếu).
  final Color? unselectedBorderColor;

  /// Độ đậm tiêu đề (mặc định semibold — thẻ Đóng sách dùng bold).
  final FontWeight titleWeight;

  /// Cỡ icon (mặc định 16 — thẻ lật giấy của bản web dùng 14).
  final double iconSize;

  /// Hiện chấm radio ở góc phải (mặc định có — thẻ lật giấy của
  /// bản web không có chấm radio).
  final bool showRadioDot;

  /// Bo góc thẻ (mặc định 12 — thẻ lật giấy của bản web dùng 8).
  final double borderRadius;

  /// Icon ở bên trái, tiêu đề + mô tả trong cột bên phải (thẻ lật
  /// giấy): mô tả nằm cạnh icon, không tràn full-width dưới hàng
  /// tiêu đề.
  final bool iconInlineWithTitle;

  Widget _radioDot() {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.sky500 : AppColors.textFaint,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sky500,
                ),
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: selected
            ? (selectedColor ?? AppColors.accentBg.withValues(alpha: 0.8))
            : AppColors.input.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: selected
              ? (selectedBorderColor ?? AppColors.sky500)
              : (unselectedBorderColor ?? AppColors.borderStrong),
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: selectedBorderColor ?? AppColors.sky500,
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: title != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (iconInlineWithTitle)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (icon != null) ...[
                              Icon(
                                icon,
                                size: iconSize,
                                color: selected
                                    ? AppColors.sky400
                                    : (unselectedIconColor ??
                                        AppColors.textMuted),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    title!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: titleWeight,
                                      color: selected
                                          ? AppColors.sky200
                                          : (unselectedTitleColor ??
                                              AppColors.textMuted),
                                    ),
                                  ),
                                  if (description != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      description!,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        )
                      else ...[
                        Row(
                          children: [
                            if (icon != null)
                              Icon(
                                icon,
                                size: iconSize,
                                color: selected
                                    ? AppColors.sky400
                                    : (unselectedIconColor ??
                                        AppColors.textMuted),
                              ),
                            if (showRadioDot) ...[
                              const Spacer(),
                              _radioDot(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: titleWeight,
                            color: selected
                                ? AppColors.sky200
                                : (unselectedTitleColor ?? AppColors.textMuted),
                          ),
                        ),
                      ],
                      // Thẻ inline (lật giấy) đã render mô tả trong cột
                      // bên phải icon; chỉ render mô tả full-width cho
                      // các thẻ còn lại.
                      if (description != null && !iconInlineWithTitle) ...[
                        const SizedBox(height: 2),
                        Text(
                          description!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  )
                : Row(
                    children: [
                      _radioDot(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                            color: selected
                                ? AppColors.sky200
                                : AppColors.textMuted,
                          ),
                          child: child!,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Hộp thông tin: nền slate-950/60–70, bo 12px, viền slate-800.
class AppInfoBox extends StatelessWidget {
  const AppInfoBox({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final Color? backgroundColor;

  /// Màu viền (mặc định slate-800 — hộp ghi chú đóng sách dùng
  /// #2F2497 đo từ ảnh tham chiếu).
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.background.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: child,
    );
  }
}

/// Vùng kéo thả: viền đứt 2px, bo 12px.
class DashedBorderBox extends StatelessWidget {
  const DashedBorderBox({
    super.key,
    required this.child,
    required this.active,
  });

  final Widget child;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: active ? AppColors.sky500 : AppColors.borderStrong,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final radius = 12.0;
    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    const dashWidth = 8.0;
    const dashGap = 6.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final segment = metric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) => old.color != color;
}

/// Chấm trạng thái 8px.
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

/// Chấm 8px nhấp nháy (opacity 0.5 → 1.0).
class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key, required this.color});

  final Color color;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Opacity(
        opacity: 0.5 + 0.5 * _controller.value,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

/// Badge dạng pill: bo tròn, viền 1px, chữ 11px semibold,
/// kèm chấm nhấp nháy tùy chọn.
///
/// Các tham số `fontWeight` / `borderRadius` / `padding` mặc định giữ
/// nguyên dáng pill cũ; badge "N tờ giấy" của hộp kế hoạch in truyền
/// riêng bo 4 + chữ bold + đệm 8/2 theo bản web.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.text,
    this.dotColor,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.fontSize = 11,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = 999,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  });

  final String text;
  final Color? dotColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.accentBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.sky800,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            PulsingDot(color: dotColor!),
            const SizedBox(width: 5),
          ],
          // Flexible (không phải Text trần): khi badge bị ép hẹp
          // (vd trong Flexible của hàng tiêu đề), Text mới nhận
          // chiều rộng có biên để ellipsis kích hoạt; khi đủ chỗ,
          // badge vẫn ôm sát nội dung như cũ.
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor ?? AppColors.sky200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nhãn mục con: 12px bold, uppercase, sky-300, tracking rộng.
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppText.sectionLabel,
    );
  }
}

/// Nhãn trường nhập: 12px semibold slate-300 + icon 14–16px sky-400.
class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.sky400),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.fieldLabel,
          ),
        ),
      ],
    );
  }
}
