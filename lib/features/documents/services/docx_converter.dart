import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/app_error.dart';
import '../../../core/result.dart';
import 'word_converter.dart';

/// Engine chuyển DOCX → PDF.
enum DocxEngine {
  /// Microsoft Word (ưu tiên nếu máy có).
  word,

  /// LibreOffice (dự phòng).
  libreOffice,

  /// Không có engine nào.
  none,
}

/// Trang tải LibreOffice Portable chính thức (không tải nhị phân
/// trong lúc build — app chỉ mở hướng dẫn tới trang này).
const libreOfficePortableUrl =
    'https://www.libreoffice.org/download/portable-versions/';

/// Kết quả tìm LibreOffice trên máy.
class LibreOfficeStatus {
  const LibreOfficeStatus({
    required this.found,
    this.path,
    required this.source,
  });

  /// true nếu tìm thấy `soffice` dùng được.
  final bool found;

  /// Đường dẫn đầy đủ tới `soffice` (null khi không tìm thấy).
  final String? path;

  /// Nguồn tìm thấy: 'portable' (thư mục libreoffice/ cạnh app),
  /// 'path' (trong PATH), 'installed' (bản cài đặt chuẩn),
  /// 'none' (không tìm thấy).
  final String source;
}

/// Chuyển đổi DOCX sang PDF (chạy offline, trên máy).
///
/// DOCX không lưu sẵn số trang hay bố cục trang hoàn chỉnh — để xem
/// trước và in đúng 100% như file gốc, bắt buộc phải render qua một
/// bộ máy bố cục. Thứ tự ưu tiên: Microsoft Word (nếu máy có, dùng
/// chính Word render) → LibreOffice (miễn phí, dự phòng). Nếu máy
/// chưa có engine nào, trả về lỗi rõ ràng và KHÔNG tự ý dùng dịch vụ
/// chuyển đổi trực tuyến (tài liệu không được tải lên mạng).
class DocxConverter {
  DocxConverter({
    this.timeout = const Duration(minutes: 2),
    this.appDirectory,
    this.includeSystemSearch = true,
    WordConverter? wordConverter,
  }) : _word = wordConverter ?? WordConverter(timeout: timeout);

  final Duration timeout;

  /// Thư mục chứa file .exe của app (để tìm bản portable). Mặc định lấy
  /// từ `Platform.resolvedExecutable`; truyền tay trong test để kiểm
  /// thử việc tìm bản portable mà không phụ thuộc máy chạy test.
  final String? appDirectory;

  /// false = chỉ tìm bản portable cạnh app, bỏ qua PATH + bản cài đặt
  /// (dùng trong test để kết quả không phụ thuộc máy chạy test).
  final bool includeSystemSearch;

  /// Engine Word (ưu tiên). Truyền tay trong test để giả lập Word
  /// mà không phụ thuộc máy chạy test.
  final WordConverter _word;

  /// Word có sẵn trên máy không.
  Future<bool> get wordAvailable => _word.isAvailable;

  /// Engine nào dùng được, theo thứ tự ưu tiên: Word → LibreOffice.
  Future<DocxEngine> availableEngine() async {
    if (await _word.isAvailable) return DocxEngine.word;
    if ((await locate()).found) return DocxEngine.libreOffice;
    return DocxEngine.none;
  }

  String get _exeDir =>
      appDirectory ?? File(Platform.resolvedExecutable).parent.path;

  String get _sofficeName => Platform.isWindows ? 'soffice.exe' : 'soffice';

