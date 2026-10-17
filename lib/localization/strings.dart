import 'package:flutter/widgets.dart';

/// Chuỗi bản địa hóa tiếng Việt / tiếng Anh.
///
/// Tất cả nút, nhãn, thông báo lỗi, hướng dẫn và hộp thoại do ứng dụng
/// tạo ra đều lấy từ đây. Tên máy in và thông báo gốc từ Windows KHÔNG
/// qua file này — hiển thị nguyên văn.
class S {
  S(this.locale);

  final Locale locale;

  bool get isVi => locale.languageCode == 'vi';

  String _get(String key) => _strings[key]?[isVi ? 'vi' : 'en'] ?? key;

  // App
  String get appTitle => _get('app_title');
  String get appSubtitle => _get('app_subtitle');
  String get footerInfo => _get('footer_info');
  String get documentsTitle => _get('documents_title');
  String get addFiles => _get('add_files');
  String get dropHint => _get('drop_hint');
  String get dropSupport => _get('drop_support');
  String get noDocuments => _get('no_documents');
  String get fileName => _get('file_name');
  String get pages => _get('pages');
  String get status => _get('status');
  String get remove => _get('remove');
  String get clearAll => _get('clear_all');
  String get moveUp => _get('move_up');
  String get moveDown => _get('move_down');
  String get convert => _get('convert');
  String get statusReady => _get('status_ready');
  String get statusNeedsConversion => _get('status_needs_conversion');
  String get statusConverting => _get('status_converting');
  String get statusError => _get('status_error');

  // Preview
  String get previewTitle => _get('preview_title');
  String get previewUnavailable => _get('preview_unavailable');
  String get previewRealContent => _get('preview_real_content');
  String pageOf(int current, int total) =>
      _get('page_of').replaceAll('{c}', '$current').replaceAll('{t}', '$total');
  String get zoomIn => _get('zoom_in');
  String get zoomOut => _get('zoom_out');
  String get prevPage => _get('prev_page');
  String get nextPage => _get('next_page');
  String sheetLabel(int a, int b) =>
      _get('sheet_label').replaceAll('{a}', '$a').replaceAll('{b}', '$b');
  String sheetSpine(String s) => _get('sheet_spine').replaceAll('{s}', s);
  String get sheetSideFront => _get('sheet_side_front');
  String get sheetSideBack => _get('sheet_side_back');
  String get sheetSideOuter => _get('sheet_side_outer');
  String get sheetSideInner => _get('sheet_side_inner');
  String get spineLeftShort => _get('spine_left_short');
  String get spineRightShort => _get('spine_right_short');

  // Printer
  String get printerLabel => _get('printer_label');
  String get printerDefault => _get('printer_default');
  String get refreshPrinters => _get('refresh_printers');
  String get noPrinters => _get('no_printers');
  String get paperNote => _get('paper_note');
  String get paperTrayLabel => _get('paper_tray_label');
  String get openQueue => _get('open_queue');

  // Print settings
  String get printSettings => _get('print_settings');
  String get pageRangeLabel => _get('page_range_label');
  String get pageRangeAll => _get('page_range_all');
  String get pageRangeCustom => _get('page_range_custom');
  String get pageRangeHint => _get('page_range_hint');
  String get copiesLabel => _get('copies_label');
  String get paperSizeLabel => _get('paper_size_label');
  String get paperSizeA4 => _get('paper_size_a4');
  String get paperSizeLetter => _get('paper_size_letter');
  String get paperSizeA3 => _get('paper_size_a3');
  String get paperSizeLegal => _get('paper_size_legal');
  String get printModeLabel => _get('print_mode_label');
  String get modeSingle => _get('mode_single');
  String get modeDuplex => _get('mode_duplex');
  String get modeBooklet => _get('mode_booklet');
  String get modeSingleDesc => _get('mode_single_desc');
  String get modeDuplexDesc => _get('mode_duplex_desc');
  String get modeBookletDesc => _get('mode_booklet_desc');
  String get firstSideLabel => _get('first_side_label');
  String get oddFirst => _get('odd_first');
  String get evenFirst => _get('even_first');
  String get flipEdgeLabel => _get('flip_edge_label');
  String get flipLong => _get('flip_long');
  String get flipShort => _get('flip_short');
  String get flipLongDesc => _get('flip_long_desc');
  String get flipShortDesc => _get('flip_short_desc');
  String get pass2OrderLabel => _get('pass2_order_label');
  String get pass2Same => _get('pass2_same');
  String get pass2Reversed => _get('pass2_reversed');
  String get pass2ReverseCheck => _get('pass2_reverse_check');
  String get insertBlankCheck => _get('insert_blank_check');
  String get duplexSettingsTitle => _get('duplex_settings_title');
  String get spineLabel => _get('spine_label');
  String get spineLeft => _get('spine_left');
  String get spineRight => _get('spine_right');
  String get bookletNote => _get('booklet_note');
  String get planTitleDuplex => _get('plan_title_duplex');
  String get planTitleBooklet => _get('plan_title_booklet');
  String get planPass1 => _get('plan_pass1');
  String get planPass2 => _get('plan_pass2');
  String get planPass1Booklet => _get('plan_pass1_booklet');
  String get planPass2Booklet => _get('plan_pass2_booklet');
  String planPages(int n) => _get('plan_pages').replaceAll('{n}', '$n');
  String planSheets(int n) => _get('plan_sheets').replaceAll('{n}', '$n');
  String planMore(int n) => _get('plan_more').replaceAll('{n}', '$n');
  String get readyStatus => _get('ready_status');

