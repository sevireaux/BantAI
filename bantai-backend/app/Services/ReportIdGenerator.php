<?php

namespace App\Services;

use App\Models\Report;

class ReportIdGenerator
{
    public static function next(): string
    {
        $year = now()->year;
        $count = Report::where('id', 'like', "RPT-{$year}-%")->count();

        return sprintf('RPT-%d-%06d', $year, $count + 1);
    }
}
