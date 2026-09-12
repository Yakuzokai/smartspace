<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Furniture;
use App\Models\User;
use Tests\TestCase;

class ApiV1Test extends TestCase
{
    /**
     * Test health check endpoint.
     */
    public function test_health_check_endpoint(): void
    {
        $response = $this->getJson('/api/v1/health');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'healthy',
                'service' => 'SmartSpace Backend API',
            ]);
    }

    /**
     * Test user registration, token issue, and authenticated profile access.
     */
    public function test_user_registration_and_authentication(): void
    {
        $payload = [
            'name' => 'Test Spatial Architect',
            'email' => 'architect_' . uniqid() . '@smartspace.local',
            'password' => 'SecurePassword123!',
        ];

        // Register
        $regResponse = $this->postJson('/api/v1/auth/register', $payload);
        $regResponse->assertStatus(201)
            ->assertJsonStructure(['token', 'user' => ['id', 'name', 'email', 'role']]);

        $token = $regResponse->json('token');

        // Authenticated profile (/auth/me)
        $meResponse = $this->withHeader('Authorization', "Bearer {$token}")
            ->getJson('/api/v1/auth/me');

        $meResponse->assertStatus(200)
            ->assertJson([
                'email' => $payload['email'],
                'role' => 'customer',
            ]);

        // Login with credentials
        $loginResponse = $this->postJson('/api/v1/auth/login', [
            'email' => $payload['email'],
            'password' => $payload['password'],
        ]);

        $loginResponse->assertStatus(200)
            ->assertJsonStructure(['token', 'user']);
    }

    /**
     * Test categories tree endpoint.
     */
    public function test_category_tree_endpoint(): void
    {
        $response = $this->getJson('/api/v1/categories');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'name',
                        'slug',
                        'subcategories' => [
                            '*' => ['id', 'name', 'slug', 'furniture_count'],
                        ],
                    ],
                ],
            ]);

        $this->assertCount(4, $response->json('data'));
    }

    /**
     * Test furniture catalog query and style filtering.
     */
    public function test_furniture_catalog_style_filtering(): void
    {
        $response = $this->getJson('/api/v1/furniture?style=scandinavian');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'sku',
                        'name',
                        'price',
                        'dimensions',
                        'bounding_box',
                        'clearance_envelope',
                        'style',
                        'availability',
                    ],
                ],
                'links',
                'meta',
            ]);

        // All returned items must have style = scandinavian
        $items = $response->json('data');
        $this->assertNotEmpty($items);
        foreach ($items as $item) {
            $this->assertEquals('scandinavian', $item['style']);
            $this->assertEquals('in_stock', $item['availability']['status']);
        }
    }

    /**
     * Test dimensional constraints search (max_width_cm, max_depth_cm, max_height_cm).
     */
    public function test_furniture_catalog_dimensional_filtering(): void
    {
        $maxWidth = 160.0;
        $maxDepth = 90.0;
        $maxHeight = 90.0;

        $response = $this->getJson("/api/v1/furniture?max_width_cm={$maxWidth}&max_depth_cm={$maxDepth}&max_height_cm={$maxHeight}");

        $response->assertStatus(200);
        $items = $response->json('data');
        $this->assertNotEmpty($items);

        foreach ($items as $item) {
            $this->assertLessThanOrEqual($maxWidth, $item['dimensions']['width_cm']);
            $this->assertLessThanOrEqual($maxDepth, $item['dimensions']['depth_cm']);
            $this->assertLessThanOrEqual($maxHeight, $item['dimensions']['height_cm']);
        }
    }

    /**
     * Test single furniture details endpoint.
     */
    public function test_single_furniture_details(): void
    {
        $sofa = Furniture::where('sku', 'SOFA-001')->firstOrFail();

        $response = $this->getJson("/api/v1/furniture/{$sofa->id}");

        $response->assertStatus(200)
            ->assertJson([
                'data' => [
                    'sku' => 'SOFA-001',
                    'style' => 'scandinavian',
                    'dimensions' => [
                        'width_cm' => 210.0,
                        'height_cm' => 82.0,
                        'depth_cm' => 88.0,
                    ],
                    'availability' => [
                        'status' => 'in_stock',
                    ],
                ],
            ]);
    }

    /**
     * Test Room Project lifecycle: create, transactional layout update, certified scoring, validation, delete.
     */
    public function test_room_project_lifecycle_and_transactional_layout(): void
    {
        $user = User::where('email', 'customer@smartspace.local')->firstOrFail();
        $token = $user->createToken('test_token')->plainTextToken;

        // 1. Create room project
        $createResponse = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/v1/room-projects', [
                'name' => 'Studio Loft Project',
                'room_type' => 'studio',
                'width_cm' => 450.0,
                'length_cm' => 600.0,
                'height_cm' => 280.0,
                'style' => 'minimalist',
            ]);

        $createResponse->assertStatus(201)
            ->assertJsonStructure(['data' => ['id', 'name', 'compatibility_score', 'score_breakdown']]);

        $projectId = $createResponse->json('data.id');
        $this->assertEquals(100.0, $createResponse->json('data.compatibility_score'));

        // 2. Transactionally update layout with placed furniture
        $sofa = Furniture::where('sku', 'SOFA-002')->firstOrFail(); // Loft studio sofa
        $table = Furniture::where('sku', 'COFF-002')->firstOrFail(); // Mono block low table

        $layoutResponse = $this->withHeader('Authorization', "Bearer {$token}")
            ->putJson("/api/v1/room-projects/{$projectId}/layout", [
                'items' => [
                    [
                        'furniture_id' => $sofa->id,
                        'position_x' => 0.0,
                        'position_y' => 0.0,
                        'position_z' => -1.0,
                        'rotation_y' => 0.0,
                    ],
                    [
                        'furniture_id' => $table->id,
                        'position_x' => 0.0,
                        'position_y' => 0.0,
                        'position_z' => 0.5,
                        'rotation_y' => 0.0,
                    ],
                ],
            ]);

        $layoutResponse->assertStatus(200);
        $this->assertCount(2, $layoutResponse->json('data.furniture_placements'));
        $this->assertGreaterThanOrEqual(85.0, $layoutResponse->json('data.compatibility_score'));

        // 3. On-demand validation endpoint
        $validateResponse = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson("/api/v1/room-projects/{$projectId}/validate");

        $validateResponse->assertStatus(200)
            ->assertJsonStructure([
                'project_id',
                'evaluation' => [
                    'total_score',
                    'is_valid',
                    'verdict',
                    'breakdown' => [
                        'boundary_fit',
                        'collision',
                        'clearance',
                        'utilization',
                        'room_fitness',
                    ],
                ],
            ]);

        // 4. Delete project
        $deleteResponse = $this->withHeader('Authorization', "Bearer {$token}")
            ->deleteJson("/api/v1/room-projects/{$projectId}");

        $deleteResponse->assertStatus(200);
    }

    /**
     * Test favorites toggle endpoint.
     */
    public function test_favorites_toggle(): void
    {
        $user = User::where('email', 'customer@smartspace.local')->firstOrFail();
        $token = $user->createToken('test_token_fav')->plainTextToken;
        $bed = Furniture::where('sku', 'BED-002')->firstOrFail();

        // Toggle ON
        $onResponse = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson("/api/v1/favorites/toggle/{$bed->id}");

        $onResponse->assertStatus(200)
            ->assertJson(['favorited' => true]);

        // Verify list
        $listResponse = $this->withHeader('Authorization', "Bearer {$token}")
            ->getJson('/api/v1/favorites');

        $listResponse->assertStatus(200);
        $favSkus = collect($listResponse->json('data'))->pluck('sku')->all();
        $this->assertContains('BED-002', $favSkus);

        // Toggle OFF
        $offResponse = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson("/api/v1/favorites/toggle/{$bed->id}");

        $offResponse->assertStatus(200)
            ->assertJson(['favorited' => false]);
    }

    /**
     * Test unauthorized access rejection on protected endpoints.
     */
    public function test_unauthenticated_requests_are_rejected(): void
    {
        $this->getJson('/api/v1/auth/me')->assertStatus(401);
        $this->getJson('/api/v1/room-projects')->assertStatus(401);
        $this->postJson('/api/v1/room-projects', [])->assertStatus(401);
        $this->getJson('/api/v1/favorites')->assertStatus(401);
    }
}
