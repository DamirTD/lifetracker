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
        Schema::table('user_water_progress', function (Blueprint $table) {
            $table->integer('remaining_ml')->default(0)->after('daily_goal_ml');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('user_water_progress', function (Blueprint $table) {
            //
        });
    }
};