  /// Tìm LibreOffice theo thứ tự ưu tiên:
  /// 1. Bản portable trong thư mục `libreoffice/` cạnh file .exe của app
  ///    (hoặc trong thư mục làm việc hiện tại — tiện khi chạy debug).
  /// 2. `soffice` trong PATH.
  /// 3. Bản cài đặt chuẩn trên Windows (Program Files / LOCALAPPDATA).
  Future<LibreOfficeStatus> locate() async {
    // (1) Bản portable cạnh app.
    for (final root in [_exeDir, Directory.current.path]) {
      for (final rel in [
        p.join('libreoffice', 'program', _sofficeName),
        p.join('libreoffice', _sofficeName),
      ]) {
        final candidate = File(p.join(root, rel));
        if (await candidate.exists()) {
          return LibreOfficeStatus(
            found: true,
            path: candidate.path,
            source: 'portable',
          );
        }
      }
    }
    if (!includeSystemSearch) {
      return const LibreOfficeStatus(found: false, source: 'none');
    }
    // (2) Trong PATH.
    try {
      final which = await Process.run(
        Platform.isWindows ? 'where' : 'which',
        <String>['soffice'],
      );
      if (which.exitCode == 0 && (which.stdout as String).trim().isNotEmpty) {
        return LibreOfficeStatus(
          found: true,
          path: (which.stdout as String).trim().split('\n').first.trim(),
          source: 'path',
        );
      }
    } catch (_) {
      // Rơi xuống kiểm tra vị trí mặc định bên dưới.
    }
    // (3) Bản cài đặt chuẩn trên Windows.
    if (Platform.isWindows) {
      final env = Platform.environment;
      final roots = <String>{
        if (env['ProgramFiles'] != null) env['ProgramFiles']!,
        if (env['ProgramFiles(x86)'] != null) env['ProgramFiles(x86)']!,
        if (env['LOCALAPPDATA'] != null) env['LOCALAPPDATA']!,
        r'C:\Program Files',
        r'C:\Program Files (x86)',
      };
      for (final root in roots) {
        final candidate = File(
          p.join(root, 'LibreOffice', 'program', 'soffice.exe'),
        );
        if (await candidate.exists()) {
          return LibreOfficeStatus(
            found: true,
            path: candidate.path,
            source: 'installed',
          );
        }
      }
    }
    return const LibreOfficeStatus(found: false, source: 'none');
  }

  /// Kiểm tra có engine chuyển đổi nào dùng được không (Word hoặc
  /// LibreOffice).
  Future<bool> get isAvailable async =>
      (await availableEngine()) != DocxEngine.none;

  Future<String?> _findSoffice() async => (await locate()).path;

  /// Chuyển đổi [docxPath] sang PDF trong [outputDir]. Trả về đường dẫn
  /// PDF, hoặc lỗi (không có engine / hết thời gian / lỗi convert).
  /// File PDF đích được ghi đè nếu đã tồn tại.
  /// Thứ tự: Word (nếu máy có) → LibreOffice. Word chuyển lỗi thì thử
  /// LibreOffice; cả 2 đều lỗi mới báo lỗi.
  Future<Result<String>> convertToPdf({
    required String docxPath,
    required Directory outputDir,
  }) async {
    if (await _word.isAvailable) {
      final wordResult = await _word.convertToPdf(
        docxPath: docxPath,
        outputDir: outputDir,
      );
      if (wordResult is Ok<String>) return wordResult;
      // Word có nhưng chuyển lỗi: thử LibreOffice bên dưới.
    }
    final soffice = await _findSoffice();
    if (soffice == null) {
      return Err(
        const AppError(messageKey: 'error_docx_needs_converter'),
      );
    }
    return _convertWithLibreOffice(
      soffice: soffice,
      docxPath: docxPath,
      outputDir: outputDir,
    );
  }

  /// Chuyển bằng LibreOffice (engine dự phòng). [soffice] đã tìm trước.
  Future<Result<String>> _convertWithLibreOffice({
    required String soffice,
    required String docxPath,
    required Directory outputDir,
  }) async {
    try {
      final proc = await Process.start(
        soffice,
        <String>[
          '--headless',
          '--norestore',
          '--convert-to',
          'pdf',
          '--outdir',
          outputDir.path,
          docxPath,
        ],
      );
      final exitCode = await proc.exitCode.timeout(timeout, onTimeout: () {
        proc.kill(ProcessSignal.sigkill);
        return -1;
      });
      if (exitCode != 0) {
        return Err(
          AppError(
            messageKey: 'error_docx_convert_failed',
            technicalDetail: 'soffice exitCode=$exitCode',
          ),
        );
      }
      final baseName = docxPath.split(Platform.pathSeparator).last;
      final stem =
          baseName.replaceFirst(RegExp(r'\.docx$', caseSensitive: false), '');
      final pdf = File('${outputDir.path}/$stem.pdf');
      if (!await pdf.exists()) {
        return Err(
          const AppError(messageKey: 'error_docx_convert_failed'),
        );
      }
      return Ok(pdf.path);
    } on AppError {
      rethrow;
    } catch (e) {
      return Err(wrapSystemError('error_docx_convert_failed', e));
    }
  }
}
