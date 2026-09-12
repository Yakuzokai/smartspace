<?php

namespace App\Services;

use App\Models\Furniture;
use App\Models\RoomProject;
use App\Models\RoomProjectFurniture;

class SpaceCompatibilityService
{
    /**
     * Epsilon value for numerical floating point stability.
     */
    private const EPSILON = 0.001;

    /**
     * Maximum points per category according to the thesis specification:
     * Total (100) = Boundary (30) + Collision (25) + Clearance (25) + Utilization (10) + Fitness (10)
     */
    public const MAX_BOUNDARY_SCORE = 30.0;
    public const MAX_COLLISION_SCORE = 25.0;
    public const MAX_CLEARANCE_SCORE = 25.0;
    public const MAX_UTILIZATION_SCORE = 10.0;
    public const MAX_FITNESS_SCORE = 10.0;

    /**
     * Mapping of room types to allowed/preferred furniture category slugs.
     */
    private const ROOM_CATEGORY_MATRIX = [
        'living_room' => [
            'sofas-lounging',
            'coffee-side-tables',
            'media-tv-units',
            'accent-storage',
        ],
        'bedroom' => [
            'beds-mattresses',
            'nightstands',
            'accent-storage',
            'desks-workstations',
        ],
        'home_office' => [
            'desks-workstations',
            'accent-storage',
            'sofas-lounging',
            'coffee-side-tables',
        ],
        'dining_room' => [
            'dining-tables',
            'dining-chairs',
            'accent-storage',
        ],
        'studio' => [
            'sofas-lounging',
            'coffee-side-tables',
            'media-tv-units',
            'beds-mattresses',
            'nightstands',
            'desks-workstations',
            'dining-tables',
            'dining-chairs',
            'accent-storage',
        ],
    ];

    /**
     * Evaluate a persisted RoomProject model and optionally update its scores in the database.
     *
     * @param RoomProject $project
     * @param bool $persist
     * @return array
     */
    public function evaluateProject(RoomProject $project, bool $persist = true): array
    {
        $placements = $project->furniturePlacements()->with('furniture.category')->get();

        $items = [];
        foreach ($placements as $placement) {
            $furniture = $placement->furniture;
            if (!$furniture) {
                continue;
            }

            $items[] = [
                'placement_id' => $placement->id,
                'furniture_id' => $furniture->id,
                'sku' => $furniture->sku,
                'name' => $furniture->name,
                'category_slug' => $furniture->category?->slug ?? '',
                'width_m' => (float) $furniture->width_m,
                'height_m' => (float) $furniture->height_m,
                'depth_m' => (float) $furniture->depth_m,
                'clearance_front_m' => (float) ($furniture->clearance_front_cm / 100),
                'clearance_side_m' => (float) ($furniture->clearance_side_cm / 100),
                'position_x' => (float) $placement->position_x,
                'position_y' => (float) $placement->position_y,
                'position_z' => (float) $placement->position_z,
                'rotation_y' => (float) $placement->rotation_y,
                'scale' => 1.0, // Fixed physical scale
            ];
        }

        $result = $this->evaluateLayout(
            (float) $project->width_cm,
            (float) $project->length_cm,
            (float) $project->height_cm,
            $project->room_type,
            $items
        );

        if ($persist) {
            $project->update([
                'compatibility_score' => $result['total_score'],
                'score_breakdown' => $result,
            ]);
        }

        return $result;
    }

