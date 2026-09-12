<?php

namespace Tests\Unit;

use App\Models\Furniture;
use App\Models\RoomProject;
use App\Services\SpaceCompatibilityService;
use Tests\TestCase;

class SpaceCompatibilityServiceTest extends TestCase
{
    private SpaceCompatibilityService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new SpaceCompatibilityService();
    }

    /**
     * An empty room has no collisions, no breaches, and full clearance.
     */
    public function test_empty_room_scores_baseline(): void
    {
        $result = $this->service->evaluateLayout(400.0, 500.0, 260.0, 'living_room', []);

        $this->assertEquals(100.0, $result['total_score']);
        $this->assertTrue($result['is_valid']);
        $this->assertEquals('Excellent Fit', $result['verdict']);
        $this->assertEquals(30.0, $result['breakdown']['boundary_fit']['score']);
        $this->assertEquals(25.0, $result['breakdown']['collision']['score']);
        $this->assertEquals(25.0, $result['breakdown']['clearance']['score']);
        $this->assertEquals(10.0, $result['breakdown']['utilization']['score']);
        $this->assertEquals(10.0, $result['breakdown']['room_fitness']['score']);
    }

    /**
     * A well-proportioned layout with sofa, coffee table, and TV unit.
     */
    public function test_well_arranged_room_scores_excellent_fit(): void
    {
        // 4.2m x 5.0m room
        $items = [
            [
                'sku' => 'SOFA-001',
                'name' => 'Nordik 3-Seater Sofa',
                'category_slug' => 'sofas-lounging',
                'width_m' => 2.10,
                'height_m' => 0.82,
                'depth_m' => 0.88,
                'clearance_front_m' => 0.80,
                'clearance_side_m' => 0.50,
                'position_x' => 0.0,
                'position_y' => 0.0,
                'position_z' => -1.2,
                'rotation_y' => 0.0, // facing +Z
            ],
            [
                'sku' => 'COFF-001',
                'name' => 'Aura Oval Coffee Table',
                'category_slug' => 'coffee-side-tables',
                'width_m' => 1.10,
                'height_m' => 0.42,
                'depth_m' => 0.60,
                'clearance_front_m' => 0.50,
                'clearance_side_m' => 0.50,
                'position_x' => 0.0,
                'position_y' => 0.0,
                'position_z' => 0.2,
                'rotation_y' => 0.0,
            ],
            [
                'sku' => 'TV-002',
                'name' => 'Oslo Low Media Bench',
                'category_slug' => 'media-tv-units',
                'width_m' => 2.00,
                'height_m' => 0.48,
                'depth_m' => 0.45,
                'clearance_front_m' => 0.90,
                'clearance_side_m' => 0.40,
                'position_x' => 0.0,
                'position_y' => 0.0,
                'position_z' => 1.8,
                'rotation_y' => 180.0, // facing -Z towards sofa
            ],
        ];

        $result = $this->service->evaluateLayout(420.0, 500.0, 260.0, 'living_room', $items);

        $this->assertTrue($result['is_valid']);
        $this->assertGreaterThanOrEqual(90.0, $result['total_score']);
        $this->assertEquals(30.0, $result['breakdown']['boundary_fit']['score']);
        $this->assertEquals(25.0, $result['breakdown']['collision']['score']);
        $this->assertEquals('Excellent Fit', $result['verdict']);
    }

    /**
     * Furniture breaching perimeter walls fails boundary check (0 pts) and marks layout invalid.
     */
    public function test_boundary_breach_results_in_zero_boundary_score_and_invalid_state(): void
    {
        // Room width: 4.0m (bounds from -2.0m to +2.0m). Sofa placed at X = 1.8m with width 2.1m (extends to 2.85m).
        $items = [
            [
                'sku' => 'SOFA-001',
                'name' => 'Nordik 3-Seater Sofa',
                'category_slug' => 'sofas-lounging',
                'width_m' => 2.10,
                'height_m' => 0.82,
                'depth_m' => 0.88,
                'position_x' => 1.8,
                'position_y' => 0.0,
                'position_z' => 0.0,
                'rotation_y' => 0.0,
            ],
        ];

        $result = $this->service->evaluateLayout(400.0, 400.0, 260.0, 'living_room', $items);

        $this->assertFalse($result['is_valid']);
        $this->assertEquals(0.0, $result['breakdown']['boundary_fit']['score']);
        $this->assertEquals('fail', $result['breakdown']['boundary_fit']['status']);
        $this->assertCount(1, $result['breakdown']['boundary_fit']['violations']);
        $this->assertStringContainsString('east_wall_breach_m', json_encode($result['breakdown']['boundary_fit']['violations']));
        $this->assertEquals('Does Not Fit', $result['verdict']);
    }

    /**
     * Two overlapping furniture pieces cause a physical collision (0 pts) and invalid state.
     */
    public function test_collision_detection_fails_overlapping_items(): void
    {
        // Both items centered at (0.0, 0.0)
        $items = [
            [
                'sku' => 'SOFA-001',
                'name' => 'Nordik 3-Seater Sofa',
                'category_slug' => 'sofas-lounging',
                'width_m' => 2.10,
                'height_m' => 0.82,
                'depth_m' => 0.88,
                'position_x' => 0.0,
                'position_y' => 0.0,
                'position_z' => 0.0,
                'rotation_y' => 0.0,
            ],
            [
                'sku' => 'COFF-001',
                'name' => 'Aura Coffee Table',
                'category_slug' => 'coffee-side-tables',
                'width_m' => 1.10,
                'height_m' => 0.42,
                'depth_m' => 0.60,
                'position_x' => 0.2,
                'position_y' => 0.0,
                'position_z' => 0.1,
                'rotation_y' => 0.0,
            ],
        ];

        $result = $this->service->evaluateLayout(500.0, 500.0, 260.0, 'living_room', $items);

        $this->assertFalse($result['is_valid']);
        $this->assertEquals(0.0, $result['breakdown']['collision']['score']);
        $this->assertEquals('fail', $result['breakdown']['collision']['status']);
        $this->assertCount(1, $result['breakdown']['collision']['collisions']);
        $this->assertEquals('Does Not Fit', $result['verdict']);
    }

    /**
     * Front clearance restriction reduces clearance score proportionally.
     */
    public function test_clearance_restriction_applies_penalty(): void
    {
        // Sofa at Z = 1.6m in a 4.0m long room (Z boundary is +2.0m).
        // Front edge is at Z = 1.6 + 0.44 = 2.04m, so it faces directly into the south wall with 0cm clearance.
        $items = [
            [
                'sku' => 'SOFA-001',
                'name' => 'Nordik 3-Seater Sofa',
                'category_slug' => 'sofas-lounging',
                'width_m' => 2.10,
                'height_m' => 0.82,
                'depth_m' => 0.88,
                'clearance_front_m' => 0.80,
                'position_x' => 0.0,
                'position_y' => 0.0,
                'position_z' => 1.0, // front edge is at 1.44m, wall is at 1.75m -> only 31cm out of 80cm
                'rotation_y' => 0.0,
            ],
        ];

        $result = $this->service->evaluateLayout(400.0, 350.0, 260.0, 'living_room', $items);

        $this->assertTrue($result['is_valid']); // Stays within wall boundary (1.44m < 1.75m)
        $this->assertLessThan(25.0, $result['breakdown']['clearance']['score']);
        $this->assertGreaterThan(0, $result['breakdown']['clearance']['warning_count']);
    }

    /**
     * Overcrowded room with excessive furniture footprint gives 0 utilization points.
     */
    public function test_overcrowded_space_utilization(): void
    {
        // Room: 3m x 3m = 9 sqm.
        // Place 3 large sofas total footprint: 3 * (2.1 * 0.88) = 5.54 sqm (approx 62% occupied -> walking ratio 0.38)
        $items = [
            ['width_m' => 2.0, 'depth_m' => 1.0, 'height_m' => 0.8, 'position_x' => -0.5, 'position_z' => -1.0, 'rotation_y' => 0.0],
            ['width_m' => 2.0, 'depth_m' => 1.0, 'height_m' => 0.8, 'position_x' => -0.5, 'position_z' => 0.1, 'rotation_y' => 0.0],
            ['width_m' => 2.0, 'depth_m' => 1.0, 'height_m' => 0.8, 'position_x' => -0.5, 'position_z' => 1.2, 'rotation_y' => 0.0],
            ['width_m' => 0.8, 'depth_m' => 2.5, 'height_m' => 0.8, 'position_x' => 1.0, 'position_z' => 0.0, 'rotation_y' => 0.0],
        ]; // Total furniture area = 2 + 2 + 2 + 2 = 8 sqm out of 9 sqm -> walking ratio = 1/9 = 11%

        $result = $this->service->evaluateLayout(300.0, 300.0, 260.0, 'living_room', $items);

        $this->assertEquals(0.0, $result['breakdown']['utilization']['score']);
        $this->assertEquals('overcrowded', $result['breakdown']['utilization']['status']);
    }

    /**
     * Room type appropriateness checks category fitness.
     */
    public function test_room_fitness_scoring(): void
    {
        // 2 items: 1 bed (atypical for dining room), 1 dining chair
        $items = [
            ['category_slug' => 'beds-mattresses', 'width_m' => 1.8, 'depth_m' => 2.0, 'height_m' => 1.0, 'position_x' => 0.0, 'position_z' => -1.0],
            ['category_slug' => 'dining-chairs', 'width_m' => 0.5, 'depth_m' => 0.5, 'height_m' => 0.8, 'position_x' => 0.0, 'position_z' => 1.0],
        ];

        $result = $this->service->evaluateLayout(500.0, 500.0, 260.0, 'dining_room', $items);

        // 1 matched out of 2 -> 5.0 out of 10.0
        $this->assertEquals(5.0, $result['breakdown']['room_fitness']['score']);
        $this->assertCount(1, $result['breakdown']['room_fitness']['unmatched']);
    }

    /**
     * Evaluating a persisted RoomProject updates its database columns.
     */
    public function test_evaluate_persisted_project(): void
    {
        $project = RoomProject::where('name', 'Nordic Living Room Concept')->firstOrFail();

        $result = $this->service->evaluateProject($project, persist: true);

        $this->assertIsArray($result);
        $this->assertGreaterThanOrEqual(70.0, $result['total_score']);
        $this->assertTrue($result['is_valid']);

        // Refresh model from DB
        $project->refresh();
        $this->assertEquals($result['total_score'], $project->compatibility_score);
        $this->assertNotNull($project->score_breakdown);
    }
}
