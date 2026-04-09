<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Game;
use App\Models\User;

class GameController extends Controller
{
    // 🎮 Tạo game mới
    public function newGame()
    {
        $board = [
            [5,3,0,0,7,0,0,0,0],[6,0,0,1,9,5,0,0,0],[0,9,8,0,0,0,0,6,0],
            [8,0,0,0,6,0,0,0,3],[4,0,0,8,0,3,0,0,1],[7,0,0,0,2,0,0,0,6],
            [0,6,0,0,0,0,2,8,0],[0,0,0,4,1,9,0,0,5],[0,0,0,0,8,0,0,7,9]
        ];

        $solution = [
            [5,3,4,6,7,8,9,1,2],[6,7,2,1,9,5,3,4,8],[1,9,8,3,4,2,5,6,7],
            [8,5,9,7,6,1,4,2,3],[4,2,6,8,5,3,7,9,1],[7,1,3,9,2,4,8,5,6],
            [9,6,1,5,3,7,2,8,4],[2,8,7,4,1,9,6,3,5],[3,4,5,2,8,6,1,7,9]
        ];

        // Lấy đại diện 1 User để gán vào (Tránh lỗi NOT NULL user_id)
        $user = User::first();
        if (!$user) {
            return response()->json(['error' => 'Vui lòng tạo user trước bằng /api/register'], 400);
        }

        // TRUYỀN ĐẦY ĐỦ CÁC CỘT TRONG DATABASE
        $game = Game::create([
            'user_id'      => $user->id,
            'board'        => $board,
            'solution'     => $solution,
            'difficulty'   => 'easy',
            'is_completed' => false, // Mặc định chưa xong
            'status'       => 'playing' // Nếu migration có cột status
        ]);

        return response()->json([
            'game_id' => $game->id,
            'board'   => $board
        ]);
    }

    // ✅ Check kết quả
    public function check(Request $request)
    {
        // Nhận dữ liệu từ Postman (board và game_id)
        $game = Game::find($request->game_id);

        if (!$game) {
            return response()->json(['error' => 'Game không tồn tại'], 404);
        }

        // So sánh mảng (Laravel tự cast JSON sang Array nếu đã cấu chỉnh Model)
        if ($game->solution == $request->board) {
            $game->update([
                'is_completed' => true,
                'time' => $request->time
            ]);

            return response()->json(['message' => 'Chính xác 🎉', 'status' => true]);
        }

        return response()->json(['message' => 'Sai rồi ❌', 'status' => false]);
    }

    // 📜 Lịch sử
    public function history()
    {
        return response()->json(Game::latest()->get());
    }
}
