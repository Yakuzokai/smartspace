<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Furniture;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class OrderController extends Controller
{
    /**
     * Store a new furniture order.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'shipping.first_name' => 'required|string|max:100',
            'shipping.last_name' => 'required|string|max:100',
            'shipping.email' => 'required|email|max:150',
            'shipping.phone' => 'required|string|max:50',
            'shipping.address_line1' => 'required|string|max:255',
            'shipping.address_line2' => 'nullable|string|max:255',
            'shipping.city' => 'required|string|max:100',
            'shipping.province' => 'nullable|string|max:100',
            'shipping.postal_code' => 'nullable|string|max:20',
            'shipping.notes' => 'nullable|string|max:1000',
            'payment_method' => 'required|string|in:cod,gcash,card',
            'items' => 'required|array|min:1',
            'items.*.furniture_id' => 'required|integer',
            'items.*.quantity' => 'required|integer|min:1',
            'subtotal' => 'nullable|numeric',
            'shipping_fee' => 'nullable|numeric',
            'discount_amount' => 'nullable|numeric',
            'total' => 'nullable|numeric',
        ]);

        $shipping = $validated['shipping'];
        $orderNumber = 'ORD-' . date('Ymd') . '-' . strtoupper(Str::random(4));

        try {
            DB::beginTransaction();

            $order = Order::create([
                'order_number' => $orderNumber,
                'user_id' => $request->user()?->id,
                'status' => 'confirmed',
                'payment_method' => $validated['payment_method'],
                'payment_status' => $validated['payment_method'] === 'cod' ? 'pending' : 'paid',
                'subtotal' => $validated['subtotal'] ?? 0,
                'shipping_fee' => $validated['shipping_fee'] ?? 0,
                'discount_amount' => $validated['discount_amount'] ?? 0,
                'total_amount' => $validated['total'] ?? 0,
                'shipping_first_name' => $shipping['first_name'],
                'shipping_last_name' => $shipping['last_name'],
                'shipping_email' => $shipping['email'],
                'shipping_phone' => $shipping['phone'],
                'shipping_address_line1' => $shipping['address_line1'],
                'shipping_address_line2' => $shipping['address_line2'] ?? null,
                'shipping_city' => $shipping['city'],
                'shipping_province' => $shipping['province'] ?? 'Metro Manila',
                'shipping_postal_code' => $shipping['postal_code'] ?? null,
                'notes' => $shipping['notes'] ?? null,
            ]);

            foreach ($validated['items'] as $item) {
                $furniture = Furniture::find($item['furniture_id']);
                $unitPrice = $furniture ? (float) $furniture->price : (float) ($item['price'] ?? 0);
                $qty = (int) $item['quantity'];

                OrderItem::create([
                    'order_id' => $order->id,
                    'furniture_id' => $item['furniture_id'],
                    'quantity' => $qty,
                    'unit_price' => $unitPrice,
                    'total_price' => $unitPrice * $qty,
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Order placed successfully.',
                'order' => [
                    'id' => $order->id,
                    'order_number' => $order->order_number,
                    'status' => $order->status,
                    'total' => $order->total_amount,
                    'created_at' => $order->created_at->toIso8601String(),
                ],
            ], 201);
        } catch (\Throwable $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Could not process order: ' . $e->getMessage(),
                'order' => [
                    'order_number' => $orderNumber,
                ],
            ], 500);
        }
    }

    /**
     * Get order details by order number.
     */
    public function show(string $orderNumber): JsonResponse
    {
        $order = Order::with(['items.furniture.images', 'items.furniture.category'])
            ->where('order_number', $orderNumber)
            ->first();

        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'order' => $order,
        ]);
    }
}
