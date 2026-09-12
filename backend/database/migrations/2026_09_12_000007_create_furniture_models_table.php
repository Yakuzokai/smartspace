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
        Schema::create('furniture_models', function (Blueprint $table) {
            $table->id();
            $table->foreignId('furniture_id')->constrained('furniture')->cascadeOnDelete();
            $table->string('model_path');
            $table->string('format')->default('glb');
            $table->decimal('file_size_mb', 8, 2)->default(0.00);
            $table->boolean('is_optimized')->default(true);
            $table->boolean('draco_compressed')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('furniture_models');
    }
};
