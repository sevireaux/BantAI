import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../data/repositories/report_sync_service.dart';

/// Consistent card wrapper used for every grouped block of content across
/// the app — keeps the 12px radius / border / padding combination from
/// being redeclared (and drifting) screen by screen.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: padding ?? const EdgeInsets.all(AppSpacing.md), child: child),
    );
  }
}

/// A thin, persistent banner reflecting the offline queue's state. Fades in
/// only when there's something to say (queued reports, or a sync in
/// progress) — silent the rest of the time, per the "not exaggerated"
/// animation brief.
class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<ReportSyncService>();

    return AnimatedSize(
      duration: AppMotion.base,
      curve: AppMotion.curve,
      child: sync.lastKnownQueueLength == 0 && !sync.isSyncing
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              color: AppColors.secondary.withValues(alpha: 0.25),
              child: Row(
                children: [
                  if (sync.isSyncing)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.deep),
                    )
                  else
                    const Icon(Icons.cloud_off, size: 16, color: AppColors.deep),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      sync.isSyncing
                          ? 'Sending queued reports…'
                          : '${sync.lastKnownQueueLength} report${sync.lastKnownQueueLength == 1 ? '' : 's'} saved offline — will send automatically once you\'re online.',
                      style: const TextStyle(fontSize: 12, color: AppColors.deep, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.sm),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
