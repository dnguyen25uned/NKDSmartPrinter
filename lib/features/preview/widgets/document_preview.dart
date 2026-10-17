import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../../localization/strings.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_widgets.dart';

/// Thông tin tờ giấy cho trang đang xem trước:
/// `sheet` = "Tờ giấy vật lý: a / b", `side` = nhãn mặt giấy,
/// `spine` = gáy đóng cuốn (chỉ chế độ đóng sách).
typedef SheetInfo = ({String sheet, String side, String? spine});

/// Toàn bộ panel giữa: thanh công cụ xem trước (tên file, badge,
/// nút chuyển trang) + hàng thông tin tờ giấy + canvas xem trước.
///
/// Xem trước tài liệu PDF: render trung thực bằng Pdfium (nội dung gốc:
/// văn bản, hình ảnh, bảng, màu, khổ trang). Chuyển trang bằng nút hoặc
/// cuộn. Phóng to/thu nhỏ bằng thao tác pinch/trackpad (tích hợp sẵn
/// trong PdfView). Dùng PdfView/PdfController — biến thể pinch của
/// pdfx không hỗ trợ Windows, và PdfController không có API zoom bằng
/// code nên thanh công cụ không có nút zoom (xem báo cáo fidelity pass).
class DocumentPreview extends StatefulWidget {
  const DocumentPreview({
    super.key,
    required this.pdfPath,
    required this.fileName,
    required this.strings,
    required this.onPageChanged,
    this.sheetInfoForPage,
  });

  /// Đường dẫn PDF đã chuyển đổi; null = chưa có tài liệu để xem trước.
  final String? pdfPath;
  final String? fileName;
  final S strings;
  final void Function(int page) onPageChanged;

  /// Trả về thông tin tờ giấy cho `page` (null = ẩn hàng thông tin).
  final SheetInfo? Function(int page)? sheetInfoForPage;

  @override
  State<DocumentPreview> createState() => _DocumentPreviewState();
}

class _DocumentPreviewState extends State<DocumentPreview> {
  PdfController? _controller;
  PdfDocument? _doc;
  int _currentPage = 1;
  int _totalPages = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ensureController();
  }

  void _ensureController() {
    final path = widget.pdfPath;
    if (path == null || _controller != null) return;
    _controller = PdfController(document: PdfDocument.openFile(path));
  }

  @override
  void didUpdateWidget(covariant DocumentPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pdfPath != widget.pdfPath) {
      // Đóng tài liệu + controller cũ, tạo controller mới cho tài liệu mới.
      final previous = _doc;
      _doc = null;
      _controller?.dispose();
      _controller = null;
      setState(() {
        _currentPage = 1;
        _totalPages = 0;
        _error = null;
      });
      previous?.close();
      _ensureController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _doc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final hasDoc = widget.pdfPath != null;
    final sheetInfo =
        hasDoc ? widget.sheetInfoForPage?.call(_currentPage) : null;
    final controller = _controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Thanh công cụ xem trước: tên file + badge | nút chuyển trang.
        // Khi panel giữa hẹp (< 320px), dùng bản gọn (bỏ badge + cột
        // trống cân bằng) để không tràn ngang.
        Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 320;
              final titleRow = Row(
                children: [
                  const Icon(
                    Icons.layers_outlined,
                    size: 20,
                    color: AppColors.sky400,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.fileName ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (hasDoc && !compact) ...[
                    const SizedBox(width: 8),
                    // Badge co lại + ellipsis khi panel giữa hẹp.
                    Flexible(
                      child: AppBadge(text: s.previewRealContent),
                    ),
                  ],
                ],
              );
              // Pill phân trang: nút trước + "Trang x / y" + nút sau.
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
                    _PillIconButton(
                      icon: Icons.chevron_left,
                      tooltip: s.prevPage,
                      onPressed: controller != null && _currentPage > 1
                          ? () => controller.previousPage(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                              )
                          : null,
                    ),
                    Flexible(
                      child: Text(
                        hasDoc ? s.pageOf(_currentPage, _totalPages) : '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    _PillIconButton(
                      icon: Icons.chevron_right,
                      tooltip: s.nextPage,
                      onPressed:
                          controller != null && _currentPage < _totalPages
                              ? () => controller.nextPage(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                  )
                              : null,
                    ),
                  ],
                ),
              );
              // Bản gọn (< 320px): xếp chồng — tên file lên trên,
              // pill xuống dưới dồn phải (co lại được) thay vì ép
              // 1 hàng gây tràn phải khi pill + icon tên file vượt
              // quá chiều rộng panel.
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
                  // Cột trống cân bằng để pill phân trang nằm giữa.
                  const Expanded(child: SizedBox()),
                ],
              );
            },
          ),
        ),
        const Divider(height: 1),
        // Hàng thông tin tờ giấy (ẩn khi không tính được).
        if (sheetInfo != null)
          Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    sheetInfo.spine != null
                        ? '${sheetInfo.sheet} • ${s.sheetSpine(sheetInfo.spine!)}'
                        : sheetInfo.sheet,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                AppBadge(
                  text: sheetInfo.side,
                  dotColor: AppColors.sky400,
                  fontSize: 12,
                ),
              ],
            ),
          ),
        // Canvas xem trước.
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              // Nền tối quanh trang trắng, viền mỏng + bóng lớn cho trang.
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  if (_error != null)
                    Center(
                      child: Text(_error!, textAlign: TextAlign.center),
                    )
                  else if (controller != null)
                    PdfView(
                      controller: controller,
                      scrollDirection: Axis.vertical,
                      onDocumentLoaded: (doc) {
                        if (mounted) {
                          setState(() {
                            _doc = doc;
                            _totalPages = doc.pagesCount;
                            _error = null;
                          });
                        }
                      },
                      onDocumentError: (_) {
                        if (mounted) {
                          setState(
                            () => _error = s.errorFor('error_pdf_unreadable'),
                          );
                        }
                      },
                      onPageChanged: (page) {
                        if (mounted) setState(() => _currentPage = page);
                        widget.onPageChanged(page);
                      },
                    )
                  else
                    Center(
                      child: Text(
                        s.previewUnavailable,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  // Nhãn "trang x / y" mono 9px ở góc dưới-phải của trang.
                  if (controller != null && _error == null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Text(
                        s.pageOf(_currentPage, _totalPages),
                        style: AppText.monoBadge,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Nút icon 24×24 trong pill phân trang.
class _PillIconButton extends StatelessWidget {
  const _PillIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(6),
            child: Icon(
              icon,
              size: 16,
              color: enabled ? AppColors.textSecondary : AppColors.textFaint,
            ),
          ),
        ),
      ),
    );
  }
}
