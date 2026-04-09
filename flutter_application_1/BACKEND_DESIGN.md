# Thiết Kế Backend - Sudoku App

## Ngày: 9/4/2026

### Những gì đã hoàn thành hôm nay:

1. **Sửa lỗi import gói `http`**:
   - Lỗi ban đầu: "Target of URI doesn't exist: 'package:http/http.dart'."
   - Nguyên nhân: Gói `http` chưa được thêm vào `pubspec.yaml`.
   - Giải pháp: Thêm `http: ^1.2.1` vào phần `dependencies` trong `pubspec.yaml`.
   - Chạy `flutter pub get` để cài đặt gói.
   - Kết quả: Import `package:http/http.dart` giờ hoạt động, cho phép sử dụng các hàm HTTP như `http.get()` trong `api_service.dart`.

2. **Cập nhật `pubspec.yaml`**:
   - Thêm dependency `http` để hỗ trợ API calls.
   - Đảm bảo dự án có thể thực hiện các yêu cầu HTTP cho backend (ví dụ: giao tiếp với API Sudoku).

### Tiến độ tổng thể:
- Backend đang được thiết kế để xử lý logic game Sudoku, bao gồm API service cho việc tải dữ liệu, lưu lịch sử, v.v.
- Các file liên quan: `api_service.dart`, `history_model.dart`, `home_screen.dart`, `game_screen.dart`.

### Ghi chú:
- Nếu cần thêm tính năng mới (ví dụ: tích hợp với Laravel backend trong thư mục `sudoku-api`), hãy cập nhật file này.
- Kiểm tra phiên bản Dart SDK để đảm bảo tương thích với null safety.

## 1. Danh sách các API chính
Hệ thống sử dụng các API sau để kết nối ứng dụng Flutter với server Laravel:

| Tên API     | Phương thức | Mục đích                                      | Giao diện sử dụng |
|-------------|-------------|-----------------------------------------------|-------------------|
| Get History | GET        | Lấy danh sách lịch sử đấu từ cơ sở dữ liệu.   | HistoryScreen    |
| Save Result | POST       | Lưu kết quả (cấp độ, thời gian) khi người dùng thắng cuộc. | GameScreen      |

## 2. Thiết kế chi tiết API

### 2.1. API Lấy lịch sử (fetchHistory)
- **URL**: http://10.0.2.2:8000/api/game/history
- **Mô tả**: Trả về danh sách các ván đấu đã thực hiện.
- **Dữ liệu trả về (JSON Sample)**:
  ```json
  {
    "status": "success",
    "data": [
      {
        "level": "Easy",
        "time": "120",
        "created_at": "2026-04-09 10:00:00"
      }
    ]
  }
  ```

### 2.2. API Lưu kết quả (saveGameResult)
- **URL**: http://10.0.2.2:8000/api/game/history
- **Dữ liệu gửi lên (Body)**:
  ```json
  {
    "level": "string",
    "time": "integer"
  }
  ```
- **Database**: Dữ liệu được lưu vào bảng `game_histories` gồm các trường `level`, `time`, và `created_at`.

## 3. Cấu trúc thư mục Flutter đã tối ưu
Để tránh các lỗi "Target of URI doesn't exist", dự án được tổ chức như sau:
- `lib/services/api_service.dart`: Quản lý các lệnh gọi HTTP.
- `lib/models/history_model.dart`: Định nghĩa kiểu dữ liệu GameHistory.
- `lib/screens/`: Chứa các file giao diện (home, game, history).

## 4. Hướng dẫn cập nhật lên GitHub
Sử dụng các lệnh sau trong Terminal để commit kết quả:
```
git add .
git commit -m "Bổ sung thiết kế Backend và sửa lỗi logic API"
git push origin main
```