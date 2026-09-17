import 'package:flutter/material.dart';
import '../core/theme.dart';

const Map<String, Color> _severityColors = {
  'Low': AppColors.severityLow,
  'Moderate': AppColors.severityModerate,
  'High': AppColors.severityHigh,
  'Critical': AppColors.severityCritical,
};

/// Shows a report's AI-assessed severity. Deliberately visually distinct
/// from StatusBadge (solid fill vs. outline) so "how bad is this" and
/// "where is this in the process" are never confused at a glance.
class SeverityBadge extends StatelessWidget {
  const SeverityBadge({super.key, required this.severity, this.aiAssessed = true, this.compact = false});

  final String severity;
  final bool aiAssessed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _severityColors[severity] ?? AppColors.textMuted;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : AppSpacing.sm, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadius.chip)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (aiAssessed) ...[
            const Icon(Icons.auto_awesome, size: 11, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            severity,
            style: TextStyle(color: Colors.white, fontSize: compact ? 10 : 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
