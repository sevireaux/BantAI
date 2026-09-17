<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Subcategory;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    private const CATEGORIES = [
        'Roads' => [
            'Pothole', 'Damaged road', 'Flooded road', 'Damaged sidewalk',
            'Road obstruction', 'Damaged traffic sign', 'Broken street infrastructure',
        ],
        'Waste' => [
            'Uncollected garbage', 'Illegal dumping', 'Overflowing garbage bin',
            'Improper waste disposal', 'Waste accumulation',
        ],
        'Environment' => [
            'Water pollution', 'Air pollution', 'Illegal burning', 'Fallen trees',
            'Drainage/environmental obstruction', 'Other environmental concerns',
        ],
        'Public Safety' => [
            'Broken streetlight', 'Dangerous obstruction', 'Unsafe public infrastructure',
            'Traffic-related hazard', 'Open manhole', 'Other public safety concern',
        ],
    ];

    public function run(): void
    {
        foreach (self::CATEGORIES as $name => $subcategories) {
            $category = Category::firstOrCreate(['lgu_id' => null, 'name' => $name]);
            foreach ($subcategories as $sub) {
                Subcategory::firstOrCreate(['category_id' => $category->id, 'name' => $sub]);
            }
        }
    }
}
