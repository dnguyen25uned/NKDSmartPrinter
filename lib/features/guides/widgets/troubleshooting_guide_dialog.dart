import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../localization/strings.dart';
import '../../../theme/app_theme.dart';

/// Lệnh mở cửa sổ máy in / hàng đợi in của Windows.
const kOpenQueueCommand = 'control printers';

/// Chuỗi 3 lệnh CMD (quản trị) khởi động lại Print Spooler:
/// dừng dịch vụ -> xóa file trong thư mục spool -> chạy lại dịch vụ.
const kSpoolerRestartCommands = 'net stop spooler\n'
    'del %systemroot%\\System32\\spool\\PRINTERS\\* /Q\n'
    'net start spooler';

/// Mở hộp thoại hướng dẫn xử lý sự cố & kẹt giấy (dialog riêng,
/// không gộp nội dung in thử/hiệu chuẩn).
Future<void> showTroubleshootingGuideDialog({
  required BuildContext context,
  required S strings,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: AppColors.background.withValues(alpha: 0.8),
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 768,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: TroubleshootingGuideDialog(strings: strings),
        ),
      ),
    ),
  );
}

/// Hộp thoại hướng dẫn xử lý sự cố & kẹt giấy an toàn.
///
/// Cấu trúc: tiêu đề + nút X -> Phần 1 (6 ô an toàn kẹt giấy) ->
/// Phần 2 (lệnh hàng đợi in) -> Phần 3 (bảng tra mã lỗi) ->
/// chân chỉ có nút Đóng. Nội dung cuộn dọc, không tab/accordion.
class TroubleshootingGuideDialog extends StatelessWidget {
  const TroubleshootingGuideDialog({super.key, required this.strings});

  final S strings;

  static const _cellTitleColors = [
    AppColors.warning, // amber
    AppColors.error, // rose
    AppColors.sky400, // sky
    AppColors.warning, // amber
    AppColors.success, // emerald
    AppColors.teal400, // teal
  ];

  static const _errorCodeColors = [
    AppColors.errorSoft, // rose
    AppColors.warningSoft, // amber
    AppColors.sky300, // sky
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.panel,
          border: Border.all(
            color: AppColors.borderStrong.withValues(alpha: 0.8),
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildJamSection(context),
                    const SizedBox(height: 20),
                    _buildQueueSection(),
                    const SizedBox(height: 20),
                    _buildErrorsSection(),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              strings.troubleshootTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 20),
            tooltip: strings.close,
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) return Colors.white;
                return AppColors.textMuted;
              }),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return AppColors.input;
                }
                return Colors.transparent;
              }),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return AppColors.hover;
                }
                return AppColors.input;
              }),
              foregroundColor: WidgetStateProperty.all(
                AppColors.textSecondary,
              ),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            child: Text(strings.close),
          ),
        ],
      ),
    );
  }

  Widget _buildJamSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.rose950.withValues(alpha: 0.3),
        border: Border.all(
          color: AppColors.rose800.withValues(alpha: 0.6),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.troubleshootJamTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.errorPale,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 480;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (var i = 1; i <= 6; i++)
                    SizedBox(
                      width: twoColumns
                          ? (constraints.maxWidth - 12) / 2
                          : constraints.maxWidth,
                      child: _JamCell(
                        title: strings.troubleshootJamCellTitle(i),
                        description: strings.troubleshootJamCellDesc(i),
                        titleColor: _cellTitleColors[i - 1],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQueueSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.input.withValues(alpha: 0.6),
        border: Border.all(
          color: AppColors.borderStrong.withValues(alpha: 0.8),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal, color: AppColors.sky400, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.troubleshootQueueTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            strings.troubleshootQueueDesc,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary2,
            ),
          ),
          const SizedBox(height: 12),
          _CopyCommandBlock(
            label: strings.troubleshootCmd1Label,
            command: kOpenQueueCommand,
            copyLabel: strings.troubleshootCopy,
            copiedLabel: strings.troubleshootCopied,
            multiLine: false,
          ),
          const SizedBox(height: 12),
          _CopyCommandBlock(
            label: strings.troubleshootCmd2Label,
            command: kSpoolerRestartCommands,
            copyLabel: strings.troubleshootCopy,
            copiedLabel: strings.troubleshootCopied,
            multiLine: true,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.input.withValues(alpha: 0.6),
        border: Border.all(
          color: AppColors.borderStrong.withValues(alpha: 0.8),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.troubleshootErrorsTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            strings.troubleshootErrorsLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 1; i <= 3; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i < 3 ? 8 : 0),
              child: _ErrorRow(
                code: strings.troubleshootErrorCode(i),
                description: strings.troubleshootErrorDesc(i),
                codeColor: _errorCodeColors[i - 1],
              ),
            ),
        ],
      ),
    );
  }
}

class _JamCell extends StatelessWidget {
  const _JamCell({
    required this.title,
    required this.description,
    required this.titleColor,
  });

  final String title;
  final String description;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.8),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              height: 1.5,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyCommandBlock extends StatefulWidget {
  const _CopyCommandBlock({
    required this.label,
    required this.command,
    required this.copyLabel,
    required this.copiedLabel,
    required this.multiLine,
  });

  final String label;
  final String command;
  final String copyLabel;
  final String copiedLabel;
  final bool multiLine;

  @override
  State<_CopyCommandBlock> createState() => _CopyCommandBlockState();
}

class _CopyCommandBlockState extends State<_CopyCommandBlock> {
  bool _copied = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.command));
    if (!mounted) return;
    setState(() => _copied = true);
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.8),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _copy,
                icon: Icon(
                  _copied ? Icons.check : Icons.copy,
                  size: 14,
                ),
                label: Text(_copied ? widget.copiedLabel : widget.copyLabel),
                style: TextButton.styleFrom(
                  foregroundColor:
                      _copied ? AppColors.success : AppColors.sky300,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (widget.multiLine)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.panel,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  widget.command,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontFamily: 'Consolas',
                    fontFamilyFallback: ['Courier New', 'monospace'],
                  ),
                ),
              ),
            )
          else
            SelectableText(
              widget.command,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.sky300,
                fontFamily: 'Consolas',
                fontFamilyFallback: ['Courier New', 'monospace'],
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({
    required this.code,
    required this.description,
    required this.codeColor,
  });

  final String code;
  final String description;
  final Color codeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.6),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              code,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: codeColor,
                fontFamily: 'Consolas',
                fontFamilyFallback: ['Courier New', 'monospace'],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
