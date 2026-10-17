# NKD Smart Printer

App Windows giúp máy in chỉ in 1 mặt in được **2 mặt thủ công**, kèm **in đóng sách**
(saddle-stitch), xem trước đúng nội dung gốc, hướng dẫn nạp/lật giấy và xử lý kẹt giấy.
Chạy offline, không đăng nhập, không tải tài liệu lên mạng.

> **Lưu ý trung thực về phạm vi đã kiểm chứng:** code được viết và kiểm thử trên máy
> Linux (VM phát triển). `flutter analyze` sạch, 34 unit/integration test đều pass
> (gồm chuyển đổi DOCX → PDF thật qua Word / LibreOffice). **Chưa có bản build `.exe`
> Windows và chưa thử in trên máy in thật** — cần làm theo mục “Kiểm thử trên
> máy in thật” bên dưới trên máy Windows trước khi dùng cho tài liệu quan trọng.

## Yêu cầu môi trường

- Windows 10 / 11, 64-bit.
- [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) (bản stable;
  dự án này dùng Flutter 3.47.7 / Dart 3.13.5) + Visual Studio 2022 kèm workload
  “Desktop development with C++”.
- **Microsoft Word hoặc LibreOffice** (bắt buộc một trong hai nếu muốn mở file
  DOCX): app chuyển DOCX → PDF chạy offline trên máy, ưu tiên **Word** nếu máy
  đã có (dùng chính Word render, không cần cài thêm gì), nếu không có Word thì
  dùng **LibreOffice**. App tự tìm LibreOffice theo thứ tự: bản portable trong
  thư mục `libreoffice/` cạnh file `.exe` → `soffice` trong PATH → bản cài đặt
  chuẩn (Program Files). Nếu chưa có cái nào, khi thêm file DOCX app hiện hộp
  thoại hướng dẫn tải bản Portable — xem mục “Chuyển đổi DOCX (Word / LibreOffice)”.
  File DOCX không tự dùng dịch vụ trực tuyến nào.
- Máy in bất kỳ đã cài driver trên Windows (app in qua Windows Print Spooler,
  không gửi lệnh trực tiếp tới máy in).

## Chạy / build

```powershell
flutter pub get
flutter run -d windows        # chạy bản debug trên Windows
flutter build windows --release
```

