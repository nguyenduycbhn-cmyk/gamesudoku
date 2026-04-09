<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::create('games', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable(); // Cho phép null nếu chơi khách
            $table->json('board');                    // Lưu bàn Sudoku dạng mảng JSON
            $table->json('solution');                 // Lưu đáp án dạng mảng JSON
            $table->string('difficulty');
            $table->boolean('is_completed')->default(false); // Trạng thái hoàn thành
            $table->integer('time')->nullable();      // Thời gian chơi tính bằng giây
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('games');
    }
};
