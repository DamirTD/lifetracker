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
        Schema::table('finance_records', function (Blueprint $table) {
            $table->foreignId('category_id')->nullable()->after('user_id')
                ->constrained('finance_categories')
                ->onDelete('set null');
            $table->date('date')->nullable()->after('description');
            $table->boolean('is_recurring')->default(false)->after('date');
            $table->string('recurring_frequency')->nullable()->after('is_recurring')->comment('daily, weekly, monthly, yearly');
            $table->string('type')->comment('expense, income, saving, investment')->change();
            $table->string('period')->comment('day, week, month, year')->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('finance_records', function (Blueprint $table) {
            $table->dropForeign(['category_id']);
            $table->dropColumn(['category_id', 'date', 'is_recurring', 'recurring_frequency']);
        });
    }
};
