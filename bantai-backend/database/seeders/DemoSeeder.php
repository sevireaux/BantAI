<?php

namespace Database\Seeders;

use App\Models\Barangay;
use App\Models\Lgu;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DemoSeeder extends Seeder
{
    public function run(): void
    {
        $lgu = Lgu::firstOrCreate(
            ['code' => 'QC'],
            ['name' => 'Quezon City LGU', 'region' => 'National Capital Region']
        );

        foreach (['Barangay Commonwealth', 'Barangay Batasan Hills'] as $name) {
            Barangay::firstOrCreate(['lgu_id' => $lgu->id, 'name' => $name]);
        }

        User::firstOrCreate(
            ['email' => 'citizen@example.com'],
            ['name' => 'Juana Dela Cruz', 'password' => Hash::make('Password123!'), 'role' => 'citizen']
        );

        $this->command->info('Demo LGU, barangays, and one citizen account created.');
        $this->command->info('No staff accounts were seeded — see README "Creating the first administrative account".');
    }
}