  // Actions
  String get startPrint => _get('start_print');
  String get printingPass1 => _get('printing_pass1');
  String get printingPass2 => _get('printing_pass2');
  String get confirmFlip => _get('confirm_flip');
  String get cancel => _get('cancel');
  String get cancelPrint => _get('cancel_print');
  String get testPrint => _get('test_print');
  String get printDone => _get('print_done');
  String get close => _get('close');
  String get ok => _get('ok');

  // Guides
  String get flipGuideTitle => _get('flip_guide_title');
  String flipGuideStep(int n) => _get('flip_guide_step$n');

  // Troubleshooting & paper-jam guide (dialog riêng, không gộp in thử).
  String get troubleshootTitle => _get('troubleshoot_title');
  String get troubleshootJamTitle => _get('troubleshoot_jam_title');
  String troubleshootJamCellTitle(int n) =>
      _get('troubleshoot_jam_cell${n}_title');
  String troubleshootJamCellDesc(int n) =>
      _get('troubleshoot_jam_cell${n}_desc');
  String get troubleshootQueueTitle => _get('troubleshoot_queue_title');
  String get troubleshootQueueDesc => _get('troubleshoot_queue_desc');
  String get troubleshootCmd1Label => _get('troubleshoot_cmd1_label');
  String get troubleshootCmd2Label => _get('troubleshoot_cmd2_label');
  String get troubleshootCopy => _get('troubleshoot_copy');
  String get troubleshootCopied => _get('troubleshoot_copied');
  String get troubleshootErrorsTitle => _get('troubleshoot_errors_title');
  String get troubleshootErrorsLabel => _get('troubleshoot_errors_label');
  String troubleshootErrorCode(int n) => _get('troubleshoot_error${n}_code');
  String troubleshootErrorDesc(int n) => _get('troubleshoot_error${n}_desc');

  // Dialogs
  String get confirmRemoveTitle => _get('confirm_remove_title');
  String get confirmRemoveBody => _get('confirm_remove_body');
  String get confirmClearAllTitle => _get('confirm_clear_all_title');
  String get confirmClearAllBody => _get('confirm_clear_all_body');
  String get confirmCancelTitle => _get('confirm_cancel_title');
  String get confirmCancelBody => _get('confirm_cancel_body');
  String get confirmPrintTitle => _get('confirm_print_title');
  String confirmPrintBody(int copies, int sheets) => _get('confirm_print_body')
      .replaceAll('{copies}', '$copies')
      .replaceAll('{sheets}', '$sheets');

  // Settings
  String get settingsTitle => _get('settings_title');
  String get languageLabel => _get('language_label');
  String get langVi => _get('lang_vi');
  String get langEn => _get('lang_en');
  String get loggingLabel => _get('logging_label');
  String get clearLog => _get('clear_log');
  String get guidesTitle => _get('guides_title');

  // LibreOffice (chuyển đổi DOCX)
  String get libreOfficeTitle => _get('libre_office_title');
  String get libreOfficeBody => _get('libre_office_body');
  String get libreOfficeCopyLink => _get('libre_office_copy_link');
  String get libreOfficeLinkCopied => _get('libre_office_link_copied');
  String get libreOfficeRescan => _get('libre_office_rescan');
  String get libreOfficeStillMissing => _get('libre_office_still_missing');
  String get libreOfficeStatusLabel => _get('libre_office_status_label');
  String get libreOfficeNotFound => _get('libre_office_not_found');
  String get wordStatusLabel => _get('word_status_label');
  String get wordFound => _get('word_found');
  String get wordNotFound => _get('word_not_found');
  String libreOfficeFoundAt(String path) =>
      _get('libre_office_found_at').replaceAll('{path}', path);

  // Errors (messageKey -> text)
  String errorFor(String key) => _get(key);
}

