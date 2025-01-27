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
            $table->integer('glasses_today')
                ->default(0)
                ->after('consumed_ml');
            $table->timestamp('last_added_at')
                ->nullable()
                ->after('glasses_today');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('user_water_progresses', function (Blueprint $table) {
            $table->dropColumn('glasses_today');
            $table->dropColumn('last_added_at');
        });
    }
};
