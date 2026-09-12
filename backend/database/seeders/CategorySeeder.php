<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $hierarchy = [
            [
                'name' => 'Living Room',
                'slug' => 'living-room',
                'description' => 'Furniture and accessories for communal lounging and living spaces.',
                'icon' => 'couch',
                'children' => [
                    [
                        'name' => 'Sofas & Lounging',
                        'slug' => 'sofas-lounging',
                        'description' => '2-seaters, 3-seaters, modular sectionals, and daybeds.',
                        'icon' => 'sofa',
                    ],
                    [
                        'name' => 'Coffee & Side Tables',
                        'slug' => 'coffee-side-tables',
                        'description' => 'Low central tables, nesting sets, and side tables.',
                        'icon' => 'table',
                    ],
                    [
                        'name' => 'Media & TV Units',
                        'slug' => 'media-tv-units',
                        'description' => 'Entertainment centers, credenzas, and media benches.',
                        'icon' => 'tv',
                    ],
                    [
                        'name' => 'Accent & Storage Units',
                        'slug' => 'accent-storage',
                        'description' => 'Bookcases, room dividers, armchairs, and entryway units.',
                        'icon' => 'archive',
                    ],
                ],
            ],
            [
                'name' => 'Bedroom',
                'slug' => 'bedroom',
                'description' => 'Bedframes, storage beds, and nightstands for sleeping quarters.',
                'icon' => 'bed',
                'children' => [
                    [
                        'name' => 'Beds & Mattresses',
                        'slug' => 'beds-mattresses',
                        'description' => 'Single, queen, king, and platform storage beds.',
                        'icon' => 'bed-double',
                    ],
                    [
                        'name' => 'Nightstands & Bedside Storage',
                        'slug' => 'nightstands',
                        'description' => 'Compact bedside drawers, floating shelves, and nightstands.',
                        'icon' => 'clock',
                    ],
                ],
            ],
            [
                'name' => 'Home Office',
                'slug' => 'home-office',
                'description' => 'Desks, computer workstations, and ergonomic workspace furniture.',
                'icon' => 'laptop',
                'children' => [
                    [
                        'name' => 'Desks & Workstations',
                        'slug' => 'desks-workstations',
                        'description' => 'Compact writing desks, executive desks, and sit-stand desks.',
                        'icon' => 'briefcase',
                    ],
                ],
            ],
            [
                'name' => 'Dining',
                'slug' => 'dining',
                'description' => 'Dining tables and chairs for meals and entertaining.',
                'icon' => 'utensils',
                'children' => [
                    [
                        'name' => 'Dining Tables',
                        'slug' => 'dining-tables',
                        'description' => 'Circular, rectangular, and extendable dining tables.',
                        'icon' => 'table-restaurant',
                    ],
                    [
                        'name' => 'Dining Chairs',
                        'slug' => 'dining-chairs',
                        'description' => 'Ergonomic, upholstered, and minimalist dining seating.',
                        'icon' => 'chair',
                    ],
                ],
            ],
        ];

        foreach ($hierarchy as $parentData) {
            $children = $parentData['children'] ?? [];
            unset($parentData['children']);

            $parent = Category::firstOrCreate(['slug' => $parentData['slug']], $parentData);

            foreach ($children as $childData) {
                $childData['parent_id'] = $parent->id;
                Category::firstOrCreate(['slug' => $childData['slug']], $childData);
            }
        }
    }
}
