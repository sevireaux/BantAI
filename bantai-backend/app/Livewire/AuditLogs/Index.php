<?php

namespace App\Livewire\AuditLogs;

use App\Models\AuditLog;
use Livewire\Component;
use Livewire\WithPagination;

class Index extends Component
{
    use WithPagination;

    public function render()
    {
        $logs = AuditLog::with('user:id,name,email')->orderByDesc('created_at')->paginate(30);

        return view('livewire.audit-logs.index', compact('logs'))->layout('layouts.admin', ['title' => 'Audit Logs']);
    }
}
