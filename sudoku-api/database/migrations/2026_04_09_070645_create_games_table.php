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
        $table->foreignId('user_id');
        $table->text('board');
        $table->text('solution');
        $table->string('difficulty');
        $table->string('status')->default('playing');
        $table->integer('time')->nullable();
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
