import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_error.dart';
import '../../core/result.dart';
import '../../localization/strings.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';
import '../documents/models/document_item.dart';
import '../documents/services/document_service.dart';
import '../documents/services/docx_converter.dart';
import '../guides/widgets/guides.dart';
import '../guides/widgets/troubleshooting_guide_dialog.dart';
import '../preview/widgets/document_preview.dart';
import '../printing/models/print_settings.dart';
import '../printing/services/booklet_imposition.dart';
import '../printing/services/duplex_controller.dart';
import '../printing/services/page_order.dart';
import '../printing/services/page_range.dart';
import '../printing/services/print_dispatcher.dart';
import '../settings/settings_controller.dart';
import 'print_flow.dart';

/// Màn hình chính: danh sách tài liệu | xem trước | cài đặt in.
///
/// Mọi thao tác in đều bắt đầu bằng nút bấm — app không bao giờ tự in
/// khi mở ứng dụng hoặc khi thêm tài liệu.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.strings,
    required this.settings,
    required this.documents,
    required this.dispatcher,
    required this.flow,
  });

  final S strings;
  final SettingsController settings;
  final DocumentService documents;
  final PrintDispatcher dispatcher;
  final PrintFlow flow;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DocumentItem? _selected;
  List<PrinterInfo> _printers = [];
  final PrintSettings _printSettings = PrintSettings(printerName: '');
  DuplexController? _controller;
  String? _statusKey;
  String? _rawMessage;
  bool _busy = false;
  bool _dragging = false;
  bool _loDialogOpen = false;
  final _rangeController = TextEditingController();
  final _copiesController = TextEditingController(text: '1');

  S get s => widget.strings;

  @override
  void initState() {
    super.initState();
    _refreshPrinters();
  }

  @override
  void dispose() {
    _rangeController.dispose();
    _copiesController.dispose();
    super.dispose();
  }

  Future<void> _refreshPrinters() async {
    final result = await widget.dispatcher.listPrinters();
    if (!mounted) return;
    if (result is Ok<List<PrinterInfo>>) {
      final printers = result.value;
      setState(() {
        _printers = printers;
        if (_printSettings.printerName.isEmpty && printers.isNotEmpty) {
          final def = printers.firstWhere(
            (p) => p.isDefault,
            orElse: () => printers.first,
          );
          _printSettings.printerName = def.name;
        }
      });
    } else {
      _showError((result as Err<List<PrinterInfo>>).error);
    }
  }

  void _showError(AppError error) {
    setState(() {
      _statusKey = error.messageKey;
      _rawMessage = error.rawSystemMessage;
    });
  }

  void _clearStatus() {
    setState(() {
      _statusKey = null;
      _rawMessage = null;
    });
  }

  Future<void> _addFiles() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx'],
      allowMultiple: true,
    );
    if (picked == null) return;
    for (final f in picked.files) {
      final path = f.path;
      if (path == null) continue;
      await _addOne(path);
    }
  }

  Future<void> _addOne(String path) async {
    final item = await widget.documents.addFile(path);
    if (!mounted) return;
    setState(() {
      _selected ??= item;
      if (item.status == DocumentStatus.error && item.errorMessageKey != null) {
        _statusKey = item.errorMessageKey;
      }
    });
    // DOCX: tự động chuyển sang PDF ngay khi tải lên để hiển thị và
    // in — không cần bấm "Chuyển đổi" nữa. Xem trước/in dùng cùng bản
    // PDF đã chuyển đổi nên khớp nhau.
    if (item.format == DocumentFormat.docx &&
        item.status == DocumentStatus.needsConversion) {
      final engine = await widget.documents.converterEngine();
      if (!mounted) return;
      if (engine != DocxEngine.none) {
        await _convertDocx(item);
        return;
      }
      // Chưa có engine nào (Word hay LibreOffice): hướng dẫn cài đặt
      // một lần ngay.
      await _maybeShowConverterSetup();
      if (!mounted) return;
      // Đã cài xong (bấm "Đã cài / Quét lại" trong hộp thoại) thì
      // chuyển ngay, không bắt thêm file lại hay bấm nút nữa.
      final after = await widget.documents.converterEngine();
      if (mounted &&
          after != DocxEngine.none &&
          item.status == DocumentStatus.needsConversion) {
        await _convertDocx(item);
      }
    }
  }

  /// Hộp thoại hướng dẫn cài Word/LibreOffice (chỉ khi chưa có engine
  /// nào và hộp thoại chưa mở — tránh xếp chồng khi thêm nhiều file).
  Future<void> _maybeShowConverterSetup() async {
    if (_loDialogOpen || !mounted) return;
    final engine = await widget.documents.converterEngine();
    if (!mounted || engine != DocxEngine.none) return;
    _loDialogOpen = true;
    var copied = false;
    var stillMissing = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Text(s.libreOfficeTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.libreOfficeBody),
                  const SizedBox(height: 12),
                  SelectableText(
                    libreOfficePortableUrl,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.sky300,
                    ),
                  ),
                  if (copied) ...[
                    const SizedBox(height: 8),
                    Text(
                      s.libreOfficeLinkCopied,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                  if (stillMissing) ...[
                    const SizedBox(height: 8),
                    Text(
                      s.libreOfficeStillMissing,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(
                    const ClipboardData(text: libreOfficePortableUrl),
                  );
                  setDialogState(() => copied = true);
                },
                child: Text(s.libreOfficeCopyLink),
              ),
              TextButton(
                onPressed: () async {
                  final eng = await widget.documents.converterEngine();
                  if (!dialogContext.mounted) return;
                  if (eng != DocxEngine.none) {
                    final String msg;
                    if (eng == DocxEngine.word) {
                      msg = s.wordFound;
                    } else {
                      final st = await widget.documents.libreOfficeStatus();
                      msg = s.libreOfficeFoundAt(st.path ?? '');
                    }
                    if (!dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg)),
                      );
                    }
                  } else {
                    setDialogState(() => stillMissing = true);
                  }
                },
                child: Text(s.libreOfficeRescan),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(s.close),
              ),
            ],
          );
        },
      ),
    );
    _loDialogOpen = false;
    // Đóng hộp thoại xong mà đã có engine (vừa cài + quét lại)
    // thì chuyển luôn tất cả DOCX đang chờ — kể cả file được thêm
    // trong lúc hộp thoại đang mở — khỏi bắt thêm lại hay bấm từng nút.
    if (mounted) {
      final after = await widget.documents.converterEngine();
      if (after != DocxEngine.none) {
        final pending = widget.documents.items
            .where(
              (e) =>
                  e.format == DocumentFormat.docx &&
                  e.status == DocumentStatus.needsConversion,
            )
            .toList();
        for (final item in pending) {
          if (!mounted) break;
          await _convertDocx(item);
        }
      }
    }
  }

  Future<void> _convertDocx(DocumentItem item) async {
    setState(() => _busy = true);
    final result = await widget.documents.convertDocx(item);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result is Err<DocumentItem>) {
      _showError(result.error);
    } else {
      _clearStatus();
      setState(() {});
    }
  }

  Future<void> _remove(DocumentItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.confirmRemoveTitle),
        content: Text(s.confirmRemoveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(s.remove),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.documents.remove(item);
    if (!mounted) return;
    setState(() {
      if (_selected?.id == item.id) _selected = null;
    });
  }

  /// Xóa toàn bộ danh sách sau khi xác nhận (file gốc không bị xóa).
  Future<void> _clearAll() async {
    if (widget.documents.items.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.confirmClearAllTitle),
        content: Text(s.confirmClearAllBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(s.clearAll),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    for (final item in List<DocumentItem>.of(widget.documents.items)) {
      await widget.documents.remove(item);
    }
    if (!mounted) return;
    setState(() => _selected = null);
  }

  /// Di chuyển tài liệu lên/xuống trong danh sách (delta = -1 / +1).
  void _moveItem(DocumentItem item, int delta) {
    final items = widget.documents.items;
    final idx = items.indexWhere((e) => e.id == item.id);
    final target = idx + delta;
    if (idx < 0 || target < 0 || target >= items.length) return;
    widget.documents.reorder(idx, target);
    setState(() {});
  }

  /// Mở hộp thoại hướng dẫn xử lý sự cố & kẹt giấy (dialog riêng;
  /// nội dung in thử/hiệu chuẩn nằm ở nút "In thử" trên header).
  void _openGuides() {
    showTroubleshootingGuideDialog(context: context, strings: s);
  }

  /// Các trang được chọn theo phạm vi (null = phạm vi lỗi).
  List<int>? _selectedPages(int total, PrintSettings settings) {
    if (!settings.useCustomRange) return PageRange.all(total);
    final parsed = PageRange.parse(settings.rangeText, total);
    if (parsed is Err<List<int>>) return null;
    return (parsed as Ok<List<int>>).value;
  }

  /// Thông tin tờ giấy cho `page` đang xem trước (null = ẩn hàng).
  /// Số tờ tính theo 1 bản in (không nhân số bản).
  SheetInfo? _sheetInfoForPage(DocumentItem doc, int page) {
    final total = doc.pageCount;
    if (total == null || total < 1) return null;
    final settings = _currentSettings();
    switch (settings.mode) {
      case PrintMode.singleSided:
        final selected = _selectedPages(total, settings);
        if (selected == null || !selected.contains(page)) return null;
        final idx = selected.indexOf(page) + 1;
        return (
          sheet: s.sheetLabel(idx, selected.length),
          side: s.sheetSideFront,
          spine: null,
        );
      case PrintMode.manualDuplex:
        final selected = _selectedPages(total, settings);
        if (selected == null) return null;
        final p1 = PageOrder.duplexPassPages(
          pages: selected,
          firstSide: settings.firstSide,
          firstPass: true,
        );
        final p2 = PageOrder.duplexPassPages(
          pages: selected,
          firstSide: settings.firstSide,
          firstPass: false,
          pass2Reversed: settings.pass2Reversed,
        );
        if (p1.contains(page)) {
          return (
            sheet: s.sheetLabel(p1.indexOf(page) + 1, p1.length),
            side: s.sheetSideFront,
            spine: null,
          );
        }
        if (p2.contains(page)) {
          return (
            sheet: s.sheetLabel(p2.indexOf(page) + 1, p2.length),
            side: s.sheetSideBack,
            spine: null,
          );
        }
        return null;
      case PrintMode.booklet:
        final outer = BookletImposition.outerPass(
          totalPages: total,
          spine: settings.bookletSpine,
        );
        final inner = BookletImposition.innerPass(
          totalPages: total,
          spine: settings.bookletSpine,
        );
        final spineShort = settings.bookletSpine == BookletSpine.left
            ? s.spineLeftShort
            : s.spineRightShort;
        for (var i = 0; i < outer.length; i++) {
          if (outer[i].left == page || outer[i].right == page) {
            return (
              sheet: s.sheetLabel(i + 1, outer.length),
              side: s.sheetSideOuter,
              spine: spineShort,
            );
          }
        }
        for (var i = 0; i < inner.length; i++) {
          if (inner[i].left == page || inner[i].right == page) {
            return (
              sheet: s.sheetLabel(i + 1, inner.length),
              side: s.sheetSideInner,
              spine: spineShort,
            );
          }
        }
        return null;
    }
  }

  /// Hộp kế hoạch in (chỉ chế độ 2 mặt / đóng sách, ẩn khi plan lỗi).
  Widget? _buildPlanBox(DocumentItem? doc) {
    if (doc == null || doc.printablePdfPath == null) return null;
    final settings = _currentSettings();
    if (settings.mode == PrintMode.singleSided) return null;
    final result = widget.flow.plan(document: doc, settings: settings);
    if (result is Err<PrintPlan>) return null;
    final plan = (result as Ok<PrintPlan>).value;
    final isBooklet = settings.mode == PrintMode.booklet;

    String fmtPages(List<int?> pages) {
      final shown = pages.length > 10 ? pages.take(10) : pages;
      final labels = shown.map((p) => p?.toString() ?? '—');
      final more = pages.length > 10 ? ' ${s.planMore(pages.length - 10)}' : '';
      return '${s.planPages(pages.length)} (${labels.join(', ')}$more)';
    }

    String fmtSides(List<BookletSide> sides) {
      final shown = sides.length > 4 ? sides.take(4) : sides;
      final parts = shown
          .map((side) => '[${side.left ?? '—'} | ${side.right ?? '—'}]')
          .join(', ');
      final more = sides.length > 4 ? ' ${s.planMore(sides.length - 4)}' : '';
      return '${s.planSheets(sides.length)} ($parts$more)';
    }

    final rows = isBooklet
        ? <(String, String, Color)>[
            (
              s.planPass1Booklet,
              fmtSides(plan.pass1BookletSides),
              AppColors.sky200
            ),
            (
              s.planPass2Booklet,
              fmtSides(plan.pass2BookletSides),
              AppColors.warningPale
            ),
          ]
        : <(String, String, Color)>[
            (s.planPass1, fmtPages(plan.pass1Pages), AppColors.sky200),
            (
              s.planPass2,
              fmtPages(plan.pass2Pages ?? const []),
              AppColors.warningPale
            ),
          ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isBooklet
              ? AppColors.bookletBorderInner
              : AppColors.sky800.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final label = AppSectionLabel(
                text: isBooklet ? s.planTitleBooklet : s.planTitleDuplex,
              );
              final badge = AppBadge(
                text: s.planSheets(plan.totalSheets),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                backgroundColor: AppColors.sky600,
                borderColor: AppColors.sky600,
                textColor: Colors.white,
                borderRadius: 4,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              );
              // Hẹp (< 260): xếp chồng — nhãn lên trên, badge xuống
              // dưới trong Flexible để badge co lại (ellipsis) nếu
              // vẫn chật, thay vì ép 1 hàng gây tràn phải.
              if (constraints.maxWidth >= 260) {
                return Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: AppColors.sky400,
                    ),
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
                      const Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.sky400,
                      ),
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
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 12,
                thickness: 1,
                color: AppColors.border,
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12),
                  children: [
                    TextSpan(
                      text: '${rows[i].$1}: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                    TextSpan(
                      text: rows[i].$2,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: rows[i].$3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  PrintSettings _currentSettings() {
    final copies = int.tryParse(_copiesController.text) ?? 1;
    return PrintSettings(
      printerName: _printSettings.printerName,
      mode: _printSettings.mode,
      copies: copies < 1 ? 1 : copies,
      useCustomRange: _printSettings.useCustomRange,
      rangeText: _rangeController.text,
      firstSide: _printSettings.firstSide,
      flipEdge: _printSettings.flipEdge,
      pass2Reversed: _printSettings.pass2Reversed,
      bookletSpine: _printSettings.bookletSpine,
      paperSize: _printSettings.paperSize,
      insertBlankPage: _printSettings.insertBlankPage,
    );
  }

  Future<void> _startPrint() async {
    final doc = _selected;
    if (doc == null || doc.printablePdfPath == null) return;
    if (_printSettings.printerName.isEmpty) {
      _showError(const AppError(messageKey: 'error_list_printers_failed'));
      return;
    }
    final settings = _currentSettings();
    final planResult = widget.flow.plan(document: doc, settings: settings);
    if (planResult is Err<PrintPlan>) {
      _showError(planResult.error);
      return;
    }
    final plan = (planResult as Ok<PrintPlan>).value;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.confirmPrintTitle),
        content: Text(
          s.confirmPrintBody(settings.copies, plan.totalSheets),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(s.startPrint),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    _clearStatus();
    if (settings.mode == PrintMode.singleSided) {
      setState(() => _busy = true);
      final controller = widget.flow.createController(
        document: doc,
        settings: settings,
        plan: plan,
      );
      final r = await controller.startPass1();
      if (!mounted) return;
      setState(() => _busy = false);
      if (r is Err<void>) {
        _showError(r.error);
      } else {
        setState(() => _statusKey = 'print_done');
      }
      return;
    }
    final controller = widget.flow.createController(
      document: doc,
      settings: settings,
      plan: plan,
    );
    setState(() {
      _controller = controller;
      _busy = true;
    });
    final r = await controller.startPass1();
    if (!mounted) return;
    setState(() => _busy = false);
    if (r is Err<void>) {
      _showError(r.error);
      setState(() {
        _controller = null;
      });
    } else {
      // Đang chờ người dùng lật giấy + xác nhận -> hiển thị hướng dẫn.
      setState(() {});
    }
  }

  Future<void> _confirmFlip() async {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _busy = true);
    final r = await controller.confirmFlipAndPrintPass2();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (r is Err<void>) {
        _showError(r.error);
      } else {
        _statusKey = 'print_done';
      }
      _controller = null;
    });
  }

  Future<void> _cancelPrint() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.confirmCancelTitle),
        content: Text(s.confirmCancelBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(s.cancelPrint),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    _controller?.cancel();
    setState(() {
      _controller = null;
    });
  }

  Future<void> _testPrint() async {
    final doc = _selected;
    if (doc == null || doc.printablePdfPath == null) return;
    if (_printSettings.printerName.isEmpty) return;
    setState(() => _busy = true);
    final r = await widget.flow.printTest(
      document: doc,
      settings: _currentSettings(),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (r is Err<void>) {
      _showError(r.error);
    } else {
      setState(() => _statusKey = 'print_done');
    }
  }

  Future<void> _openQueue() async {
    if (_printSettings.printerName.isEmpty) return;
    final r =
        await widget.dispatcher.openPrintQueue(_printSettings.printerName);
    if (r is Err<void>) _showError(r.error);
  }

  void _openSettings() {
    Future<bool>? wordFuture;
    Future<LibreOfficeStatus>? loFuture;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          wordFuture ??= widget.documents.wordAvailable();
          loFuture ??= widget.documents.libreOfficeStatus();
          return AlertDialog(
            title: Text(s.settingsTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.languageLabel),
                  RadioGroup<String>(
                    groupValue: widget.settings.locale.languageCode,
                    onChanged: (v) async {
                      if (v != null) {
                        await widget.settings.setLocale(Locale(v));
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<String>(
                          title: Text(s.langVi),
                          value: 'vi',
                        ),
                        RadioListTile<String>(
                          title: Text(s.langEn),
                          value: 'en',
                        ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    title: Text(s.loggingLabel),
                    value: widget.settings.loggingEnabled,
                    onChanged: (v) async {
                      await widget.settings.setLoggingEnabled(v);
                      if (mounted) setState(() {});
                    },
                  ),
                  const Divider(),
                  Text(
                    s.wordStatusLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FutureBuilder<bool>(
                    future: wordFuture,
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const LinearProgressIndicator();
                      }
                      final found = snap.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            found ? s.wordFound : s.wordNotFound,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  found ? AppColors.success : AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () => setDialogState(() {
                              wordFuture = widget.documents.wordAvailable();
                            }),
                            child: Text(s.libreOfficeRescan),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.libreOfficeStatusLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FutureBuilder<LibreOfficeStatus>(
                    future: loFuture,
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const LinearProgressIndicator();
                      }
                      final st = snap.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            st.found
                                ? s.libreOfficeFoundAt(st.path ?? '')
                                : s.libreOfficeNotFound,
                            style: TextStyle(
                              fontSize: 12,
                              color: st.found
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () => setDialogState(() {
                              loFuture = widget.documents.libreOfficeStatus();
                            }),
                            child: Text(s.libreOfficeRescan),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(s.close),
              ),
            ],
          );
        },
      ),
    );
  }

  String _statusText(DocumentItem item) {
    switch (item.status) {
      case DocumentStatus.ready:
        return s.statusReady;
      case DocumentStatus.needsConversion:
        return s.statusNeedsConversion;
      case DocumentStatus.converting:
        return s.statusConverting;
      case DocumentStatus.error:
        return item.errorMessageKey != null
            ? s.errorFor(item.errorMessageKey!)
            : s.statusError;
    }
  }

  Color _statusColor(DocumentItem item) {
    switch (item.status) {
      case DocumentStatus.ready:
        return AppColors.success;
      case DocumentStatus.needsConversion:
        return AppColors.warning;
      case DocumentStatus.converting:
        return AppColors.sky400;
      case DocumentStatus.error:
        return AppColors.error;
    }
  }

  /// Dòng meta của thẻ tài liệu: số trang + kích thước file.
  String _docMeta(DocumentItem item) {
    final pages = '${s.pages}: ${item.pageCount ?? '—'}';
    final size = item.fileSizeBytes;
    if (size == null) return pages;
    return '$pages • ${_fileSizeLabel(size)}';
  }

  String _fileSizeLabel(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildDocTile(DocumentItem item, bool selected) {
    final items = widget.documents.items;
    final idx = items.indexWhere((e) => e.id == item.id);
    final canUp = idx > 0;
    final canDown = idx >= 0 && idx < items.length - 1;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.accentBg.withValues(alpha: 0.6)
            : AppColors.input.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.sky500 : AppColors.borderStrong,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.sky500.withValues(alpha: 0.35),
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selected = item),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Nút "Chuyển đổi": hiện khi DOCX chưa chuyển, hoặc khi
                // tự chuyển lỗi (làm nút Thử lại — không cần thêm
                // file lại). PDF lỗi không có nút này.
                final showConvert = item.format == DocumentFormat.docx &&
                    (item.status == DocumentStatus.needsConversion ||
                        item.status == DocumentStatus.error);
                // Thẻ hẹp: xếp chồng (thông tin lên trên, nút xuống dưới)
                // thay vì ép 1 hàng gây tràn. Ngưỡng bao phủ nút
                // "Chuyển đổi" ở scale chữ 1.5 + 3 nút icon (70px).
                final wide = constraints.maxWidth >= (showConvert ? 260 : 140);
                // Icon tệp 36×36 theo định dạng thật.
                final fileIcon = Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.sky500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.format == DocumentFormat.docx
                        ? Icons.description_outlined
                        : Icons.picture_as_pdf_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                );
                final infoColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            selected ? AppColors.sky200 : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _docMeta(item),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AppBadge(
                      text: _statusText(item),
                      dotColor: _statusColor(item),
                      backgroundColor:
                          _statusColor(item).withValues(alpha: 0.15),
                      borderColor: _statusColor(item).withValues(alpha: 0.4),
                      textColor: _statusColor(item),
                      fontSize: 10,
                    ),
                  ],
                );
                final convertButton = AppSkyButton(
                  onPressed: () => _convertDocx(item),
                  label: s.convert,
                );
                final actionIcons = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TileIconButton(
                      icon: Icons.keyboard_arrow_up,
                      tooltip: s.moveUp,
                      enabled: canUp,
                      onPressed: () => _moveItem(item, -1),
                    ),
                    const SizedBox(width: 2),
                    _TileIconButton(
                      icon: Icons.keyboard_arrow_down,
                      tooltip: s.moveDown,
                      enabled: canDown,
                      onPressed: () => _moveItem(item, 1),
                    ),
                    const SizedBox(width: 2),
                    _TileIconButton(
                      icon: Icons.delete_outline,
                      tooltip: s.remove,
                      enabled: true,
                      onPressed: () => _remove(item),
                    ),
                  ],
                );
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      fileIcon,
                      const SizedBox(width: 10),
                      Expanded(child: infoColumn),
                      if (showConvert)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: convertButton,
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: actionIcons,
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        fileIcon,
                        const SizedBox(width: 10),
                        Expanded(child: infoColumn),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (showConvert) Flexible(child: convertButton),
                        if (showConvert) const SizedBox(width: 8),
                        actionIcons,
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsPanel() {
    final count = widget.documents.items.length;
    return AppPanel(
      header: LayoutBuilder(
        builder: (context, constraints) {
          // Header rộng (>= 300px): 1 hàng như bản web. Header hẹp:
          // 2 hàng (tiêu đề + nút xóa) để không tràn ngang.
          final wide = constraints.maxWidth >= 300;
          final clearButton = TextButton(
            onPressed: count == 0 ? null : _clearAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 26),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.error,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    s.clearAll,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
          final titleRow = Row(
            children: [
              const Icon(
                Icons.folder_outlined,
                size: 20,
                color: AppColors.sky400,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${s.documentsTitle} ($count)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.panelTitle,
                ),
              ),
            ],
          );
          if (wide) {
            return Row(
              children: [
                Expanded(child: titleRow),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 26),
                  child: clearButton,
                ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleRow,
              const SizedBox(height: 4),
              clearButton,
            ],
          );
        },
      ),
      contentPadding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashedBorderBox(
            active: _dragging,
            child: DropTarget(
              // Thêm tuần tự (await từng file): DOCX tự chuyển đổi
              // ngay khi thả nên 2 file DOCX không chạy song song
              // 2 tiến trình soffice cùng lúc (LibreOffice khóa
              // profile khi chạy đồng thời).
              onDragDone: (details) async {
                setState(() => _dragging = false);
                for (final f in details.files) {
                  await _addOne(f.path);
                }
              },
              onDragEntered: (_) => setState(() => _dragging = true),
              onDragExited: (_) => setState(() => _dragging = false),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.sky500.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppColors.sky500.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.file_upload_outlined,
                      size: 20,
                      color: AppColors.sky400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.dropHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.dropSupport,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppSkyButton(
                    onPressed: _addFiles,
                    label: s.addFiles,
                    icon: Icons.add,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: widget.documents.items.isEmpty
                ? Center(
                    child: Text(
                      s.noDocuments,
                      style: AppText.bodySmall,
                    ),
                  )
                : ListView.separated(
                    itemCount: widget.documents.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final item = widget.documents.items[i];
                      final selected = _selected?.id == item.id;
                      return _buildDocTile(item, selected);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewPanel(DocumentItem? doc) {
    return Container(
      decoration: panelDecoration(),
      child: DocumentPreview(
        pdfPath: doc?.printablePdfPath,
        fileName: doc?.fileName,
        strings: s,
        onPageChanged: (_) {},
        sheetInfoForPage:
            doc == null ? null : (page) => _sheetInfoForPage(doc, page),
      ),
    );
  }

  Widget _buildPrintPanel(DocumentItem? doc, bool awaitingFlip) {
    final isDone = _statusKey == 'print_done';
    final ready =
        doc?.printablePdfPath != null && _printSettings.printerName.isNotEmpty;
    final planBox = _buildPlanBox(doc);
    return AppPanel(
      header: Row(
        children: [
          const Icon(
            Icons.print_outlined,
            size: 20,
            color: AppColors.sky400,
          ),
          const SizedBox(width: 8),
          // Tiêu đề + badge đều co lại (ellipsis) thay vì ép đủ
          // chữ gây tràn phải khi panel hẹp: "Cấu hình in ấn" +
          // "Sẵn sàng hoạt động" vượt quá chiều rộng panel ở cửa
          // sổ ~600–800px. Không dùng Spacer vì nó tranh chỗ
          // với 2 Flexible và làm badge bị ép nhỏ hơn.
          Flexible(
            child: Text(
              s.printSettings,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.panelTitle,
            ),
          ),
          if (ready)
            Flexible(
              child: AppBadge(
                text: s.readyStatus,
                dotColor: AppColors.success,
                backgroundColor: AppColors.successBg.withValues(alpha: 0.6),
                borderColor: AppColors.successBorder.withValues(alpha: 0.6),
                textColor: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_busy) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
          ],
          AppPrimaryButton(
            onPressed:
                (doc?.printablePdfPath == null || _busy) ? null : _startPrint,
            label: _busy ? s.printingPass1 : s.startPrint,
            icon: Icons.play_arrow,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // (1) Máy in: Wrap để khi panel hẹp, link "Làm mới"
            // xuống dòng thay vì tràn ngang (lỗi RIGHT OVERFLOWED).
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppFieldLabel(
                  icon: Icons.print_outlined,
                  text: s.printerLabel,
                ),
                TextButton(
                  onPressed: _refreshPrinters,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.sky300,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Nhãn co lại + ellipsis: nút không bao giờ rộng hơn
                  // dòng của Wrap, tránh tràn ngang ở panel hẹp.
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
              initialValue: _printSettings.printerName.isEmpty
                  ? null
                  : _printSettings.printerName,
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
              items: _printers
                  .map(
                    (p) => DropdownMenuItem(
                      value: p.name,
                      child: Text(
                        p.isDefault
                            ? '${p.name} (${s.printerDefault})'
                            : p.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _printSettings.printerName = v);
                }
              },
            ),
            if (_printers.isEmpty)
              Text(
                s.noPrinters,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.warning,
                ),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.paperTrayLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.sky300,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.paperNote,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _openQueue,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.sky300,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Nhãn co lại + ellipsis để không tràn ở panel hẹp.
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.list_alt_outlined, size: 14),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        s.openQueue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // (2) Chế độ in: 3 thẻ trong 1 hàng, cao theo nội dung
            // (IntrinsicHeight: không còn chiều cao cố định gây tràn).
            AppSectionLabel(text: s.printModeLabel),
            const SizedBox(height: 8),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: AppOptionCard(
                      selected: _printSettings.mode == PrintMode.manualDuplex,
                      onTap: () => setState(
                        () => _printSettings.mode = PrintMode.manualDuplex,
                      ),
                      icon: Icons.menu_book_outlined,
                      title: s.modeDuplex,
                      description: s.modeDuplexDesc,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppOptionCard(
                      selected: _printSettings.mode == PrintMode.booklet,
                      onTap: () => setState(
                        () => _printSettings.mode = PrintMode.booklet,
                      ),
                      icon: Icons.bookmark_outline,
                      title: s.modeBooklet,
                      description: s.modeBookletDesc,
                      padding: const EdgeInsets.all(8),
                      titleWeight: FontWeight.w700,
                      unselectedTitleColor: AppColors.bookletAccentSoft,
                      unselectedIconColor: AppColors.bookletAccent,
                      selectedBorderColor: AppColors.bookletBorderSelected,
                      unselectedBorderColor: AppColors.bookletBorderUnselected,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppOptionCard(
                      selected: _printSettings.mode == PrintMode.singleSided,
                      onTap: () => setState(
                        () => _printSettings.mode = PrintMode.singleSided,
                      ),
                      icon: Icons.description_outlined,
                      title: s.modeSingle,
                      description: s.modeSingleDesc,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ),
            if (_printSettings.mode == PrintMode.booklet)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: AppInfoBox(
                  borderColor: AppColors.bookletBorderOuter,
                  child: Text(
                    s.bookletNote,
                    style: AppText.bodySmall,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // (3) Số bản in + Khổ giấy: lưới 2 cột. Khổ giấy là cài
            // đặt thật — quyết định khổ trang file PDF từng lượt in
            // và khổ giấy app yêu cầu driver dùng cho lệnh in.
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
                      TextField(
                        controller: _copiesController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                        decoration: const InputDecoration(
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
                        initialValue: _printSettings.paperSize,
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
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _printSettings.paperSize = v);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // (4) Phạm vi in: 2 thẻ radio trên một hàng.
            AppSectionLabel(text: s.pageRangeLabel),
            const SizedBox(height: 8),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: AppOptionCard(
                      selected: !_printSettings.useCustomRange,
                      onTap: () => setState(
                        () => _printSettings.useCustomRange = false,
                      ),
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
                      selected: _printSettings.useCustomRange,
                      onTap: () => setState(
                        () => _printSettings.useCustomRange = true,
                      ),
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
            if (_printSettings.useCustomRange)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: _rangeController,
                  decoration: InputDecoration(hintText: s.pageRangeHint),
                ),
              ),
            // (5) Hộp thiết lập lật hai mặt (chỉ chế độ 2 mặt).
            if (_printSettings.mode == PrintMode.manualDuplex) ...[
              const SizedBox(height: 16),
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
                    // 2 thẻ lật: cao theo nội dung (IntrinsicHeight).
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: AppOptionCard(
                              selected:
                                  _printSettings.flipEdge == FlipEdge.longEdge,
                              onTap: () => setState(
                                () =>
                                    _printSettings.flipEdge = FlipEdge.longEdge,
                              ),
                              icon: Icons.book_outlined,
                              title: s.flipLong,
                              description: s.flipLongDesc,
                              padding: const EdgeInsets.all(8),
                              iconSize: 14,
                              showRadioDot: false,
                              borderRadius: 8,
                              iconInlineWithTitle: true,
                              selectedColor:
                                  AppColors.accentBgSoft.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppOptionCard(
                              selected:
                                  _printSettings.flipEdge == FlipEdge.shortEdge,
                              onTap: () => setState(
                                () => _printSettings.flipEdge =
                                    FlipEdge.shortEdge,
                              ),
                              icon: Icons.calendar_today_outlined,
                              title: s.flipShort,
                              description: s.flipShortDesc,
                              padding: const EdgeInsets.all(8),
                              iconSize: 14,
                              showRadioDot: false,
                              borderRadius: 8,
                              iconInlineWithTitle: true,
                              selectedColor:
                                  AppColors.accentBgSoft.withValues(alpha: 0.4),
                              unselectedIconColor: AppColors.warning,
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
                      initialValue: _printSettings.firstSide,
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
                          child: Text(
                            s.oddFirst,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DropdownMenuItem(
                          value: FirstSide.evenFirst,
                          child: Text(
                            s.evenFirst,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _printSettings.firstSide = v!),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    _WebCheckbox(
                      value: _printSettings.pass2Reversed,
                      onChanged: (v) => setState(
                        () => _printSettings.pass2Reversed = v,
                      ),
                      label: s.pass2ReverseCheck,
                    ),
                    const SizedBox(height: 8),
                    _WebCheckbox(
                      value: _printSettings.insertBlankPage,
                      onChanged: (v) => setState(
                        () => _printSettings.insertBlankPage = v,
                      ),
                      label: s.insertBlankCheck,
                    ),
                  ],
                ),
              ),
            ],
            // Gáy sách (chỉ chế độ đóng sách).
            if (_printSettings.mode == PrintMode.booklet) ...[
              const SizedBox(height: 12),
              AppFieldLabel(
                icon: Icons.book_outlined,
                text: s.spineLabel,
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<BookletSpine>(
                isExpanded: true,
                initialValue: _printSettings.bookletSpine,
                dropdownColor: AppColors.input,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.bookletBorderOuter,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.bookletBorderOuter,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.bookletBorderOuter,
                    ),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: BookletSpine.left,
                    child: Text(
                      s.spineLeft,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  DropdownMenuItem(
                    value: BookletSpine.right,
                    child: Text(
                      s.spineRight,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
                onChanged: (v) => setState(
                  () => _printSettings.bookletSpine = v!,
                ),
              ),
            ],
            // (6) Hộp kế hoạch in (2 mặt / đóng sách).
            if (planBox != null) ...[
              const SizedBox(height: 16),
              planBox,
            ],
            if (_statusKey != null) ...[
              const SizedBox(height: 12),
              AppInfoBox(
                backgroundColor: isDone ? AppColors.successBg : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDone ? s.printDone : s.errorFor(_statusKey!),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDone ? AppColors.success : AppColors.error,
                      ),
                    ),
                    if (_rawMessage != null) ...[
                      const SizedBox(height: 4),
                      SelectableText(
                        _rawMessage!,
                        style: AppText.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (awaitingFlip) ...[
              const SizedBox(height: 16),
              FlipGuide(
                strings: s,
                flipEdge: _printSettings.flipEdge,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _busy ? null : _confirmFlip,
                child: Text(s.confirmFlip),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy ? null : _cancelPrint,
                child: Text(s.cancelPrint),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doc = _selected;
    final awaitingFlip = _controller?.state == DuplexState.awaitingFlipConfirm;
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            AppHeader(
              title: s.appTitle,
              subtitle: s.appSubtitle,
              actions: [
                AppHeaderButton(
                  onPressed: (doc?.printablePdfPath == null || _busy)
                      ? null
                      : _testPrint,
                  label: s.testPrint,
                  icon: Icons.science_outlined,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                AppHeaderButton(
                  onPressed: _openGuides,
                  label: s.guidesTitle,
                  icon: Icons.warning_amber_outlined,
                  color: AppColors.error,
                ),
                const SizedBox(width: 6),
                AppHeaderButton(
                  onPressed: _openSettings,
                  label: widget.settings.locale.languageCode == 'vi'
                      ? s.langVi
                      : s.langEn,
                  icon: Icons.language_outlined,
                  color: AppColors.sky400,
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1920),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildDocumentsPanel(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 5,
                          child: _buildPreviewPanel(doc),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: _buildPrintPanel(doc, awaitingFlip),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AppFooter(infoText: s.footerInfo),
          ],
        ),
      ),
    );
  }

  /// Phím tắt của cửa sổ chính: Ctrl+P = in (như nút "Bắt đầu in").
  /// Chỉ kích hoạt khi cửa sổ chính có focus — khi dialog mở, focus nằm
  /// trong dialog nên phím tắt không xuyên qua dialog. Esc đóng dialog
  /// đang mở do Flutter tự xử lý qua showDialog, không cần code thêm.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final isCtrlP = event.logicalKey == LogicalKeyboardKey.keyP &&
        HardwareKeyboard.instance.isControlPressed;
    if (!isCtrlP) return KeyEventResult.ignored;
    final doc = _selected;
    if (_busy || doc?.printablePdfPath == null) {
      return KeyEventResult.ignored;
    }
    _startPrint();
    return KeyEventResult.handled;
  }
}

/// Checkbox kiểu web trong hộp lật hai mặt: ô vuông 14px, viền
/// slate-700, khi tick nền sky-500 + dấu tick trắng, nhãn 12px
/// slate-300. Cả hàng đều bấm được (toàn bộ tile là InkWell).
class _WebCheckbox extends StatelessWidget {
  const _WebCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: value ? AppColors.sky500 : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: value ? AppColors.sky500 : AppColors.borderStrong,
                    width: 1.5,
                  ),
                ),
                child: value
                    ? const Icon(
                        Icons.check,
                        size: 10,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary2,
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

class _TileIconButton extends StatelessWidget {
  const _TileIconButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 22,
        height: 22,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(6),
            child: Icon(
              icon,
              size: 14,
              color: enabled ? AppColors.textSecondary2 : AppColors.textFaint,
            ),
          ),
        ),
      ),
    );
  }
}
