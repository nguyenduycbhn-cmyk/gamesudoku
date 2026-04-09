<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\GameController;

/*

|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// ✅ TEST NHANH (Sử dụng GET để test trên trình duyệt)
Route::get('/register', function () {
    $user = \App\Models\User::create([
        'name' => 'duy',
        'email' => 'duy' . rand(1, 1000) . '@gmail.com',
        'password' => bcrypt('123456')
    ]);
    return response()->json(['message' => 'Tạo user thành công', 'user' => $user]);
});

Route::get('/login', function () {
    $user = \App\Models\User::first();
    if (!$user) return response()->json(['error' => 'Chưa có user']);
    
    $token = $user->createToken('auth_token')->plainTextToken;
    return response()->json(['message' => 'Login thành công', 'token' => $token]);
});

// 🎮 GAME ROUTES (Đã cập nhật theo ảnh)
Route::group(['prefix' => 'game'], function () {
    Route::get('/new', [GameController::class, 'newGame']);     // Lấy game mới
    Route::post('/check', [GameController::class, 'check']);    // Kiểm tra kết quả (POST)
    Route::get('/history', [GameController::class, 'history']); // Xem lịch sử
});

// 🔐 USER (Yêu cầu Token Sanctum)
Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});
