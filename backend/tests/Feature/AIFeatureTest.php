<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Furniture;
use App\Models\Role;
use App\Models\RoomProject;
use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class AIFeatureTest extends TestCase
{
    use DatabaseTransactions;

    protected User $user;
    protected RoomProject $project;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');

        $role = Role::firstOrCreate(['slug' => 'customer'], ['name' => 'customer']);
        $this->user = User::firstOrCreate(
            ['email' => 'ai_test@smartspace.local'],
            [
                'name' => 'AI Test User',
                'password' => bcrypt('password123'),
                'role_id' => $role->id,
            ]
        );

        $category = Category::firstOrCreate(
            ['slug' => 'living-room-test'],
            ['name' => 'Living Room Test']
        );

        $this->project = RoomProject::create([
            'user_id' => $this->user->id,
            'name' => 'AI Test Living Room',
            'room_type' => 'Living Room',
            'width_cm' => 400.0,
            'length_cm' => 500.0,
            'height_cm' => 280.0,
            'style_preference' => 'Scandinavian',
        ]);

        Furniture::create([
            'category_id' => $category->id,
            'name' => 'Nordik 3-Seater Sofa',
            'slug' => 'nordik-3-seater-sofa',
            'sku' => 'SOFA-AI-001',
            'price' => 1250.00,
            'width_cm' => 210.0,
            'depth_cm' => 88.0,
            'height_cm' => 82.0,
            'style' => 'Scandinavian',
            'color_name' => 'Warm Taupe',
            'color_hex' => '#9B8D7E',
            'material' => 'Textured Bouclé Fabric',
            'is_active' => true,
        ]);
    }

    public function test_room_analysis_requires_authentication(): void
    {
        $response = $this->postJson('/api/v1/ai/analyze-room', []);
        $response->assertStatus(401);
    }

    public function test_authenticated_user_can_analyze_room_image(): void
    {
        // 1x1 valid minimal JPEG binary
        $jpegBinary = base64_decode('/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////wgALCAABAAEBAREA/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPxA=');
        $tempPath = tempnam(sys_get_temp_dir(), 'test_img_') . '.jpg';
        file_put_contents($tempPath, $jpegBinary);
        $image = new UploadedFile($tempPath, 'living_room.jpg', 'image/jpeg', null, true);

        $response = $this->actingAs($this->user, 'sanctum')
            ->post('/api/v1/ai/analyze-room', [
                'image' => $image,
                'hint' => 'Living Room',
                'room_project_id' => $this->project->id,
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'analysis' => [
                    'id',
                    'image_url',
                    'detected_room_type',
                    'detected_style',
                    'dominant_colors',
                    'confidence',
                    'provider',
                ],
            ]);

        $this->assertDatabaseHas('room_analyses', [
            'user_id' => $this->user->id,
            'room_project_id' => $this->project->id,
        ]);
    }

    public function test_recommendations_endpoint_returns_geometry_constrained_results(): void
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->postJson('/api/v1/ai/recommendations', [
                'room_project_id' => $this->project->id,
                'room_type' => 'Living Room',
                'style' => 'Scandinavian',
            ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'target_style',
                'provider',
                'recommendations',
            ]);
    }
}
