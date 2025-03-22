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
        Schema::create('budgets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('category_id')
                ->constrained('finance_categories')
                ->onDelete('cascade');
            $table->decimal('amount', 10, 2);
            $table->string('period')->comment('week, month, year');
            $table->date('start_date');
            $table->date('end_date');
            $table->timestamps();
            $table->unique(['user_id', 'category_id', 'period', 'start_date', 'end_date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('budgets');
    }
};
