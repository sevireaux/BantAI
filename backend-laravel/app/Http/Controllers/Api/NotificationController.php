<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ReportNotification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $notifications = ReportNotification::where('user_id', $request->user()->id)
            ->orderByDesc('created_at')->limit(200)->get();

        return response()->json(['notifications' => $notifications]);
    }

    public function markRead(Request $request, ReportNotification $notification)
    {
        if ($notification->user_id !== $request->user()->id) {
            return response()->json(['error' => 'Notification not found.'], 404);
        }
        $notification->update(['read' => true]);

        return response()->json(['notification' => $notification]);
    }

    public function markAllRead(Request $request)
    {
        ReportNotification::where('user_id', $request->user()->id)->update(['read' => true]);

        return response()->json(['success' => true]);
    }
}
