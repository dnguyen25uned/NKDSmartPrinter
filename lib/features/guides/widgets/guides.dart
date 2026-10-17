import 'package:flutter/material.dart';

import '../../../localization/strings.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_widgets.dart';
import '../../printing/services/page_order.dart';

/// Sơ đồ hướng dẫn lật giấy: vẽ giấy + mũi tên lật theo cạnh đã chọn.
/// Sơ đồ là minh họa hướng dẫn (không phải dữ liệu), vẽ bằng code.
class FlipGuideDiagram extends StatelessWidget {
  const FlipGuideDiagram({super.key, required this.flipEdge});

  final FlipEdge flipEdge;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(220, 140),
      painter: _FlipPainter(
        flipEdge: flipEdge,
        color: AppColors.sky400,
      ),
    );
  }
}

class _FlipPainter extends CustomPainter {
  _FlipPainter({required this.flipEdge, required this.color});

  final FlipEdge flipEdge;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(30, 20, 160, 100);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, border);
    // Mũi tên lật: cạnh dài -> lật quanh trục dọc (mũi tên ngang);
    // cạnh ngắn -> lật quanh trục ngang (mũi tên dọc).
    final arrow = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    if (flipEdge == FlipEdge.longEdge) {
      final y = size.height / 2;
      canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), arrow);
      canvas.drawLine(
        Offset(size.width - 20, y),
        Offset(size.width - 32, y - 8),
        arrow,
      );
      canvas.drawLine(
        Offset(size.width - 20, y),
        Offset(size.width - 32, y + 8),
        arrow,
      );
    } else {
      final x = size.width / 2;
      canvas.drawLine(Offset(x, 10), Offset(x, size.height - 10), arrow);
      canvas.drawLine(
        Offset(x, size.height - 10),
        Offset(x - 8, size.height - 22),
        arrow,
      );
      canvas.drawLine(
        Offset(x, size.height - 10),
        Offset(x + 8, size.height - 22),
        arrow,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FlipPainter old) =>
      old.flipEdge != flipEdge || old.color != color;
}

/// Hướng dẫn lật giấy từng bước + sơ đồ.
class FlipGuide extends StatelessWidget {
  const FlipGuide({
    super.key,
    required this.strings,
    required this.flipEdge,
  });

  final S strings;
  final FlipEdge flipEdge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionLabel(text: strings.flipGuideTitle),
        const SizedBox(height: 8),
        FlipGuideDiagram(flipEdge: flipEdge),
        const SizedBox(height: 8),
        for (var i = 1; i <= 4; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              strings.flipGuideStep(i),
              style: AppText.bodySmall,
            ),
          ),
      ],
    );
  }
}