    /**
     * Pure in-memory layout evaluation without database dependency.
     *
     * Coordinates are defined in Three.js room-centered right-handed space:
     * Room bounds: X in [-width/2, +width/2], Z in [-length/2, +length/2] in meters.
     *
     * @param float $roomWidthCm
     * @param float $roomLengthCm
     * @param float $roomHeightCm
     * @param string $roomType
     * @param array $placedItems
     * @return array
     */
    public function evaluateLayout(
        float $roomWidthCm,
        float $roomLengthCm,
        float $roomHeightCm,
        string $roomType,
        array $placedItems
    ): array {
        $roomWidthM = round($roomWidthCm / 100, 4);
        $roomLengthM = round($roomLengthCm / 100, 4);
        $roomHeightM = round($roomHeightCm / 100, 4);
        $roomAreaSqm = round($roomWidthM * $roomLengthM, 4);

        // Precompute 2D AABB bounding boxes for all placed items
        $boxes = [];
        foreach ($placedItems as $idx => $item) {
            $w = (float) ($item['width_m'] ?? ($item['width_cm'] / 100 ?? 1.0));
            $h = (float) ($item['height_m'] ?? ($item['height_cm'] / 100 ?? 1.0));
            $d = (float) ($item['depth_m'] ?? ($item['depth_cm'] / 100 ?? 1.0));

            $posX = (float) ($item['position_x'] ?? 0.0);
            $posY = (float) ($item['position_y'] ?? 0.0);
            $posZ = (float) ($item['position_z'] ?? 0.0);
            $rotDeg = (float) ($item['rotation_y'] ?? 0.0);

            $cFront = (float) ($item['clearance_front_m'] ?? (isset($item['clearance_front_cm']) ? $item['clearance_front_cm'] / 100 : 0.75));
            $cSide = (float) ($item['clearance_side_m'] ?? (isset($item['clearance_side_cm']) ? $item['clearance_side_cm'] / 100 : 0.60));

            $bounds = $this->compute2DBounds($w, $d, $posX, $posZ, $rotDeg);

            $boxes[] = [
                'index' => $idx,
                'sku' => $item['sku'] ?? "ITEM-{$idx}",
                'name' => $item['name'] ?? "Furniture {$idx}",
                'category_slug' => $item['category_slug'] ?? '',
                'width_m' => $w,
                'height_m' => $h,
                'depth_m' => $d,
                'footprint_sqm' => round($w * $d, 4),
                'position_x' => $posX,
                'position_y' => $posY,
                'position_z' => $posZ,
                'rotation_y' => $rotDeg,
                'clearance_front_m' => $cFront,
                'clearance_side_m' => $cSide,
                'min_x' => $bounds['min_x'],
                'max_x' => $bounds['max_x'],
                'min_z' => $bounds['min_z'],
                'max_z' => $bounds['max_z'],
            ];
        }

        // 1. Boundary Fit (30 pts)
        $boundaryResult = $this->checkBoundaryFit($roomWidthM, $roomLengthM, $roomHeightM, $boxes);

        // 2. Collision Detection (25 pts)
        $collisionResult = $this->checkCollisions($boxes);

        // 3. Functional Clearance (25 pts)
        $clearanceResult = $this->checkClearances($roomWidthM, $roomLengthM, $boxes);

        // 4. Space Utilization & Circulation (10 pts)
        $utilizationResult = $this->calculateUtilization($roomAreaSqm, $boxes);

        // 5. Room Type Fitness (10 pts)
        $fitnessResult = $this->evaluateRoomFitness($roomType, $boxes);

        // Total Score Calculation
        $totalScore = round(
            $boundaryResult['score'] +
            $collisionResult['score'] +
            $clearanceResult['score'] +
            $utilizationResult['score'] +
            $fitnessResult['score'],
            2
        );

        // Boundary or collision failures represent hard physical invalidity
        $isValid = ($boundaryResult['score'] > 0) && ($collisionResult['score'] > 0);

        $verdict = $this->formatVerdict($totalScore, $isValid);

        return [
            'total_score' => $totalScore,
            'is_valid' => $isValid,
            'verdict' => $verdict['title'],
            'badge' => $verdict['badge'],
            'description' => $verdict['description'],
            'room_dimensions' => [
                'width_m' => $roomWidthM,
                'length_m' => $roomLengthM,
                'height_m' => $roomHeightM,
                'area_sqm' => $roomAreaSqm,
            ],
            'item_count' => count($boxes),
            'breakdown' => [
                'boundary_fit' => $boundaryResult,
                'collision' => $collisionResult,
                'clearance' => $clearanceResult,
                'utilization' => $utilizationResult,
                'room_fitness' => $fitnessResult,
            ],
            'evaluation_notes' => $this->generateSummaryNotes($boundaryResult, $collisionResult, $clearanceResult, $utilizationResult, $fitnessResult),
        ];
    }

    /**
     * Computes the rotated 2D AABB bounding extents in meters.
     */
    public function compute2DBounds(float $w, float $d, float $posX, float $posZ, float $rotDeg): array
    {
        $rad = deg2rad($rotDeg);
        $halfW = $w / 2;
        $halfD = $d / 2;

        $corners = [
            [-$halfW, -$halfD],
            [$halfW, -$halfD],
            [$halfW, $halfD],
            [-$halfW, $halfD],
        ];

        $minX = INF;
        $maxX = -INF;
        $minZ = INF;
        $maxZ = -INF;

        foreach ($corners as [$cx, $cz]) {
            $rx = $cx * cos($rad) - $cz * sin($rad);
            $rz = $cx * sin($rad) + $cz * cos($rad);

            $worldX = $posX + $rx;
            $worldZ = $posZ + $rz;

            $minX = min($minX, $worldX);
            $maxX = max($maxX, $worldX);
            $minZ = min($minZ, $worldZ);
            $maxZ = max($maxZ, $worldZ);
        }

        return [
            'min_x' => round($minX, 4),
            'max_x' => round($maxX, 4),
            'min_z' => round($minZ, 4),
            'max_z' => round($maxZ, 4),
        ];
    }

