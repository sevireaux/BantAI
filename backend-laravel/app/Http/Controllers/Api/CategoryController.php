<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Subcategory;
use App\Services\AuditLogger;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index(Request $request)
    {
        $categories = Category::with('subcategories:id,category_id,name')
            ->where(function ($q) use ($request) {
                $q->whereNull('lgu_id');
                if ($request->user()?->lgu_id) {
                    $q->orWhere('lgu_id', $request->user()->lgu_id);
                }
            })
            ->orderBy('name')
            ->get(['id', 'name']);

        return response()->json(['categories' => $categories]);
    }

    public function store(Request $request)
    {
        $data = $request->validate(['name' => ['required', 'string', 'max:255']]);

        $category = Category::create(['lgu_id' => $request->user()->lgu_id, 'name' => $data['name']]);
        AuditLogger::log($request->user(), 'add_category', 'category', $category->id, [], $request);

        return response()->json(['category' => $category], 201);
    }

    public function storeSubcategory(Request $request)
    {
        $data = $request->validate([
            'categoryId' => ['required', 'uuid', 'exists:categories,id'],
            'name' => ['required', 'string', 'max:255'],
        ]);

        $subcategory = Subcategory::create(['category_id' => $data['categoryId'], 'name' => $data['name']]);
        AuditLogger::log($request->user(), 'add_subcategory', 'subcategory', $subcategory->id, $data, $request);

        return response()->json(['subcategory' => $subcategory], 201);
    }
}
