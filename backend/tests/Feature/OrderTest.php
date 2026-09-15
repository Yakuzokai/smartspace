<?php

namespace Tests\Feature;

use App\Models\Furniture;
use Tests\TestCase;

class OrderTest extends TestCase
{
    /**
     * Test order placement via POST /api/v1/orders.
     */
    public function test_can_place_order_successfully(): void
    {
        $furniture = Furniture::first();

        if (!$furniture) {
            $this->markTestSkipped('No furniture seeded.');
        }

        $payload = [
            'shipping' => [
                'first_name' => 'Maria',
                'last_name' => 'Santos',
                'email' => 'maria.santos@example.com',
                'phone' => '+63 917 123 4567',
                'address_line1' => 'Unit 14B Minimalist Tower, Ayala Ave',
                'address_line2' => 'Bel-Air',
                'city' => 'Makati',
                'province' => 'Metro Manila',
                'postal_code' => '1209',
                'notes' => 'Please call upon arrival at the lobby',
            ],
            'payment_method' => 'cod',
            'items' => [
                [
                    'furniture_id' => $furniture->id,
                    'quantity' => 2,
                    'price' => (float) $furniture->price,
                ],
            ],
            'subtotal' => (float) $furniture->price * 2,
            'shipping_fee' => 0,
            'discount_amount' => 0,
            'total' => (float) $furniture->price * 2,
        ];

        $response = $this->postJson('/api/v1/orders', $payload);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'order' => [
                    'id',
                    'order_number',
                    'status',
                    'total',
                    'created_at',
                ],
            ]);

        $orderNumber = $response->json('order.order_number');

        // Verify lookup by order number
        $lookup = $this->getJson("/api/v1/orders/{$orderNumber}");
        $lookup->assertStatus(200)
            ->assertJson([
                'success' => true,
                'order' => [
                    'order_number' => $orderNumber,
                    'shipping_first_name' => 'Maria',
                    'shipping_last_name' => 'Santos',
                ],
            ]);
    }

    /**
     * Test validation failure on invalid order request.
     */
    public function test_order_validation_fails_on_missing_shipping(): void
    {
        $response = $this->postJson('/api/v1/orders', [
            'payment_method' => 'cod',
            'items' => [],
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['shipping.first_name', 'shipping.email', 'items']);
    }
}
