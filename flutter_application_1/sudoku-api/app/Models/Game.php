<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Game extends Model
{
  protected $fillable = ['user_id', 'board', 'solution', 'difficulty', 'is_completed', 'time', 'status'];

protected $casts = [
    'board' => 'array',
    'solution' => 'array',
];

}