    /**
     * Step 1: Boundary Fit Check (30 pts)
     * All items must reside completely within [-W/2, W/2] and [-L/2, L/2].
     */
    private function checkBoundaryFit(float $roomWidthM, float $roomLengthM, float $roomHeightM, array $boxes): array
    {
        $halfW = $roomWidthM / 2;
        $halfL = $roomLengthM / 2;
        $violations = [];

        foreach ($boxes as $box) {
            $breaches = [];

            if ($box['min_x'] < (-$halfW - self::EPSILON)) {
                $breaches['west_wall_breach_m'] = round(abs($box['min_x'] - (-$halfW)), 3);
            }
            if ($box['max_x'] > ($halfW + self::EPSILON)) {
                $breaches['east_wall_breach_m'] = round($box['max_x'] - $halfW, 3);
            }
            if ($box['min_z'] < (-$halfL - self::EPSILON)) {
                $breaches['north_wall_breach_m'] = round(abs($box['min_z'] - (-$halfL)), 3);
            }
            if ($box['max_z'] > ($halfL + self::EPSILON)) {
                $breaches['south_wall_breach_m'] = round($box['max_z'] - $halfL, 3);
            }
            if (($box['position_y'] + $box['height_m']) > ($roomHeightM + self::EPSILON)) {
                $breaches['ceiling_breach_m'] = round(($box['position_y'] + $box['height_m']) - $roomHeightM, 3);
            }

            if (!empty($breaches)) {
                $violations[] = [
                    'sku' => $box['sku'],
                    'name' => $box['name'],
                    'breaches' => $breaches,
                    'message' => "Item '{$box['name']}' exceeds the perimeter walls of the room.",
                ];
            }
        }

        $passed = empty($violations);

        return [
            'score' => $passed ? self::MAX_BOUNDARY_SCORE : 0.0,
            'max' => self::MAX_BOUNDARY_SCORE,
            'status' => $passed ? 'pass' : 'fail',
            'violation_count' => count($violations),
            'violations' => $violations,
        ];
    }

    /**
     * Step 2: Collision & Overlap Check (25 pts)
     * Detects pairwise 2D/3D intersections between furniture bounding boxes.
     */
    private function checkCollisions(array $boxes): array
    {
        $collisions = [];
        $count = count($boxes);

        for ($i = 0; $i < $count; $i++) {
            for ($j = $i + 1; $j < $count; $j++) {
                $a = $boxes[$i];
                $b = $boxes[$j];

                // 2D horizontal overlap check
                $xOverlap = ($a['min_x'] < $b['max_x'] - self::EPSILON) && ($a['max_x'] > $b['min_x'] + self::EPSILON);
                $zOverlap = ($a['min_z'] < $b['max_z'] - self::EPSILON) && ($a['max_z'] > $b['min_z'] + self::EPSILON);

                if ($xOverlap && $zOverlap) {
                    // Vertical overlap check
                    $aMinY = $a['position_y'];
                    $aMaxY = $a['position_y'] + $a['height_m'];
                    $bMinY = $b['position_y'];
                    $bMaxY = $b['position_y'] + $b['height_m'];

                    $yOverlap = ($aMinY < $bMaxY - self::EPSILON) && ($aMaxY > $bMinY + self::EPSILON);

                    if ($yOverlap) {
                        $collisions[] = [
                            'item_a' => ['sku' => $a['sku'], 'name' => $a['name']],
                            'item_b' => ['sku' => $b['sku'], 'name' => $b['name']],
                            'overlap_type' => '3D AABB Intersection',
                            'message' => "Physical collision detected between '{$a['name']}' and '{$b['name']}'.",
                        ];
                    }
                }
            }
        }

        $passed = empty($collisions);

        return [
            'score' => $passed ? self::MAX_COLLISION_SCORE : 0.0,
            'max' => self::MAX_COLLISION_SCORE,
            'status' => $passed ? 'pass' : 'fail',
            'collision_count' => count($collisions),
            'collisions' => $collisions,
        ];
    }

