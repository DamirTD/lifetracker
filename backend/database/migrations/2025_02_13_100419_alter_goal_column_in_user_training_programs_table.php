<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('user_training_programs', function (Blueprint $table) {
            $table->string('goal')->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('user_training_programs', function (Blueprint $table) {
            $table->enum('goal', ['weight_loss', 'muscle_gain', 'maintain'])->change();
        });
    }
};
