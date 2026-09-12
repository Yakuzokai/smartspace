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
        Schema::create('room_analyses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('room_project_id')->nullable()->constrained('room_projects')->nullOnDelete();
            $table->string('image_path');
            $table->string('detected_room_type')->nullable();
            $table->string('detected_style')->nullable();
            $table->json('detected_colors')->nullable();
            $table->json('detected_objects')->nullable();
            $table->decimal('confidence', 4, 3)->default(0.000);
            $table->string('ai_provider')->default('mock');
            $table->json('raw_response')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('room_analyses');
    }
};
