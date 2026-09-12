<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Favorite;
use App\Models\Furniture;
use App\Models\Role;
use App\Models\RoomProject;
use App\Models\RoomProjectFurniture;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Roles
        $this->call(RoleSeeder::class);

        // 2. Categories
        $this->call(CategorySeeder::class);

        // 3. Furniture Catalog
        $this->call(FurnitureSeeder::class);

        // 4. Default System Users
        $adminRole = Role::where('slug', 'admin')->first();
        $customerRole = Role::where('slug', 'customer')->first();

        $admin = User::firstOrCreate(
            ['email' => 'admin@smartspace.local'],
            [
                'role_id' => $adminRole->id,
                'name' => 'SmartSpace Admin',
                'password' => Hash::make('password123'),
                'email_verified_at' => now(),
            ]
        );

        $customer = User::firstOrCreate(
            ['email' => 'customer@smartspace.local'],
            [
                'role_id' => $customerRole->id,
                'name' => 'Demo Customer',
                'password' => Hash::make('password123'),
                'email_verified_at' => now(),
            ]
        );

        // 5. Demo Room Project with Placed Furniture
        $sofa = Furniture::where('sku', 'SOFA-001')->first();
        $coffeeTable = Furniture::where('sku', 'COFF-001')->first();
        $tvUnit = Furniture::where('sku', 'TV-002')->first();
        $armchair = Furniture::where('sku', 'STG-003')->first();

        $project = RoomProject::firstOrCreate(
            [
                'user_id' => $customer->id,
                'name' => 'Nordic Living Room Concept',
            ],
            [
                'room_type' => 'living_room',
                'width_cm' => 420.00,
                'length_cm' => 500.00,
                'height_cm' => 260.00,
                'style' => 'scandinavian',
                'room_image_path' => null,
                'compatibility_score' => 92.50,
                'score_breakdown' => [
                    'boundary_fit' => 30.00,
                    'clearance' => 24.50,
                    'collision' => 25.00,
                    'circulation' => 8.00,
                    'room_fitness' => 5.00,
                    'is_valid' => true,
                    'evaluation_notes' => 'Comfortable circulation with compliant clearance envelopes on all placed seating and media units.',
                ],
            ]
        );

        // Seed 3D furniture placements (meters in Three.js right-handed coordinates)
        if ($sofa) {
            RoomProjectFurniture::firstOrCreate(
                ['room_project_id' => $project->id, 'furniture_id' => $sofa->id],
                ['position_x' => 0.0, 'position_y' => 0.0, 'position_z' => -1.2, 'rotation_y' => 0.0, 'scale' => 1.0]
            );
        }

        if ($coffeeTable) {
            RoomProjectFurniture::firstOrCreate(
                ['room_project_id' => $project->id, 'furniture_id' => $coffeeTable->id],
                ['position_x' => 0.0, 'position_y' => 0.0, 'position_z' => 0.2, 'rotation_y' => 0.0, 'scale' => 1.0]
            );
        }

        if ($tvUnit) {
            RoomProjectFurniture::firstOrCreate(
                ['room_project_id' => $project->id, 'furniture_id' => $tvUnit->id],
                ['position_x' => 0.0, 'position_y' => 0.0, 'position_z' => 1.8, 'rotation_y' => 180.0, 'scale' => 1.0]
            );
        }

        if ($armchair) {
            RoomProjectFurniture::firstOrCreate(
                ['room_project_id' => $project->id, 'furniture_id' => $armchair->id],
                ['position_x' => -1.25, 'position_y' => 0.0, 'position_z' => 0.4, 'rotation_y' => 60.0, 'scale' => 1.0]
            );
        }

        // 6. Seed Demo Favorites
        if ($sofa) {
            Favorite::firstOrCreate(['user_id' => $customer->id, 'furniture_id' => $sofa->id]);
        }
        if ($tvUnit) {
            Favorite::firstOrCreate(['user_id' => $customer->id, 'furniture_id' => $tvUnit->id]);
        }
        $desk = Furniture::where('sku', 'DSK-002')->first();
        if ($desk) {
            Favorite::firstOrCreate(['user_id' => $customer->id, 'furniture_id' => $desk->id]);
        }

        // 7. Defense Demonstration Scenarios
        $this->call(DefenseDemoScenariosSeeder::class);
    }
}
