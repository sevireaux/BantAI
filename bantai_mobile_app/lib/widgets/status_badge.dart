import 'package:flutter/material.dart';
import '../core/theme.dart';

const Map<String, Color> _statusColors = {
  'Pending': AppColors.secondary,
  'Verified': Color(0xFF6B8FA3),
  'In Progress': AppColors.accent,
  'Resolved': AppColors.success,
  'Closed': AppColors.textMuted,
  'Rejected': AppColors.danger,
  'Duplicate': AppColors.textMuted,
  'Cancelled': AppColors.textMuted,
};

/// Pill badge for a report's workflow status. Uses AnimatedContainer so a
/// status change (e.g. after a sync or a pull-to-refresh) transitions
/// smoothly instead of snapping — one of the app's few, deliberately
/// understated animations.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColors[status] ?? AppColors.textMuted;
    final awaitingAction = status == 'Pending';

    return AnimatedContainer(
      duration: AppMotion.base,
      curve: AppMotion.curve,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Dot(color: color, pulse: awaitingAction),
          const SizedBox(width: 6),
          Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({required this.color, required this.pulse});
  final Color color;
  final bool pulse;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pulse) {
      return Container(width: 6, height: 6, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle));
    }
    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(_controller),
      child: Container(width: 6, height: 6, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
    );
  }
}
