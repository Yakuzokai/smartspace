<?php

namespace Database\Seeders;

use App\Models\Furniture;
use App\Models\RoomProject;
use App\Models\RoomProjectFurniture;
use App\Models\User;
use App\Services\SpaceCompatibilityService;
use Illuminate\Database\Seeder;

class DefenseDemoScenariosSeeder extends Seeder
{
    /**
     * Seeds 3 calibrated Capstone Defense demonstration scenarios.
     * All scores are calculated dynamically by SpaceCompatibilityService,
     * ensuring no hardcoded scores exist in the database.
     */
    public function run(): void
    {
        $user = User::where('email', 'customer@smartspace.local')->first();
        if (!$user) {
            return;
        }

        $spatialService = app(SpaceCompatibilityService::class);

        // Fetch required catalog items
        $sofa1 = Furniture::where('sku', 'SOFA-001')->first() ?? Furniture::first();
        $sofa2 = Furniture::where('sku', 'SOFA-002')->first() ?? Furniture::skip(1)->first();
        $sofa3 = Furniture::where('sku', 'SOFA-003')->first() ?? Furniture::skip(2)->first();
        $coff1 = Furniture::where('sku', 'COFF-001')->first() ?? Furniture::skip(3)->first();
        $tv1 = Furniture::where('sku', 'TV-001')->first() ?? Furniture::skip(4)->first();
        $table1 = Furniture::where('sku', 'DTB-001')->first() ?? Furniture::skip(5)->first();
        $stg1 = Furniture::where('sku', 'STG-001')->first() ?? Furniture::skip(6)->first();

        // ---------------------------------------------------------------------
        // SCENARIO A: High Compliance Living Room (~95-100/100)
        // ---------------------------------------------------------------------
        $projectA = RoomProject::updateOrCreate(
            [
                'user_id' => $user->id,
                'name' => 'Scenario A — High Compliance Living Room',
            ],
            [
                'room_type' => 'living_room',
                'style' => 'scandinavian',
                'width_cm' => 420.0,
                'length_cm' => 500.0,
                'height_cm' => 280.0,
            ]
        );

        // Clear existing placements for scenario A
        $projectA->furniturePlacements()->delete();

        // 1. Primary 3-Seater Sofa centered against rear zone
        RoomProjectFurniture::create([
            'room_project_id' => $projectA->id,
            'furniture_id' => $sofa1->id,
            'position_x' => 0.0,
            'position_y' => 0.0,
            'position_z' => -1.6,
            'rotation_y' => 0.0,
        ]);

        // 2. Oval Coffee Table with clear walking corridors
        RoomProjectFurniture::create([
            'room_project_id' => $projectA->id,
            'furniture_id' => $coff1->id,
            'position_x' => 0.0,
            'position_y' => 0.0,
            'position_z' => 0.1,
            'rotation_y' => 0.0,
        ]);

        // 3. Media Console against front wall, facing sofa
        RoomProjectFurniture::create([
            'room_project_id' => $projectA->id,
            'furniture_id' => $tv1->id,
            'position_x' => 0.0,
            'position_y' => 0.0,
            'position_z' => 2.0,
            'rotation_y' => 180.0, // facing inward towards -Z
        ]);

        $coff3 = Furniture::where('sku', 'COFF-003')->first() ?? Furniture::skip(7)->first();

        // 4. Accent Side Table beside primary sofa
        if ($coff3) {
            RoomProjectFurniture::create([
                'room_project_id' => $projectA->id,
                'furniture_id' => $coff3->id,
                'position_x' => 1.55,
                'position_y' => 0.0,
                'position_z' => -1.6,
                'rotation_y' => 0.0,
            ]);
        }

        // 5. Tall Modular Bookcase against left wall
        if ($stg1) {
            RoomProjectFurniture::create([
                'room_project_id' => $projectA->id,
                'furniture_id' => $stg1->id,
                'position_x' => -1.8,
                'position_y' => 0.0,
                'position_z' => 0.0,
                'rotation_y' => 90.0, // facing inward towards +X
            ]);
        }

        // Evaluate layout dynamically through the geometry engine and persist output
        $resA = $spatialService->evaluateProject($projectA, true);
        echo "Scenario A Evaluated: Score {$resA['total_score']}/100\n";
        foreach ($resA['breakdown'] as $k => $v) {
            $max = $v['max'] ?? 0;
            echo "   - $k: {$v['score']}/{$max}\n";
        }

        // ---------------------------------------------------------------------
        // SCENARIO B: Conflict & Recovery Demo (Boundary & Collision Violations)
        // ---------------------------------------------------------------------
        $projectB = RoomProject::updateOrCreate(
            [
                'user_id' => $user->id,
                'name' => 'Scenario B — Conflict & Recovery Demo',
            ],
            [
                'room_type' => 'living_room',
                'style' => 'industrial',
                'width_cm' => 300.0,
                'length_cm' => 320.0,
                'height_cm' => 260.0,
            ]
        );

        $projectB->furniturePlacements()->delete();

        // 1. Large Sectional placed overlapping the wall boundary at X = +1.5m
        RoomProjectFurniture::create([
            'room_project_id' => $projectB->id,
            'furniture_id' => $sofa3->id,
            'position_x' => 1.1, // Half-width extends past right wall at +1.5m
            'position_y' => 0.0,
            'position_z' => 0.4,
            'rotation_y' => 0.0,
        ]);

        // 2. Dining Table placed intersecting directly inside the sectional
        RoomProjectFurniture::create([
            'room_project_id' => $projectB->id,
            'furniture_id' => $table1->id,
            'position_x' => 0.6, // Directly overlaps sectional AABB
            'position_y' => 0.0,
            'position_z' => 0.4,
            'rotation_y' => 0.0,
        ]);

        // Evaluate layout dynamically through the geometry engine
        $resB = $spatialService->evaluateProject($projectB, true);
        echo "Scenario B Evaluated: Score {$resB['total_score']}/100 (Collision: {$resB['breakdown']['collision']['score']}/25, Boundary: {$resB['breakdown']['boundary_fit']['score']}/30)\n";

        // ---------------------------------------------------------------------
        // SCENARIO C: AI Vision Sandbox (Blank Slate for Live Photo Analysis)
        // ---------------------------------------------------------------------
        $projectC = RoomProject::updateOrCreate(
            [
                'user_id' => $user->id,
                'name' => 'Scenario C — AI Vision Sandbox',
            ],
            [
                'room_type' => 'living_room',
                'style' => 'scandinavian',
                'width_cm' => 400.0,
                'length_cm' => 500.0,
                'height_cm' => 280.0,
                'compatibility_score' => null, // Uncertified blank state
                'score_breakdown' => null,
            ]
        );

        $projectC->furniturePlacements()->delete();
        echo "Scenario C Seeded: Blank AI Sandbox ready for photo upload.\n";
    }
}
