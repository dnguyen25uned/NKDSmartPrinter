import 'package:flutter_test/flutter_test.dart';
import 'package:nkd_smart_printer/core/app_error.dart';
import 'package:nkd_smart_printer/core/result.dart';
import 'package:nkd_smart_printer/features/printing/services/duplex_controller.dart';

void main() {
  group('DuplexController', () {
    test('luồng đủ: lượt 1 -> chờ xác nhận -> lượt 2 -> xong', () async {
      final printed = <int>[];
      final c = DuplexController(
        printPass: (pass) async {
          printed.add(pass);
        },
      );
      expect(c.state, DuplexState.idle);

      final r1 = await c.startPass1();
      expect(r1, isA<Ok<void>>());
      expect(c.state, DuplexState.awaitingFlipConfirm);
      expect(printed, [1]);

      final r2 = await c.confirmFlipAndPrintPass2();
      expect(r2, isA<Ok<void>>());
      expect(c.state, DuplexState.done);
      expect(printed, [1, 2]);
    });

    test('không xác nhận lượt 2 khi chưa in lượt 1', () async {
      final c = DuplexController(printPass: (_) async {});
      final r = await c.confirmFlipAndPrintPass2();
      expect(r, isA<Err<void>>());
      expect(c.state, DuplexState.idle);
    });

    test('không in lượt 1 hai lần', () async {
      final c = DuplexController(printPass: (_) async {});
      await c.startPass1();
      final r = await c.startPass1();
      expect(r, isA<Err<void>>());
      expect(c.state, DuplexState.awaitingFlipConfirm);
    });

    test('hủy khi đang chờ xác nhận', () async {
      final c = DuplexController(printPass: (_) async {});
      await c.startPass1();
      final r = c.cancel();
      expect(r, isA<Ok<void>>());
      expect(c.state, DuplexState.cancelled);
    });

    test('hủy khi đang idle -> lỗi trạng thái', () {
      final c = DuplexController(printPass: (_) async {});
      final r = c.cancel();
      expect(r, isA<Err<void>>());
    });

    test('lượt 1 lỗi -> trạng thái error, giữ lỗi', () async {
      const failure = AppError(messageKey: 'error_print_pass_failed');
      final c = DuplexController(
        printPass: (_) async => throw failure,
      );
      final r = await c.startPass1();
      expect(r, isA<Err<void>>());
      expect(c.state, DuplexState.error);
      expect(c.error, same(failure));
    });

    test('lượt 2 lỗi -> trạng thái error', () async {
      var calls = 0;
      final c = DuplexController(
        printPass: (_) async {
          calls++;
          if (calls == 2) {
            throw const AppError(messageKey: 'error_print_pass_failed');
          }
        },
      );
      await c.startPass1();
      final r = await c.confirmFlipAndPrintPass2();
      expect(r, isA<Err<void>>());
      expect(c.state, DuplexState.error);
    });

    test('reset về idle', () async {
      final c = DuplexController(printPass: (_) async {});
      await c.startPass1();
      c.reset();
      expect(c.state, DuplexState.idle);
      expect(c.error, isNull);
    });
  });
}
