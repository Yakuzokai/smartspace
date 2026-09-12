<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Furniture;
use App\Models\Role;
use App\Models\RoomAnalysis;
use App\Models\RoomProject;
use App\Models\RoomProjectFurniture;
use App\Models\User;
use Tests\TestCase;

class DatabaseFoundationTest extends TestCase
{
    public function test_roles_and_users_exist(): void
    {
        $this->assertDatabaseHas('roles', ['slug' => 'admin']);
        $this->assertDatabaseHas('roles', ['slug' => 'customer']);

        $this->assertDatabaseHas('users', ['email' => 'admin@smartspace.local']);
        $this->assertDatabaseHas('users', ['email' => 'customer@smartspace.local']);
    }

    public function test_categories_hierarchy(): void
    {
        $this->assertEquals(4, Category::whereNull('parent_id')->count());
        $this->assertEquals(9, Category::whereNotNull('parent_id')->count());
    }

    public function test_furniture_curated_count_and_geometry(): void
    {
        $this->assertEquals(40, Furniture::count());

        $sofa = Furniture::where('sku', 'SOFA-001')->firstOrFail();
        $this->assertEquals(2.1, $sofa->width_m);
        $this->assertEquals(0.88, $sofa->depth_m);
        $this->assertEquals(1.848, $sofa->footprint_area_sqm);

        $this->assertArrayHasKey('width_m', $sofa->bounding_box);
        $this->assertArrayHasKey('clearance_envelope', $sofa->toArray());
    }

    public function test_room_project_and_spatial_bounds(): void
    {
        $project = RoomProject::firstOrFail();
        $this->assertEquals(420.00, $project->width_cm);
        $this->assertEquals(4.2, $project->width_m);

        $placement = RoomProjectFurniture::firstOrFail();
        $this->assertEquals(1.0, $placement->scale);

        $bounds = $placement->getWorldBounds2D();
        $this->assertArrayHasKey('min_x', $bounds);
        $this->assertArrayHasKey('max_x', $bounds);
    }

    public function test_room_analysis_hides_raw_response(): void
    {
        $analysis = new RoomAnalysis([
            'user_id' => 1,
            'image_path' => '/storage/sample.jpg',
            'raw_response' => ['secret_key' => '12345'],
        ]);

        $this->assertArrayNotHasKey('raw_response', $analysis->toArray());
    }
}
