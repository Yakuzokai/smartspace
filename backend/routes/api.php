<?php

use App\Http\Controllers\Api\V1\AIController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CategoryController;
use App\Http\Controllers\Api\V1\FavoriteController;
use App\Http\Controllers\Api\V1\FurnitureController;
use App\Http\Controllers\Api\V1\RoomProjectController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes — SmartSpace v1
|--------------------------------------------------------------------------
*/

use App\Http\Controllers\Api\V1\SystemHealthController;

Route::prefix('v1')->group(function () {

    // 1. Basic Health & Aggregated System Telemetry (Milestone 7)
    Route::get('/health', function () {
        return response()->json([
            'status' => 'healthy',
            'service' => 'SmartSpace Backend API',
            'timestamp' => now()->toIso8601String(),
        ]);
    });
    Route::get('/system/health', [SystemHealthController::class, 'show']);

    // 2. Public Authentication Endpoints
    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);
    });

    // 3. Public Furniture Catalog & Categories
    Route::get('/categories', [CategoryController::class, 'index']);
    Route::get('/categories/{idOrSlug}', [CategoryController::class, 'show']);

    Route::get('/furniture', [FurnitureController::class, 'index']);
    Route::get('/furniture/featured', [FurnitureController::class, 'featured']);
    Route::get('/furniture/styles', [FurnitureController::class, 'styles']);
    Route::get('/furniture/{id}', [FurnitureController::class, 'show']);

    // 4. Protected Endpoints (Requires Sanctum Authentication)
    Route::middleware('auth:sanctum')->group(function () {
        // Authenticated User Profile & Logout
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);

        // Room Design Projects
        Route::get('/room-projects', [RoomProjectController::class, 'index']);
        Route::post('/room-projects', [RoomProjectController::class, 'store']);
        Route::get('/room-projects/{id}', [RoomProjectController::class, 'show']);
        Route::put('/room-projects/{id}', [RoomProjectController::class, 'update']);
        Route::put('/room-projects/{id}/layout', [RoomProjectController::class, 'updateLayout']);
        Route::post('/room-projects/{id}/validate', [RoomProjectController::class, 'validateLayout']);
        Route::delete('/room-projects/{id}', [RoomProjectController::class, 'destroy']);

        // Customer Favorites
        Route::get('/favorites', [FavoriteController::class, 'index']);
        Route::post('/favorites/toggle/{furnitureId}', [FavoriteController::class, 'toggle']);

        // AI Perception & Recommendations (Milestone 6)
        Route::post('/ai/analyze-room', [AIController::class, 'analyzeRoom']);
        Route::post('/ai/recommendations', [AIController::class, 'recommendations']);
    });
});
