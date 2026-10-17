import 'app_error.dart';

/// Kết quả của một thao tác: thành công mang dữ liệu, thất bại mang lỗi.
sealed class Result<T> {
  const Result();
}

class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.error);
  final AppError error;
}
