<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;

class Report extends Model
{
    protected $keyType = 'string';
    public $incrementing = false;

    protected $fillable = [
        'id', 'client_uuid', 'user_id', 'lgu_id', 'barangay_id', 'category_id', 'subcategory_id',
        'title', 'description', 'address', 'lat', 'lng', 'status',
        'severity', 'severity_confidence', 'severity_source', 'severity_reasoning', 'severity_overridden_by',
        'cluster_id', 'similar_report_count',
        'verified_at', 'verified_by', 'resolved_at', 'resolved_by', 'closed_at', 'closed_by', 'cancelled_at',
        'resolution_description', 'resolution_date', 'invalid_reason',
        'barangay_confirmed', 'barangay_confirmed_at', 'barangay_confirmed_by', 'barangay_note',
        'priority_endorsed', 'priority_endorsement_reason', 'priority_endorsed_by',
        'attention_requested', 'attention_requested_reason', 'attention_requested_by',
        'recurring_flagged', 'recurring_flagged_by',
        'device_submitted_at',
    ];

    protected function casts(): array
    {
        return [
            'lat' => 'float',
            'lng' => 'float',
            'severity_confidence' => 'float',
            'barangay_confirmed' => 'boolean',
            'priority_endorsed' => 'boolean',
            'attention_requested' => 'boolean',
            'recurring_flagged' => 'boolean',
            'verified_at' => 'datetime',
            'resolved_at' => 'datetime',
            'closed_at' => 'datetime',
            'cancelled_at' => 'datetime',
            'resolution_date' => 'datetime',
            'barangay_confirmed_at' => 'datetime',
            'device_submitted_at' => 'datetime',
        ];
    }

    // -- Relationships ---------------------------------------------------
    public function user() { return $this->belongsTo(User::class); }
    public function lgu() { return $this->belongsTo(Lgu::class); }
    public function barangay() { return $this->belongsTo(Barangay::class); }
    public function category() { return $this->belongsTo(Category::class); }
    public function subcategory() { return $this->belongsTo(Subcategory::class); }
    public function cluster() { return $this->belongsTo(IssueCluster::class, 'cluster_id'); }
    public function photos() { return $this->hasMany(ReportPhoto::class); }
    public function statusHistory() { return $this->hasMany(StatusHistory::class)->orderBy('created_at'); }
    public function followers() { return $this->belongsToMany(User::class, 'report_followers'); }

    public function evidencePhotos()
    {
        return $this->photos()->where('kind', 'evidence');
    }

    public function resolutionPhotos()
    {
        return $this->photos()->whereIn('kind', ['resolution_before', 'resolution_after', 'resolution_document']);
    }

    public function barangayPhotos()
    {
        return $this->photos()->where('kind', 'barangay_evidence');
    }

    // -- Jurisdiction scope ------------------------------------------------
    // Role determines what a user may DO; jurisdiction determines what data
    // they may SEE. This mirrors the Node backend's canAccessReport(): a
    // System Admin sees everything, a citizen only their own, a Barangay
    // Administrator only their barangay, and LGU staff only their LGU.
    public function scopeVisibleTo(Builder $query, User $user): Builder
    {
        return match ($user->role) {
            'system_admin' => $query,
            'citizen' => $query->where('user_id', $user->id),
            'barangay_admin' => $query->where('barangay_id', $user->barangay_id),
            'lgu_official', 'lgu_admin' => $query->where('lgu_id', $user->lgu_id),
            default => $query->whereRaw('1 = 0'),
        };
    }
}
