<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Validation\ValidatesRequests;

// NOTE: this REPLACES the minimal base Controller Laravel 11 generates by
// default — the framework's version doesn't include AuthorizesRequests,
// which every controller here needs for $this->authorize(...) calls.
abstract class Controller
{
    use AuthorizesRequests, ValidatesRequests;
}