    /**
     * Step 3: Functional Clearance Check (25 pts)
     * Evaluates whether required front and side clearance corridors are maintained.
     */
    private function checkClearances(float $roomWidthM, float $roomLengthM, array $boxes): array
    {
        if (empty($boxes)) {
            return [
                'score' => self::MAX_CLEARANCE_SCORE,
                'max' => self::MAX_CLEARANCE_SCORE,
                'status' => 'pass',
                'warning_count' => 0,
                'warnings' => [],
            ];
        }

        $halfW = $roomWidthM / 2;
        $halfL = $roomLengthM / 2;
        $warnings = [];
        $totalPenalty = 0.0;

        foreach ($boxes as $i => $item) {
            $rotRad = deg2rad($item['rotation_y']);
            // Forward vector in right-handed Three.js (0 deg = +Z forward)
            $fwdX = sin($rotRad);
            $fwdZ = cos($rotRad);

            // Front edge center point
            $frontEdgeX = $item['position_x'] + $fwdX * ($item['depth_m'] / 2);
            $frontEdgeZ = $item['position_z'] + $fwdZ * ($item['depth_m'] / 2);

            $requiredClearance = $item['clearance_front_m'];
            $probes = 5; // Sample points along the clearance corridor
            $minObstructionDistance = $requiredClearance;

            for ($p = 1; $p <= $probes; $p++) {
                $dist = ($requiredClearance / $probes) * $p;
                $px = $frontEdgeX + $fwdX * $dist;
                $pz = $frontEdgeZ + $fwdZ * $dist;

                // Check wall collision
                if ($px < -$halfW || $px > $halfW || $pz < -$halfL || $pz > $halfL) {
                    $minObstructionDistance = min($minObstructionDistance, $dist);
                    break;
                }

                // Check other furniture intrusion into front clearance
                foreach ($boxes as $j => $other) {
                    if ($i === $j) {
                        continue;
                    }

                    if (
                        $px >= $other['min_x'] && $px <= $other['max_x'] &&
                        $pz >= $other['min_z'] && $pz <= $other['max_z']
                    ) {
                        $minObstructionDistance = min($minObstructionDistance, $dist);
                        break 2;
                    }
                }
            }

            if ($minObstructionDistance < $requiredClearance) {
                $deficit = $requiredClearance - $minObstructionDistance;
                $deficitRatio = $deficit / $requiredClearance;
                $penalty = round($deficitRatio * 5.0, 2); // Up to 5 pts deducted per item
                $totalPenalty += $penalty;

                $warnings[] = [
                    'sku' => $item['sku'],
                    'name' => $item['name'],
                    'required_clearance_m' => $requiredClearance,
                    'available_clearance_m' => round($minObstructionDistance, 2),
                    'deficit_m' => round($deficit, 2),
                    'penalty_pts' => $penalty,
                    'message' => "Front clearance zone for '{$item['name']}' is restricted (available: " . round($minObstructionDistance * 100) . " cm, required: " . round($requiredClearance * 100) . " cm).",
                ];
            }
        }

        $finalScore = max(0.0, round(self::MAX_CLEARANCE_SCORE - $totalPenalty, 2));

        return [
            'score' => $finalScore,
            'max' => self::MAX_CLEARANCE_SCORE,
            'status' => $finalScore >= 20.0 ? 'pass' : ($finalScore >= 10.0 ? 'warning' : 'poor'),
            'warning_count' => count($warnings),
            'warnings' => $warnings,
        ];
    }

    /**
     * Step 4: Circulation & Space Utilization (10 pts)
     * Evaluates walking room ratio: R_walk = (A_room - A_furniture) / A_room
     */
    private function calculateUtilization(float $roomAreaSqm, array $boxes): array
    {
        if ($roomAreaSqm <= 0.0) {
            return [
                'score' => 0.0,
                'max' => self::MAX_UTILIZATION_SCORE,
                'walking_ratio' => 0.0,
                'room_area_sqm' => 0.0,
                'furniture_area_sqm' => 0.0,
                'status' => 'fail',
            ];
        }

        $totalFurnitureArea = 0.0;
        foreach ($boxes as $box) {
            $totalFurnitureArea += $box['footprint_sqm'];
        }

        $walkingArea = max(0.0, $roomAreaSqm - $totalFurnitureArea);
        $walkingRatio = round($walkingArea / $roomAreaSqm, 4);
        $occupiedRatio = round($totalFurnitureArea / $roomAreaSqm, 4);

        // Utilization scoring table
        if ($walkingRatio >= 0.50) {
            $score = 10.0; // Optimal spaciousness
            $status = 'excellent';
        } elseif ($walkingRatio >= 0.40) {
            $score = 8.0; // Comfortable living layout
            $status = 'good';
        } elseif ($walkingRatio >= 0.30) {
            $score = 5.0; // Dense / compact layout
            $status = 'tight';
        } elseif ($walkingRatio >= 0.20) {
            $score = 2.0; // Very crowded
            $status = 'crowded';
        } else {
            $score = 0.0; // Severely over-furnished
            $status = 'overcrowded';
        }

        return [
            'score' => $score,
            'max' => self::MAX_UTILIZATION_SCORE,
            'walking_ratio' => $walkingRatio,
            'occupied_percentage' => round($occupiedRatio * 100, 1),
            'room_area_sqm' => round($roomAreaSqm, 2),
            'furniture_area_sqm' => round($totalFurnitureArea, 2),
            'status' => $status,
        ];
    }

