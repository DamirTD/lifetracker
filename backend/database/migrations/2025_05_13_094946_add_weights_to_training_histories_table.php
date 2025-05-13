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
        Schema::table('training_histories', function (Blueprint $table) {
            $table->float('weight_before')->nullable();
            $table->float('weight_after')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('training_histories', function (Blueprint $table) {
            $table->dropColumn(['weight_before', 'weight_after']);
        });
    }
};
