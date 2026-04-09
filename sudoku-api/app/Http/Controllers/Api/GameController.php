<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Game;

class GameController extends Controller
{
    // 1. Tạo game mới
    public function newGame(Request $request)
    {
        // Bàn Sudoku mẫu (demo)
        $board = [
            [5,3,0,0,7,0,0,0,0],
            [6,0,0,1,9,5,0,0,0],
            [0,9,8,0,0,0,0,6,0],
            [8,0,0,0,6,0,0,0,3],
            [4,0,0,8,0,3,0,0,1],
            [7,0,0,0,2,0,0,0,6],
            [0,6,0,0,0,0,2,8,0],
            [0,0,0,4,1,9,0,0,5],
            [0,0,0,0,8,0,0,7,9]
        ];

        // Demo solution (sau này bạn nâng cấp)
        $solution = $board;

        $game = Game::create([
            'user_id' => auth()->id(),
            'board' => json_encode($board),
            'solution' => json_encode($solution),
            'difficulty' => 'easy',
            'status' => 'playing'
        ]);

        return response()->json([
            'game_id' => $game->id,
            'board' => $board
        ]);
    }

    // 2. Submit game
    public function submitGame(Request $request)
    {
        $game = Game::find($request->game_id);

        if (!$game) {
            return response()->json(['error' => 'Game không tồn tại'], 404);
        }

        if ($game->solution == json_encode($request->board)) {
            $game->status = 'win';
            $game->time = $request->time;
            $game->save();

            return response()->json([
                'result' => 'correct'
            ]);
        }

        return response()->json([
            'result' => 'wrong'
        ]);
    }

    // 3. Lịch sử chơi
    public function history()
    {
        $games = Game::where('user_id', auth()->id())->get();

        return response()->json($games);
    }

    // 4. Thống kê
    public function statistics()
    {
        $games = Game::where('user_id', auth()->id());

        return response()->json([
            'total_games' => $games->count(),
            'win' => $games->where('status', 'win')->count(),
            'lose' => $games->where('status', 'playing')->count()
        ]);
    }
}