    /**
     * Step 5: Room Type Fitness (10 pts)
     * Compares placed furniture categories against declared room archetype.
     */
    private function evaluateRoomFitness(string $roomType, array $boxes): array
    {
        if (empty($boxes)) {
            return [
                'score' => self::MAX_FITNESS_SCORE,
                'max' => self::MAX_FITNESS_SCORE,
                'matched_items' => 0,
                'total_items' => 0,
                'status' => 'pass',
            ];
        }

        $allowedCategories = self::ROOM_CATEGORY_MATRIX[$roomType] ?? self::ROOM_CATEGORY_MATRIX['studio'];
        $matchedCount = 0;
        $unmatched = [];

        foreach ($boxes as $box) {
            $cat = $box['category_slug'];
            if (empty($cat) || in_array($cat, $allowedCategories, true)) {
                $matchedCount++;
            } else {
                $unmatched[] = [
                    'sku' => $box['sku'],
                    'name' => $box['name'],
                    'category' => $cat,
                    'message' => "Item '{$box['name']}' ({$cat}) is atypical for a {$roomType}.",
                ];
            }
        }

        $total = count($boxes);
        $ratio = $total > 0 ? ($matchedCount / $total) : 1.0;
        $score = round($ratio * self::MAX_FITNESS_SCORE, 1);

        return [
            'score' => $score,
            'max' => self::MAX_FITNESS_SCORE,
            'matched_items' => $matchedCount,
            'total_items' => $total,
            'status' => $score >= 8.0 ? 'pass' : 'warning',
            'unmatched' => $unmatched,
        ];
    }

    /**
     * Categorize compatibility verdict based on certified score.
     */
    private function formatVerdict(float $score, bool $isValid): array
    {
        if (!$isValid || $score < 30.0) {
            return [
                'title' => 'Does Not Fit',
                'badge' => '🔴',
                'description' => 'Items collide or extend beyond room boundaries. Layout adjustment required.',
            ];
        }

        if ($score >= 90.0) {
            return [
                'title' => 'Excellent Fit',
                'badge' => '🟢',
                'description' => 'Optimal furniture arrangement with generous walking circulation and complete clearance compliance.',
            ];
        }

        if ($score >= 70.0) {
            return [
                'title' => 'Good Fit',
                'badge' => '🟢',
                'description' => 'Comfortable layout meeting standard accessibility clearances and perimeter boundaries.',
            ];
        }

        if ($score >= 50.0) {
            return [
                'title' => 'Limited Space',
                'badge' => '🟡',
                'description' => 'Arrangement is functional but has clearance pinch points and tight walking flow.',
            ];
        }

        return [
            'title' => 'Tight Fit',
            'badge' => '🟠',
            'description' => 'Noticeably cramped layout with restricted circulation corridors.',
        ];
    }

    /**
     * Generate natural language summary notes explaining the evaluation breakdown.
     */
    private function generateSummaryNotes(
        array $boundary,
        array $collision,
        array $clearance,
        array $utilization,
        array $fitness
    ): string {
        $notes = [];

        if ($boundary['status'] !== 'pass') {
            $notes[] = "Boundary breach: {$boundary['violation_count']} item(s) exceed room boundaries.";
        } else {
            $notes[] = "All items safely contained within room perimeter.";
        }

        if ($collision['status'] !== 'pass') {
            $notes[] = "Overlap detected: {$collision['collision_count']} furniture collision(s).";
        } else {
            $notes[] = "Zero collision overlaps.";
        }

        if ($clearance['warning_count'] > 0) {
            $notes[] = "{$clearance['warning_count']} clearance warning(s) detected.";
        } else {
            $notes[] = "Full front and side clearance corridors maintained.";
        }

        $notes[] = "Space utilization: {$utilization['occupied_percentage']}% occupied ({$utilization['status']} circulation).";

        return implode(' ', $notes);
    }
}
