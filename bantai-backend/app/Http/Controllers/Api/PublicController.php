<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Barangay;
use App\Models\Lgu;
use Illuminate\Http\Request;

class PublicController extends Controller
{
    public function lgus()
    {
        return response()->json(['lgus' => Lgu::select('id', 'name', 'region', 'code')->orderBy('name')->get()]);
    }

    public function barangays(Request $request)
    {
        $request->validate(['lguId' => ['required', 'uuid']]);

        $barangays = Barangay::where('lgu_id', $request->query('lguId'))
            ->select('id', 'name')
            ->orderBy('name')
            ->get();

        return response()->json(['barangays' => $barangays]);
    }
}
