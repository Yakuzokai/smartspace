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
        Schema::create('room_project_furniture', function (Blueprint $table) {
            $table->id();
            $table->foreignId('room_project_id')->constrained('room_projects')->cascadeOnDelete();
            $table->foreignId('furniture_id')->constrained('furniture')->cascadeOnDelete();
            $table->decimal('position_x', 8, 4)->default(0.0000);
            $table->decimal('position_y', 8, 4)->default(0.0000);
            $table->decimal('position_z', 8, 4)->default(0.0000);
            $table->decimal('rotation_y', 8, 4)->default(0.0000);
            $table->decimal('scale', 5, 3)->default(1.000);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('room_project_furniture');
    }
};
