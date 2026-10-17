import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/app_error.dart';
import '../../../core/result.dart';

/// Chuyển DOCX → PDF bằng Microsoft Word có sẵn trên máy.
///
/// Dùng Word COM automation qua PowerShell (`Word.Application`): mở
/// file ở chế độ chỉ đọc, xuất PDF, đóng file. Không gửi tài liệu lên
/// mạng, không cần cài thêm gì nếu máy đã có Word.
///
/// An toàn với Word đang mở của người dùng: nếu Word đã chạy trước
/// khi chuyển, app KHÔNG gọi `Quit()` (chỉ đóng file vừa mở); chỉ
/// `Quit()` khi chính app là người khởi động Word.
class WordConverter {
  WordConverter({this.timeout = const Duration(minutes: 2)});

  final Duration timeout;

  /// Word có đăng ký COM trên máy không. Chỉ kiểm tra ProgID
  /// `Word.Application`, KHÔNG khởi động Word.
  Future<bool> get isAvailable async {
    if (!Platform.isWindows) return false;
    try {
      final result = await Process.run(
        'powershell',
        const [
          '-NoProfile',
          '-NonInteractive',
          '-Command',
          "if ([Type]::GetTypeFromProgID('Word.Application')) { exit 0 } else { exit 1 }",
        ],
      ).timeout(const Duration(seconds: 15));
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Chuyển [docxPath] sang PDF trong [outputDir]. Trả về đường dẫn
  /// PDF, hoặc lỗi. File PDF đích được ghi đè nếu đã tồn tại.
  Future<Result<String>> convertToPdf({
    required String docxPath,
    required Directory outputDir,
  }) async {
    if (!Platform.isWindows) {
      return Err(
        const AppError(messageKey: 'error_word_unavailable'),
      );
    }
    final stem = p.basenameWithoutExtension(docxPath);
    final pdf = File(p.join(outputDir.path, '$stem.pdf'));
    final scriptDir =
        await Directory.systemTemp.createTemp('nkd_word_convert_');
    try {
      await outputDir.create(recursive: true);
      final script = File(p.join(scriptDir.path, 'convert.ps1'));
      await script.writeAsString(_script);
      final proc = await Process.start(
        'powershell',
        [
          '-NoProfile',
          '-NonInteractive',
          '-ExecutionPolicy',
          'Bypass',
          '-File',
          script.path,
          '-Docx',
          docxPath,
          '-Pdf',
          pdf.path,
        ],
      );
      // Xả stdout/stderr để tiến trình không treo khi đầy bộ đệm ống.
      proc.stdout.listen((_) {});
      proc.stderr.listen((_) {});
      final exitCode = await proc.exitCode.timeout(
        timeout,
        onTimeout: () {
          proc.kill(ProcessSignal.sigkill);
          return -1;
        },
      );
      if (exitCode != 0) {
        return Err(
          AppError(
            messageKey: 'error_docx_convert_failed',
            technicalDetail: 'word exitCode=$exitCode',
          ),
        );
      }
      if (!await pdf.exists()) {
        return Err(
          const AppError(messageKey: 'error_docx_convert_failed'),
        );
      }
      return Ok(pdf.path);
    } catch (e) {
      return Err(wrapSystemError('error_docx_convert_failed', e));
    } finally {
      try {
        if (await scriptDir.exists()) {
          await scriptDir.delete(recursive: true);
        }
      } catch (_) {
        // Dọn file script tạm thất bại: không chặn luồng chính.
      }
    }
  }
}

/// Script PowerShell chuyển DOCX → PDF bằng Word COM. Đường dẫn file
/// vào/ra truyền qua tham số `-Docx` / `-Pdf` (không nhúng vào script
/// nên không lo ký tự đặc biệt trong tên file).
/// Viết bằng cú pháp Windows PowerShell 5.1 (không dùng toán tử
/// ternary `? :` — chỉ có từ PowerShell 7).
const _script = r'''
param([string]$Docx, [string]$Pdf)
$ErrorActionPreference = 'Stop'
if (Test-Path $Pdf) { Remove-Item $Pdf -Force }
$word = $null
$doc = $null
$wasRunning = $null -ne (Get-Process WINWORD -ErrorAction SilentlyContinue)
try {
  $word = New-Object -ComObject Word.Application
  $word.Visible = $false
  $word.DisplayAlerts = 0
  $doc = $word.Documents.Open($Docx, $false, $true, $false)
  $doc.ExportAsFixedFormat($Pdf, 17, $false)
  $doc.Close($false)
  $doc = $null
} finally {
  if ($null -ne $doc) { try { $doc.Close($false) } catch {} }
  if ($null -ne $word) {
    try { if (-not $wasRunning) { $word.Quit() } } catch {}
    try { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null } catch {}
  }
}
if (-not (Test-Path $Pdf)) { exit 1 }
''';