const Map<String, Map<String, String>> _strings = {
  'app_title': {
    'vi': 'NKD Smart Printer',
    'en': 'NKD Smart Printer',
  },
  'app_subtitle': {
    'vi': 'In hai mặt thủ công cho máy in một mặt',
    'en': 'Manual duplex printing for single-sided printers',
  },
  'footer_info': {
    'vi':
        '100% Hoạt động Offline & Bảo mật · Windows Print Spooler Architecture · Shortcuts: Ctrl+P (Print) | Esc (Close)',
    'en':
        '100% Offline & Secure · Windows Print Spooler Architecture · Shortcuts: Ctrl+P (Print) | Esc (Close)',
  },
  'documents_title': {
    'vi': 'Tài liệu',
    'en': 'Documents',
  },
  'add_files': {
    'vi': 'Thêm tệp',
    'en': 'Add files',
  },
  'drop_hint': {
    'vi': 'Kéo thả tệp PDF/DOCX vào đây hoặc bấm “Thêm tệp”.',
    'en': 'Drag & drop PDF/DOCX files here or click “Add files”.',
  },
  'drop_support': {
    'vi': 'Hỗ trợ PDF và DOCX. Tài liệu không được tải lên mạng.',
    'en': 'Supports PDF and DOCX. Documents are never uploaded.',
  },
  'no_documents': {
    'vi': 'Chưa có tài liệu nào.',
    'en': 'No documents yet.',
  },
  'file_name': {
    'vi': 'Tên tệp',
    'en': 'File name',
  },
  'pages': {
    'vi': 'Số trang',
    'en': 'Pages',
  },
  'status': {
    'vi': 'Trạng thái',
    'en': 'Status',
  },
  'remove': {
    'vi': 'Xóa',
    'en': 'Remove',
  },
  'clear_all': {
    'vi': 'Xóa toàn bộ danh sách',
    'en': 'Clear all',
  },
  'move_up': {
    'vi': 'Di chuyển lên',
    'en': 'Move up',
  },
  'move_down': {
    'vi': 'Di chuyển xuống',
    'en': 'Move down',
  },
  'convert': {
    'vi': 'Chuyển đổi',
    'en': 'Convert',
  },
  'status_ready': {
    'vi': 'Sẵn sàng',
    'en': 'Ready',
  },
  'status_needs_conversion': {
    'vi': 'Cần chuyển đổi (LibreOffice)',
    'en': 'Needs conversion (LibreOffice)',
  },
  'status_converting': {
    'vi': 'Đang chuyển đổi…',
    'en': 'Converting…',
  },
  'status_error': {
    'vi': 'Lỗi',
    'en': 'Error',
  },
  'preview_title': {
    'vi': 'Xem trước',
    'en': 'Preview',
  },
  'preview_unavailable': {
    'vi':
        'Chưa có tài liệu để xem trước. Hãy thêm tệp PDF hoặc chuyển đổi DOCX trước.',
    'en': 'Nothing to preview. Add a PDF file or convert a DOCX file first.',
  },
  'preview_real_content': {
    'vi': 'Nội dung PDF thật',
    'en': 'True PDF content',
  },
  'page_of': {
    'vi': 'Trang {c}/{t}',
    'en': 'Page {c} of {t}',
  },
  'zoom_in': {
    'vi': 'Phóng to',
    'en': 'Zoom in',
  },
  'zoom_out': {
    'vi': 'Thu nhỏ',
    'en': 'Zoom out',
  },
  'prev_page': {
    'vi': 'Trang trước',
    'en': 'Previous page',
  },
  'next_page': {
    'vi': 'Trang sau',
    'en': 'Next page',
  },
  'sheet_label': {
    'vi': 'Tờ giấy vật lý: {a} / {b}',
    'en': 'Physical sheet: {a} / {b}',
  },
  'sheet_spine': {
    'vi': 'Gáy đóng cuốn: {s}',
    'en': 'Booklet spine: {s}',
  },
  'sheet_side_front': {
    'vi': 'Mặt trước (Lượt 1)',
    'en': 'Front side (Pass 1)',
  },
  'sheet_side_back': {
    'vi': 'Mặt sau (Lượt 2)',
    'en': 'Back side (Pass 2)',
  },
  'sheet_side_outer': {
    'vi': 'Mặt ngoài (Lượt 1)',
    'en': 'Outer side (Pass 1)',
  },
  'sheet_side_inner': {
    'vi': 'Mặt trong (Lượt 2)',
    'en': 'Inner side (Pass 2)',
  },
  'spine_left_short': {
    'vi': 'Trái',
    'en': 'Left',
  },
  'spine_right_short': {
    'vi': 'Phải',
    'en': 'Right',
  },
  'printer_label': {
    'vi': 'Máy in',
    'en': 'Printer',
  },
  'printer_default': {
    'vi': 'Mặc định',
    'en': 'Default',
  },
  'refresh_printers': {
    'vi': 'Làm mới danh sách máy in',
    'en': 'Refresh printer list',
  },
  'no_printers': {
    'vi': 'Không tìm thấy máy in nào. Kiểm tra kết nối máy in.',
    'en': 'No printers found. Check the printer connection.',
  },
  'paper_note': {
    'vi':
        'Khổ giấy: trang in được đặt theo khổ giấy đã chọn. Nạp đúng khổ giấy vào khay trước khi in.',
    'en':
        'Paper size: printed pages are sized to the selected paper. Load the matching paper size in the tray before printing.',
  },
  'paper_tray_label': {
    'vi': 'Đặc tính khay giấy:',
    'en': 'Tray characteristics:',
  },
  'open_queue': {
    'vi': 'Mở hàng đợi in',
    'en': 'Open print queue',
  },
  'print_settings': {
    'vi': 'Cấu hình in ấn',
    'en': 'Print configuration',
  },
  'page_range_label': {
    'vi': 'Phạm vi trang',
    'en': 'Page range',
  },
  'page_range_all': {
    'vi': 'Tất cả các trang',
    'en': 'All pages',
  },
  'page_range_custom': {
    'vi': 'Trang tùy chọn (vd: 1-5, 8, 11-14)',
    'en': 'Custom pages (e.g. 1-5, 8, 11-14)',
  },
  'page_range_hint': {
    'vi': 'VD: 1-3,5,8-10',
    'en': 'E.g. 1-3,5,8-10',
  },
  'copies_label': {
    'vi': 'Số bản in',
    'en': 'Copies',
  },
  'paper_size_label': {
    'vi': 'Khổ giấy',
    'en': 'Paper size',
  },
  'paper_size_a4': {
    'vi': 'A4 (210 x 297 mm)',
    'en': 'A4 (210 x 297 mm)',
  },
  'paper_size_letter': {
    'vi': 'Letter',
    'en': 'Letter',
  },
  'paper_size_a3': {
    'vi': 'A3',
    'en': 'A3',
  },
  'paper_size_legal': {
    'vi': 'Legal',
    'en': 'Legal',
  },
  'print_mode_label': {
    'vi': 'Chế độ in',
    'en': 'Print mode',
  },
  'mode_single': {
    'vi': 'Một mặt (Simplex)',
    'en': '1-Sided (Simplex)',
  },
  'mode_duplex': {
    'vi': '2 Mặt (Duplex)',
    'en': '2-Sided (Duplex)',
  },
  'mode_booklet': {
    'vi': 'Đóng sách (Booklet)',
    'en': 'Booklet',
  },
  'mode_single_desc': {
    'vi': 'In chuẩn từng trang',
    'en': 'Standard one-sided printing',
  },
  'mode_duplex_desc': {
    'vi': 'In đảo 2 mặt trang đơn',
    'en': 'Flip and print both sides, one page per side',
  },
  'mode_booklet_desc': {
    'vi': 'In 2 trang/mặt gấp đôi',
    'en': '2 pages per side, folded in half',
  },
  'first_side_label': {
    'vi': 'Thứ tự lượt in',
    'en': 'Print order',
  },
  'odd_first': {
    'vi': 'In trang lẻ trước (1, 3, 5...) - Khuyên dùng',
    'en': 'Odd pages first (1, 3, 5...) – Recommended',
  },
  'even_first': {
    'vi': 'In trang chẵn trước (2, 4, 6...)',
    'en': 'Even pages first (2, 4, 6...)',
  },
  'flip_edge_label': {
    'vi': 'Hướng lật giấy khi in mặt sau',
    'en': 'Flip edge for the back side',
  },
  'flip_long': {
    'vi': 'Lật cạnh dài (Dạng sách / Báo cáo)',
    'en': 'Flip on long edge (Book / Report)',
  },
  'flip_short': {
    'vi': 'Lật cạnh ngắn (Dạng lịch / Sổ tay)',
    'en': 'Flip on short edge (Calendar / Notebook)',
  },
  'flip_long_desc': {
    'vi':
        'Lật lề trái sang phải hoặc từ phải sang trái. Phù hợp tài liệu khổ dọc.',
    'en': 'Flip left to right or right to left. Best for portrait documents.',
  },
  'flip_short_desc': {
    'vi':
        'Lật từ dưới lên trên. Phù hợp tài liệu xoay ngang hoặc hóa đơn gáy trên.',
    'en':
        'Flip bottom to top. Best for landscape documents or top-bound invoices.',
  },
  'pass2_order_label': {
    'vi': 'Thứ tự lượt 2',
    'en': 'Pass 2 order',
  },
  'pass2_same': {
    'vi': 'Cùng chiều lượt 1',
    'en': 'Same order as pass 1',
  },
  'pass2_reversed': {
    'vi': 'Ngược chiều lượt 1',
    'en': 'Reverse of pass 1',
  },
  'pass2_reverse_check': {
    'vi': 'Đảo ngược thứ tự trang Lượt 2',
    'en': 'Reverse pass 2 page order',
  },
  'insert_blank_check': {
    'vi': 'Tự động chêm 1 trang trắng nếu tổng số trang là số lẻ',
    'en': 'Auto-insert a blank page when the total page count is odd',
  },
  'duplex_settings_title': {
    'vi': 'Thiết lập lật hai mặt',
    'en': 'Duplex flip settings',
  },
  'spine_label': {
    'vi': 'Gáy sách',
    'en': 'Book spine',
  },
  'spine_left': {
    'vi': 'Gáy trái (tiếng Việt/tiếng Anh)',
    'en': 'Left spine (Vietnamese/English)',
  },
  'spine_right': {
    'vi': 'Gáy phải (Manga)',
    'en': 'Right spine (Manga)',
  },
  'booklet_note': {
    'vi':
        'Đóng sách: 2 trang trên 1 mặt giấy A4 nằm ngang, gập giữa thành sách A5. Số trang tự động làm tròn lên bội số của 4, trang thiếu chèn trang trắng.',
    'en':
        'Booklet: 2 pages per A4 landscape side, folded in the middle into an A5 book. Page count is rounded up to a multiple of 4; missing pages become blank pages.',
  },
  'plan_title_duplex': {
    'vi': 'Kế hoạch in hai mặt',
    'en': 'Duplex print plan',
  },
  'plan_title_booklet': {
    'vi': 'Kế hoạch in đóng sách',
    'en': 'Booklet print plan',
  },
  'plan_pass1': {
    'vi': 'Lượt 1 (In mặt trước)',
    'en': 'Pass 1 (front)',
  },
  'plan_pass2': {
    'vi': 'Lượt 2 (In mặt sau)',
    'en': 'Pass 2 (back)',
  },
  'plan_pass1_booklet': {
    'vi': 'Lượt 1 (Mặt ngoài)',
    'en': 'Pass 1 (outer)',
  },
  'plan_pass2_booklet': {
    'vi': 'Lượt 2 (Mặt trong)',
    'en': 'Pass 2 (inner)',
  },
  'plan_pages': {
    'vi': '{n} trang',
    'en': '{n} pages',
  },
  'plan_sheets': {
    'vi': '{n} tờ giấy',
    'en': '{n} sheets',
  },
  'plan_more': {
    'vi': '… (+{n})',
    'en': '… (+{n})',
  },
  'ready_status': {
    'vi': 'Sẵn sàng hoạt động',
    'en': 'Ready',
  },
  'start_print': {
    'vi': 'Bắt đầu in',
    'en': 'Start printing',
  },
  'printing_pass1': {
    'vi': 'Đang in lượt 1…',
    'en': 'Printing pass 1…',
  },
  'printing_pass2': {
    'vi': 'Đang in lượt 2…',
    'en': 'Printing pass 2…',
  },
  'confirm_flip': {
    'vi': 'Đã nạp lại giấy đúng hướng — In lượt 2',
    'en': 'Paper reloaded correctly — Print pass 2',
  },
  'cancel': {
    'vi': 'Hủy',
    'en': 'Cancel',
  },
  'cancel_print': {
    'vi': 'Hủy lệnh in',
    'en': 'Cancel print job',
  },
  'test_print': {
    'vi': 'In thử 2 trang',
    'en': 'Print a 2-page test',
  },
  'print_done': {
    'vi': 'In xong.',
    'en': 'Printing finished.',
  },
  'close': {
    'vi': 'Đóng',
    'en': 'Close',
  },
  'ok': {
    'vi': 'Đồng ý',
    'en': 'OK',
  },
  'flip_guide_title': {
    'vi': 'Hướng dẫn lật giấy',
    'en': 'Paper flip guide',
  },
  'flip_guide_step1': {
    'vi': '1. In xong lượt 1, chờ giấy ra hết rồi mới lấy giấy.',
    'en': '1. After pass 1 finishes, wait until all paper has come out.',
  },
  'flip_guide_step2': {
    'vi': '2. Giữ nguyên thứ tự xấp giấy, không đảo tờ.',
    'en': '2. Keep the stack order; do not shuffle the sheets.',
  },
  'flip_guide_step3': {
    'vi':
        '3. Lật cả xấp giấy theo cạnh đã chọn (cạnh dài/cạnh ngắn), mặt đã in hướng xuống khay giấy.',
    'en':
        '3. Flip the whole stack along the selected edge (long/short), printed side facing the tray.',
  },
  'flip_guide_step4': {
    'vi': '4. Nạp lại xấp giấy vào khay, bấm xác nhận để in lượt 2.',
    'en': '4. Reload the stack into the tray, then confirm to print pass 2.',
  },
  'troubleshoot_title': {
    'vi': 'Xử lý sự cố & Kẹt giấy an toàn',
    'en': 'Troubleshooting & Safe Paper-Jam Handling',
  },
  'troubleshoot_jam_title': {
    'vi': 'Xử lý kẹt giấy an toàn',
    'en': 'Safe paper-jam handling',
  },
  'troubleshoot_jam_cell1_title': {
    'vi': 'Dừng lệnh in ngay',
    'en': 'Stop the print job immediately',
  },
  'troubleshoot_jam_cell1_desc': {
    'vi': 'Hủy lệnh in trong hàng đợi Windows để máy không tiếp tục kéo giấy.',
    'en':
        'Cancel the job in the Windows print queue so the printer stops pulling paper.',
  },
  'troubleshoot_jam_cell2_title': {
    'vi': 'Chờ bộ sấy nguội',
    'en': 'Let the fuser cool down',
  },
  'troubleshoot_jam_cell2_desc': {
    'vi': 'Đừng chạm vào bên trong máy ngay — bộ sấy còn rất nóng sau khi in.',
    'en':
        'Do not reach inside right away — the fuser stays very hot after printing.',
  },
  'troubleshoot_jam_cell3_title': {
    'vi': 'Rút giấy nhẹ nhàng',
    'en': 'Pull the paper out gently',
  },
  'troubleshoot_jam_cell3_desc': {
    'vi':
        'Dùng hai tay rút giấy theo chiều giấy chạy, không giật chéo hay giật mạnh.',
    'en':
        'Use both hands and pull along the paper path — never yank at an angle.',
  },
  'troubleshoot_jam_cell4_title': {
    'vi': 'Không dùng vật nhọn',
    'en': 'No sharp metal objects',
  },
  'troubleshoot_jam_cell4_desc': {
    'vi':
        'Không dùng dao, kéo hay kẹp kim loại để móc giấy — dễ làm hỏng trục và cảm biến.',
    'en':
        'Never pick paper out with a knife, scissors or metal tweezers — they damage rollers and sensors.',
  },
  'troubleshoot_jam_cell5_title': {
    'vi': 'Kiểm tra giấy vụn',
    'en': 'Check for leftover scraps',
  },
  'troubleshoot_jam_cell5_desc': {
    'vi':
        'Soi đèn pin vào khay và đường giấy để tìm mẩu giấy rách còn sót lại.',
    'en':
        'Shine a flashlight into the tray and paper path to find torn scraps left behind.',
  },
  'troubleshoot_jam_cell6_title': {
    'vi': 'Đóng nắp & in thử',
    'en': 'Close the cover & test',
  },
  'troubleshoot_jam_cell6_desc': {
    'vi': 'Đóng nắp, khởi động lại máy rồi in một trang thử để kiểm tra.',
    'en':
        'Close the cover, restart the printer, then print a test page to verify.',
  },
  'troubleshoot_queue_title': {
    'vi': 'Công cụ hàng đợi in của Windows',
    'en': 'Windows print-queue tools',
  },
  'troubleshoot_queue_desc': {
    'vi':
        'Mở hàng đợi in để hủy lệnh bị kẹt, hoặc khởi động lại dịch vụ Print Spooler khi hàng đợi bị treo.',
    'en':
        'Open the print queue to cancel a stuck job, or restart the Print Spooler service when the queue is frozen.',
  },
  'troubleshoot_cmd1_label': {
    'vi': 'Mở cửa sổ máy in',
    'en': 'Open the printers window',
  },
  'troubleshoot_cmd2_label': {
    'vi': 'Khởi động lại Print Spooler (CMD, chạy với quyền quản trị)',
    'en': 'Restart Print Spooler (admin CMD)',
  },
  'troubleshoot_copy': {
    'vi': 'Sao chép',
    'en': 'Copy',
  },
  'troubleshoot_copied': {
    'vi': 'Đã sao chép',
    'en': 'Copied',
  },
  'troubleshoot_errors_title': {
    'vi': 'Tra cứu mã lỗi',
    'en': 'Error-code lookup',
  },
  'troubleshoot_errors_label': {
    'vi': 'Mã lỗi thường gặp',
    'en': 'Common error codes',
  },
  'troubleshoot_error1_code': {
    'vi': 'Kẹt giấy',
    'en': 'Paper jam',
  },
  'troubleshoot_error1_desc': {
    'vi': 'Giấy kẹt ở khay nạp hoặc bộ sấy. Làm theo 6 bước ở Phần 1.',
    'en':
        'Paper stuck at the pickup tray or fuser. Follow the 6 steps in Part 1.',
  },
  'troubleshoot_error2_code': {
    'vi': 'Spooler đã dừng',
    'en': 'Spooler stopped',
  },
  'troubleshoot_error2_desc': {
    'vi':
        'Dịch vụ Print Spooler của Windows đã dừng — hàng đợi in bị treo. Chạy lại bằng lệnh ở Phần 2.',
    'en':
        'The Windows Print Spooler service has stopped, freezing the queue. Restart it with the commands in Part 2.',
  },
  'troubleshoot_error3_code': {
    'vi': 'Ngoại tuyến / Tạm dừng',
    'en': 'Offline / Paused',
  },
  'troubleshoot_error3_desc': {
    'vi':
        'Cáp USB lỏng hoặc driver đang ở chế độ tạm dừng. Cắm chặt cáp và bỏ tạm dừng trong hàng đợi in.',
    'en':
        'Loose USB cable, or the driver is in paused mode. Reseat the cable and unpause the printer in the queue.',
  },
  'confirm_remove_title': {
    'vi': 'Xóa tài liệu?',
    'en': 'Remove document?',
  },
  'confirm_remove_body': {
    'vi': 'Tài liệu sẽ bị xóa khỏi danh sách. File gốc trên máy không bị xóa.',
    'en':
        'The document will be removed from the list. The original file on disk is not deleted.',
  },
  'confirm_clear_all_title': {
    'vi': 'Xóa toàn bộ danh sách?',
    'en': 'Clear all documents?',
  },
  'confirm_clear_all_body': {
    'vi':
        'Tất cả tài liệu sẽ bị xóa khỏi danh sách. File gốc trên máy không bị xóa.',
    'en':
        'All documents will be removed from the list. Original files on disk are not deleted.',
  },
  'confirm_cancel_title': {
    'vi': 'Hủy lệnh in?',
    'en': 'Cancel print job?',
  },
  'confirm_cancel_body': {
    'vi':
        'Lượt in đang chạy do Windows quản lý — app sẽ không gửi lượt còn lại. Nếu muốn dừng hẳn, hãy hủy lệnh trong hàng đợi in của Windows.',
    'en':
        'The running pass is managed by Windows — the app will not send the remaining pass. To stop it completely, cancel the job in the Windows print queue.',
  },
  'confirm_print_title': {
    'vi': 'Bắt đầu in?',
    'en': 'Start printing?',
  },
  'confirm_print_body': {
    'vi':
        'Sẽ in {copies} bản, tổng {sheets} tờ giấy. App không tự in khi mở ứng dụng hoặc khi thêm tài liệu.',
    'en':
        'This will print {copies} copie(s), {sheets} sheet(s) in total. The app never prints automatically when opened or when a document is added.',
  },
  'settings_title': {
    'vi': 'Cài đặt',
    'en': 'Settings',
  },
  'language_label': {
    'vi': 'Ngôn ngữ',
    'en': 'Language',
  },
  'lang_vi': {
    'vi': 'Tiếng Việt',
    'en': 'Vietnamese',
  },
  'lang_en': {
    'vi': 'Tiếng Anh',
    'en': 'English',
  },
  'logging_label': {
    'vi': 'Ghi log kỹ thuật (không chứa nội dung tài liệu)',
    'en': 'Technical logging (never contains document content)',
  },
  'clear_log': {
    'vi': 'Xóa log',
    'en': 'Clear log',
  },
  'guides_title': {
    'vi': 'Hướng dẫn',
    'en': 'Guides',
  },
  'libre_office_title': {
    'vi': 'Cần Word hoặc LibreOffice để mở file DOCX',
    'en': 'Word or LibreOffice is needed to open DOCX files',
  },
  'libre_office_body': {
    'vi':
        'File DOCX cần Microsoft Word hoặc LibreOffice (miễn phí) để chuyển sang PDF trước khi xem trước/in.\n\nNếu máy đã có Word thì không cần cài thêm — app tự dùng Word. Nếu chưa có Word, cài LibreOffice một lần:\n\n1. Tải LibreOffice Portable (không cần cài đặt).\n2. Giải nén vào thư mục “libreoffice” ngay cạnh file .exe của app — hoặc cài bản LibreOffice thường.\n3. Bấm “Đã cài / Quét lại” bên dưới.',
    'en':
        'DOCX files need Microsoft Word or LibreOffice (free) to convert to PDF before preview/printing.\n\nIf Word is already installed, nothing else is needed — the app uses Word automatically. If Word is not installed, set up LibreOffice once:\n\n1. Download LibreOffice Portable (no installation needed).\n2. Extract it into a “libreoffice” folder next to the app’s .exe file — or install regular LibreOffice.\n3. Press “Installed / Rescan” below.',
  },
  'libre_office_copy_link': {
    'vi': 'Sao chép liên kết tải',
    'en': 'Copy download link',
  },
  'libre_office_link_copied': {
    'vi': 'Đã sao chép liên kết. Dán vào trình duyệt để tải.',
    'en': 'Link copied. Paste it into your browser to download.',
  },
  'libre_office_rescan': {
    'vi': 'Đã cài / Quét lại',
    'en': 'Installed / Rescan',
  },
  'libre_office_still_missing': {
    'vi': 'Vẫn chưa thấy Word hay LibreOffice. Kiểm tra lại cài đặt.',
    'en': 'Neither Word nor LibreOffice was found. Check the installation.',
  },
  'word_status_label': {
    'vi': 'Microsoft Word (chuyển đổi DOCX)',
    'en': 'Microsoft Word (DOCX conversion)',
  },
  'word_found': {
    'vi': 'Đã tìm thấy — file DOCX sẽ chuyển bằng Word.',
    'en': 'Found — DOCX files will convert with Word.',
  },
  'word_not_found': {
    'vi': 'Chưa tìm thấy.',
    'en': 'Not found.',
  },
  'libre_office_status_label': {
    'vi': 'LibreOffice (chuyển đổi DOCX)',
    'en': 'LibreOffice (DOCX conversion)',
  },
  'libre_office_not_found': {
    'vi': 'Chưa tìm thấy — file DOCX chưa chuyển đổi được.',
    'en': 'Not found — DOCX files cannot be converted yet.',
  },
  'libre_office_found_at': {
    'vi': 'Đã tìm thấy: {path}',
    'en': 'Found: {path}',
  },
  // Errors
  'error_page_range_empty': {
    'vi': 'Chưa nhập phạm vi trang.',
    'en': 'Page range is empty.',
  },
  'error_document_no_pages': {
    'vi': 'Tài liệu không có trang nào.',
    'en': 'The document has no pages.',
  },
  'error_page_range_syntax': {
    'vi': 'Phạm vi trang sai cú pháp. Ví dụ đúng: 1-3,5,8-10.',
    'en': 'Invalid page range syntax. Example: 1-3,5,8-10.',
  },
  'error_page_range_out_of_bounds': {
    'vi': 'Trang nằm ngoài phạm vi của tài liệu.',
    'en': 'Page is outside the document range.',
  },
  'error_print_wrong_state': {
    'vi': 'Lệnh in không ở trạng thái phù hợp.',
    'en': 'The print job is in the wrong state.',
  },
  'error_print_pass_failed': {
    'vi': 'In lượt này thất bại. Kiểm tra máy in và hàng đợi in.',
    'en': 'This pass failed to print. Check the printer and print queue.',
  },
  'error_docx_needs_converter': {
    'vi':
        'File DOCX cần Microsoft Word hoặc LibreOffice để chuyển đổi sang PDF. Hãy cài một trong hai (LibreOffice miễn phí) rồi thử lại. Tài liệu không được tải lên mạng.',
    'en':
        'DOCX files need Microsoft Word or LibreOffice to convert to PDF. Please install one of them (LibreOffice is free) and try again. Documents are never uploaded.',
  },
  'error_word_unavailable': {
    'vi': 'Microsoft Word không có trên máy này.',
    'en': 'Microsoft Word is not available on this machine.',
  },
  'error_docx_convert_failed': {
    'vi': 'Chuyển đổi DOCX thất bại. Kiểm tra file có bị hỏng không.',
    'en': 'DOCX conversion failed. Check whether the file is damaged.',
  },
  'error_format_unsupported': {
    'vi': 'Định dạng chưa được hỗ trợ. App hỗ trợ PDF và DOCX.',
    'en': 'Format not supported. The app supports PDF and DOCX.',
  },
  'error_file_not_found': {
    'vi': 'Không tìm thấy file. File có thể đã bị di chuyển/xóa.',
    'en': 'File not found. It may have been moved or deleted.',
  },
  'error_pdf_unreadable': {
    'vi': 'Không đọc được file PDF. File có thể bị hỏng hoặc có mật khẩu.',
    'en': 'Cannot read the PDF file. It may be damaged or password-protected.',
  },
  'error_render_page_failed': {
    'vi': 'Không render được trang. Thử lại hoặc kiểm tra file.',
    'en': 'Could not render the page. Retry or check the file.',
  },
  'error_build_pass_pdf_failed': {
    'vi': 'Không tạo được file in cho lượt này.',
    'en': 'Could not build the print file for this pass.',
  },
  'error_list_printers_failed': {
    'vi': 'Không lấy được danh sách máy in.',
    'en': 'Could not list printers.',
  },
  'error_print_rejected': {
    'vi': 'Máy in từ chối lệnh in. Kiểm tra trạng thái máy in.',
    'en': 'The printer rejected the print job. Check the printer status.',
  },
  'error_windows_only': {
    'vi': 'Chức năng này chỉ hỗ trợ trên Windows.',
    'en': 'This feature is only supported on Windows.',
  },
  'error_open_queue_failed': {
    'vi': 'Không mở được hàng đợi in. Mở thủ công: Settings > Printers.',
    'en':
        'Could not open the print queue. Open it manually: Settings > Printers.',
  },
  'error_unknown': {
    'vi': 'Đã xảy ra lỗi không xác định.',
    'en': 'An unknown error occurred.',
  },
};
