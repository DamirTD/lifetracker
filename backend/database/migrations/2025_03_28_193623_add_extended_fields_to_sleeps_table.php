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
        Schema::table('sleeps', function (Blueprint $table) {
            $table->string('mood_on_waking')->nullable()->after('quality');
            $table->json('sleep_environment')->nullable()->after('mood_on_waking');
            $table->json('device_data')->nullable()->after('sleep_environment');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('sleeps', function (Blueprint $table) {
            $table->dropColumn('mood_on_waking');
            $table->dropColumn('sleep_environment');
            $table->dropColumn('device_data');
        });
    }
};