Bản release nằm ở `build\windows\x64\runner\Release\`
(`NKD_Smart_Printer.exe` kèm các DLL Flutter — copy cả thư mục khi mang sang
máy khác, hoặc đóng gói bằng MSIX/Inno Setup nếu cần trình cài đặt).
Icon của file `.exe` và logo trong header đều là ảnh NKD
(`assets/app_logo.png` / `windows/runner/resources/app_icon.ico`).

Kiểm tra code:

```powershell
flutter analyze
flutter test
```

## Cách dùng

Giao diện tối (dark theme): header, 3 cột Tài liệu | Xem trước | Cài đặt in,
footer mỏng. Nút in chính nằm cố định ở đáy cột Cài đặt in.

1. Kéo thả (hoặc bấm **Thêm tài liệu**) file PDF / DOCX. DOCX được **tự động**
   chuyển sang PDF bằng LibreOffice ngay khi tải lên rồi mới xem trước/in — xem
   trước và in dùng cùng một bản PDF đã chuyển đổi nên khớp nhau. Nếu máy chưa
   có LibreOffice, app hiện hộp thoại hướng dẫn cài một lần; cài xong bấm
   "Đã cài / Quét lại" là file tự chuyển ngay, không cần thêm lại. Nút
   **Chuyển đổi** trên thẻ tài liệu chỉ còn làm nút thử lại khi tự chuyển lỗi.
2. Xem trước ở cột giữa: chuyển trang bằng nút hoặc cuộn, phóng to/thu nhỏ bằng
   pinch/trackpad.
3. Chọn máy in, chế độ in:
   - **In 1 mặt** — in thường.
   - **In 2 mặt thủ công** — in lượt 1 (lẻ/chẵn tùy chọn), app hiện sơ đồ nạp/lật
     giấy theo cạnh lật đã chọn, bấm **Xác nhận đã lật giấy** rồi mới in lượt 2.
     Tùy chọn “thứ tự lượt 2” để đảo thứ tự nếu máy in của bạn nạp giấy ngược.
   - **In đóng sách** — 2 trang/1 mặt A4 ngang, gập giữa thành A5. App tự làm tròn
     tổng số trang lên bội số 4 và chèn trang trắng. Hỗ trợ gáy trái (chuẩn VN/EN)
     và gáy phải (Manga).
4. Có thể giới hạn phạm vi trang (`1-3,5,8-10`) và số bản in.
5. Nút **In thử** in 1 trang để kiểm tra hướng giấy trước khi in cả xấp.
6. Nút **Mở hàng đợi in** mở cửa sổ hàng đợi của Windows để theo dõi/hủy lệnh in.

## Chuyển đổi DOCX (Word / LibreOffice)

DOCX không lưu sẵn bố cục trang hoàn chỉnh nên app phải render qua một bộ máy
dàn trang để chuyển sang PDF rồi mới xem trước/in — xem trước và in dùng cùng
một bản PDF đã chuyển đổi nên khớp nhau. Thứ tự ưu tiên: **Microsoft Word**
(nếu máy có — dùng chính Word render qua Word COM, mở file chỉ đọc, không
tắt Word đang mở của người dùng) → **LibreOffice** (dự phòng, miễn phí).
Word chuyển lỗi thì app tự thử LibreOffice.

**App tìm LibreOffice theo thứ tự:**
1. Bản portable trong thư mục `libreoffice/` ngay cạnh file `.exe` của app
   (ví dụ: `NKD Smart Printer\libreoffice\program\soffice.exe`).
2. Lệnh `soffice` trong PATH.
3. Bản cài đặt chuẩn trong `Program Files` / `Program Files (x86)` /
   `LOCALAPPDATA`.

**Cài đặt một lần (nếu máy chưa có Word lẫn LibreOffice):**
1. Thêm file DOCX — app hiện hộp thoại hướng dẫn, bấm **Sao chép liên kết tải**
   rồi dán vào trình duyệt để tải **LibreOffice Portable** từ trang chính thức
   (libreoffice.org/download/portable-versions).
2. Giải nén bản Portable vào thư mục `libreoffice/` cạnh file `.exe` của app
   (hoặc cài bản LibreOffice thường).
3. Bấm **Đã cài / Quét lại** trong hộp thoại. Có thể kiểm tra lại bất cứ lúc nào
   trong **Cài đặt** (nút ngôn ngữ trên header) — mục Word và LibreOffice hiển
   thị đã tìm thấy hay chưa.

Sau khi có Word hoặc LibreOffice, mọi chuyển đổi đều chạy **offline** trên máy.
App **không** tự tải file cài LibreOffice (~300MB) trong lúc build/chạy.

## Giới hạn định dạng

- **PDF**: mở bằng Pdfium. PDF đặt mật khẩu chưa được hỗ trợ (mở sẽ báo lỗi).
- **DOCX**: bắt buộc chuyển đổi qua Word hoặc LibreOffice. Độ trung thực của bố
  cục phụ thuộc vào khả năng render của engine dùng để chuyển — với tài liệu
  dùng font/phức tạp (ví dụ: font không có trên máy, macro, đối tượng nhúng lạ),
  nên **in thử 1 trang** để đối chiếu với file gốc trong Word trước khi in cả xấp.
- App không bao giờ ghi nội dung tài liệu hay dữ liệu cá nhân vào log; log chỉ
  chứa thông tin kỹ thuật (mã lỗi, tên thao tác).

## Kiểm thử trên máy in thật (bắt buộc trước khi dùng chính thức)

1. **In thử 1 trang** trên giấy nháp: kiểm tra khổ giấy, lề, hướng trang có khớp
   file gốc không.
2. **In 2 mặt thủ công, 4 trang**: in lượt 1 (lẻ), làm đúng theo sơ đồ lật giấy,
   xác nhận, in lượt 2. Kiểm tra thứ tự trang và mặt trước/sau có đúng không. Nếu
   bị ngược, đổi tùy chọn cạnh lật / thứ tự lượt 2 rồi thử lại.
3. **In đóng sách, 8 trang**: in 2 lượt, gập giữa, kiểm tra thứ tự trang theo
   đúng thứ tự sách (1..8) và vạch gấp ở giữa.
4. **Kẹt giấy**: nếu kẹt, làm theo hướng dẫn trong app — tắt máy in, kéo giấy
   theo chiều giấy chạy, không giật ngược; không tháo linh kiện máy.

## Cấu trúc code

- `lib/core/` — `Result`, `AppError`, logger (không log nội dung tài liệu).
- `lib/features/documents/` — quản lý tài liệu, chuyển đổi DOCX (Word → LibreOffice).
- `lib/features/preview/` — xem trước PDF (pdfx/Pdfium).
- `lib/features/printing/` — tính thứ tự trang, sắp xếp đóng sách, máy trạng thái
  2 lượt in, tạo PDF từng lượt, phát lệnh in qua spooler.
- `lib/features/guides/` — sơ đồ lật giấy, hướng dẫn kẹt giấy, in thử.
- `lib/features/settings/` — ngôn ngữ (VI/EN), bật/tắt log.
- `lib/localization/` — toàn bộ chuỗi VI + EN.
- `test/` — unit test (thứ tự trang, phạm vi trang, đóng sách, máy trạng thái)
  + kiểm thử tích hợp DOCX → PDF (bỏ qua nếu máy chưa có engine chuyển đổi).
#   N K D S m a r t P r i n t e r  
 #   N K D S m a r t P r i n t e r  
 