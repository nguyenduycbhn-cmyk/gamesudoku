import 'package:flutter_test/flutter_test.dart';
import 'package:gamesudoku/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Vì ứng dụng của bạn bắt đầu với màn hình Đăng nhập (LoginScreen) hoặc AuthWrapper
    // nên chúng ta sẽ kiểm tra xem có chữ 'Đăng nhập' trên màn hình không.
    expect(find.text('Đăng nhập'), findsOneWidget);
  });
}
