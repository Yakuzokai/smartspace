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
        Schema::create('furniture', function (Blueprint $table) {
            $table->id();
            $table->foreignId('category_id')->constrained('categories')->cascadeOnDelete();
            $table->string('sku')->unique();
            $table->string('name');
            $table->text('description')->nullable();
            $table->decimal('price', 10, 2);
            $table->decimal('width_cm', 8, 2);
            $table->decimal('height_cm', 8, 2);
            $table->decimal('depth_cm', 8, 2);
            $table->decimal('clearance_front_cm', 8, 2)->default(75.00);
            $table->decimal('clearance_side_cm', 8, 2)->default(60.00);
            $table->string('style');
            $table->string('material')->nullable();
            $table->string('color')->nullable();
            $table->string('color_hex', 7)->nullable();
            $table->string('glb_model_path')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index('style');
            $table->index('price');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('furniture');
    }
};
