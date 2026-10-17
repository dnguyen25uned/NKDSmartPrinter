import '../../../core/app_error.dart';
import '../../../core/result.dart';

/// Máy trạng thái cho một lệnh in hai lượt.
///
/// Luồng: idle -> printingPass1 -> awaitingFlipConfirm -> printingPass2
/// -> done. Lỗi ở bất kỳ lượt nào -> error. Người dùng hủy -> cancelled.
/// [printPass] là hàm in một lượt (được truyền từ tầng UI/service) để
/// máy trạng thái này kiểm thử được mà không cần máy in thật.
enum DuplexState {
  idle,
  printingPass1,
  awaitingFlipConfirm,
  printingPass2,
  done,
  error,
  cancelled,
}

class DuplexController {
  DuplexController({required this.printPass});

  /// In một lượt. [pass] = 1 hoặc 2. Ném [AppError] khi in lỗi.
  final Future<void> Function(int pass) printPass;

  DuplexState _state = DuplexState.idle;
  AppError? _error;

  DuplexState get state => _state;
  AppError? get error => _error;

  bool get isBusy =>
      _state == DuplexState.printingPass1 ||
      _state == DuplexState.printingPass2;

  /// Bắt đầu lượt 1. Chỉ gọi được từ trạng thái idle.
  Future<Result<void>> startPass1() async {
    if (_state != DuplexState.idle) {
      return Err(
        const AppError(messageKey: 'error_print_wrong_state'),
      );
    }
    _state = DuplexState.printingPass1;
    try {
      await printPass(1);
    } on AppError catch (e) {
      _state = DuplexState.error;
      _error = e;
      return Err(e);
    } catch (e) {
      final wrapped = wrapSystemError('error_print_pass_failed', e);
      _state = DuplexState.error;
      _error = wrapped;
      return Err(wrapped);
    }
    _state = DuplexState.awaitingFlipConfirm;
    return const Ok(null);
  }

  /// Người dùng xác nhận đã nạp lại giấy đúng hướng -> in lượt 2.
  /// Chỉ gọi được từ trạng thái awaitingFlipConfirm.
  Future<Result<void>> confirmFlipAndPrintPass2() async {
    if (_state != DuplexState.awaitingFlipConfirm) {
      return Err(
        const AppError(messageKey: 'error_print_wrong_state'),
      );
    }
    _state = DuplexState.printingPass2;
    try {
      await printPass(2);
    } on AppError catch (e) {
      _state = DuplexState.error;
      _error = e;
      return Err(e);
    } catch (e) {
      final wrapped = wrapSystemError('error_print_pass_failed', e);
      _state = DuplexState.error;
      _error = wrapped;
      return Err(wrapped);
    }
    _state = DuplexState.done;
    return const Ok(null);
  }

  /// Hủy lệnh in. Chỉ có ý nghĩa khi đang chờ xác nhận lật giấy
  /// (lượt in đang chạy do driver/spooler quản lý — xem README).
  Result<void> cancel() {
    if (_state != DuplexState.awaitingFlipConfirm) {
      return Err(
        const AppError(messageKey: 'error_print_wrong_state'),
      );
    }
    _state = DuplexState.cancelled;
    return const Ok(null);
  }

  void reset() {
    _state = DuplexState.idle;
    _error = null;
  }
}
