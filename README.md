# Sudoku App

Ứng dụng Sudoku đơn giản được xây dựng bằng Flutter.

## Mô tả

`SudokuApp` là một trò chơi Sudoku 9x9 bao gồm:
- Tạo bàn cờ Sudoku hợp lệ bằng thuật toán giải đệ quy (backtracking)
- Hiển thị lưới 9x9
- Chọn ô để nhập số
- Nút "New" tạo một ván chơi mới
- Nút "Reset" đặt lại trạng thái về ván hiện tại
- Nút "Hint" gợi ý chữ số đúng tại ô đang chọn

## Cấu trúc dự án

- `sudoku_app` (file chứa mã nguồn chính)

## Yêu cầu

- Flutter SDK (phiên bản 2.x/3.x trở lên)
- Dart

## Cài đặt & chạy

1. Clone repo:
```bash
git clone https://github.com/<your-username>/gamesudoku.git
cd gamesudoku
```
2. Mở dự án với Android Studio/VS Code.
3. Chạy ứng dụng:
```bash
flutter run
```

## Chức năng hiện tại

- Sinh bảng Sudoku đầy đủ
- Loại bỏ 40 ô để tạo bài
- Cho phép người dùng chọn ô và nhập số 1-9
- Gợi ý giá trị đúng cho ô đang chọn

## Hướng mở rộng

- Kiểm tra luật khi nhập số (cảnh báo vi phạm)
- Thêm cấp độ khó (Easy/Medium/Hard)
- Lưu điểm và lịch sử ván chơi
- Hổ trợ undo/redo

## Tác giả

- Dự án mẫu: `gamesudoku`
