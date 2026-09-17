<?php

namespace App\Livewire\Organizations;

use App\Models\Barangay;
use App\Models\Lgu;
use App\Services\AuditLogger;
use Livewire\Component;

class Index extends Component
{
    public string $lguName = '';
    public string $lguRegion = '';
    public string $lguCode = '';

    public ?string $selectedLguId = null;
    public string $barangayName = '';

    public function createLgu(): void
    {
        $this->validate([
            'lguName' => ['required', 'string'],
            'lguCode' => ['required', 'string', 'unique:lgus,code'],
        ]);

        $lgu = Lgu::create(['name' => $this->lguName, 'region' => $this->lguRegion ?: null, 'code' => $this->lguCode]);
        AuditLogger::log(auth()->user(), 'create_lgu', 'lgu', $lgu->id, [], request());

        $this->reset(['lguName', 'lguRegion', 'lguCode']);
        $this->selectedLguId = $lgu->id;
    }

    public function createBarangay(): void
    {
        if (! $this->selectedLguId || $this->barangayName === '') {
            return;
        }

        $barangay = Barangay::create(['lgu_id' => $this->selectedLguId, 'name' => $this->barangayName]);
        AuditLogger::log(auth()->user(), 'create_barangay', 'barangay', $barangay->id, [], request());

        $this->barangayName = '';
    }

    public function render()
    {
        $lgus = Lgu::orderBy('name')->get();
        $barangays = $this->selectedLguId ? Barangay::where('lgu_id', $this->selectedLguId)->orderBy('name')->get() : collect();

        return view('livewire.organizations.index', compact('lgus', 'barangays'))
            ->layout('layouts.admin', ['title' => 'LGUs & Barangays']);
    }
}
