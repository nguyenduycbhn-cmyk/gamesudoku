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

        // Tìm user đầu tiên để gán vào game
        $user = User::first();
        if (!$user) {
            return response()->json(['error' => 'Vui lòng chạy /api/register để tạo user trước'], 400);
        }

        // Đã xóa dòng 'status' để tránh lỗi Database
        $game = Game::create([
            'user_id'      => $user->id,
            'board'        => $board,
            'solution'     => $solution,
            'difficulty'   => 'easy',
            'is_completed' => false,
        ]);

        return response()->json([
            'game_id' => $game->id,
            'board'   => $board
        ]);
    }

    // ✅ Kiểm tra kết quả gửi lên từ Client
    public function check(Request $request)
    {
        // Yêu cầu gửi lên: game_id, board (mảng hiện tại), time
        $game = Game::find($request->game_id);

        if (!$game) {
            return response()->json(['error' => 'Không tìm thấy ván game này'], 404);
        }

        // So sánh mảng người dùng gửi lên với solution trong DB
        if ($game->solution == $request->board) {
            $game->update([
                'is_completed' => true,
                'time' => $request->time
            ]);

            return response()->json(['message' => 'Chính xác! Bạn thắng rồi 🎉', 'status' => true]);
        }

        return response()->json(['message' => 'Vẫn còn chỗ sai, thử lại nhé ❌', 'status' => false]);
    }

    // 📜 Xem lại lịch sử các ván game
    public function history()
    {
        return response()->json(Game::latest()->get());
    }
}
