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
        Schema::table('task_categories', function (Blueprint $table) {
            $table->dropUnique('task_categories_name_unique');

            $table->unique(['user_id', 'name'], 'task_categories_user_id_name_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('task_categories', function (Blueprint $table) {
            $table->dropUnique('task_categories_user_id_name_unique');
            $table->unique('name', 'task_categories_name_unique');
        });
    }
};
