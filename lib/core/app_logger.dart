import 'dart:io';

/// Logger kỹ thuật.
///
/// NGUYÊN TẮC BẮT BUỘC: log CHỈ ghi thông tin kỹ thuật (tên thao tác, số
/// trang, mã lỗi). Không bao giờ ghi nội dung tài liệu, tên tệp, đường
/// dẫn tệp hay dữ liệu cá nhân. Người dùng có thể tắt hoặc xóa log.
class AppLogger {
  AppLogger({required this.enabled});

  bool enabled;
  File? _file;

  Future<void> init(Directory directory) async {
    try {
      _file = File('${directory.path}/nkd_smart_printer.log');
    } catch (_) {
      _file = null;
    }
  }

  Future<void> log(String event, {Map<String, Object>? fields}) async {
    if (!enabled || _file == null) return;
    try {
      final safeFields =
          (fields ?? {}).entries.map((e) => '${e.key}=${e.value}').join(' ');
      final line = '${DateTime.now().toIso8601String()} [$event] $safeFields\n';
      await _file!.writeAsString(line, mode: FileMode.append);
    } catch (_) {
      // Ghi log thất bại không được làm gián đoạn luồng chính.
    }
  }

  Future<void> clear() async {
    try {
      if (await _file!.exists()) await _file!.delete();
    } catch (_) {
      // Bỏ qua: xóa log thất bại không phải lỗi nghiêm trọng.
    }
  }
}
