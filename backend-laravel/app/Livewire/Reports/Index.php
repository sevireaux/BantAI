<?php

namespace App\Livewire\Reports;

use App\Models\Report;
use Livewire\Component;
use Livewire\WithPagination;

class Index extends Component
{
    use WithPagination;

    public string $status = 'All';
    public string $search = '';

    public function render()
    {
        $query = Report::with('category', 'barangay')->visibleTo(auth()->user());

        if ($this->status !== 'All') {
            $query->where('status', $this->status);
        }
        if ($this->search !== '') {
            $term = "%{$this->search}%";
            $query->where(fn ($q) => $q->where('title', 'ilike', $term)->orWhere('id', 'ilike', $term));
        }

        $reports = $query->orderByDesc('created_at')->paginate(20);

        return view('livewire.reports.index', compact('reports'))->layout('layouts.admin', ['title' => 'Reports']);
    }
}
