plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")

    // 1. THÊM DÒNG NÀY VÀO ĐÂY (Không cần version vì đã khai báo ở file Project level)
    id("com.google.gms.google-services")
}

android {
    // Thay vì flutter.compileSdkVersion, bạn hãy thử điền trực tiếp số 34 hoặc 35
    compileSdk = 34

    namespace = "com.example.gamesudoku"

    // Tương tự cho ndkVersion nếu bị báo lỗi tiếp theo
    ndkVersion = "25.2.9519653"

    defaultConfig {
        applicationId = "com.example.gamesudoku"
        // Điền số cụ thể nếu biến flutter bị lỗi
        minSdk = 21
        targetSdk = 34

        versionCode = 1
        versionName = "1.0"
    }
}

// 2. THÊM KHỐI DEPENDENCIES VÀO CUỐI FILE (HOẶC SAU KHỐI FLUTTER)
dependencies {
    // Nhập Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.1.0")) // Lưu ý: bản mới nhất thường là 33.x.x, bạn có thể dùng 33.1.0

    // Thêm các thư viện Firebase mong muốn
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
}

flutter {
    source = "../.."
}
