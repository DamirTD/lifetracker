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
        Schema::create('user_water_progress_histories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->date('date');
            $table->string('action', 20);
            $table->integer('volume_ml')->default(0);
            $table->foreignId('container_id')->nullable();
            $table->timestamp('timestamp');
            $table->integer('daily_goal_ml')->nullable();
            $table->integer('glass_volume_ml')->nullable();
            $table->json('calculation_factors')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_water_progress_history');
    }
};
