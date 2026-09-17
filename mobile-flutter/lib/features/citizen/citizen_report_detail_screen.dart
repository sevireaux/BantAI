import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../data/models/report.dart';
import '../../data/repositories/report_repository.dart';
import '../../widgets/severity_badge.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/status_badge.dart';

class CitizenReportDetailScreen extends StatefulWidget {
  const CitizenReportDetailScreen({super.key, required this.reportId});
  final String reportId;

  @override
  State<CitizenReportDetailScreen> createState() => _CitizenReportDetailScreenState();
}

class _CitizenReportDetailScreenState extends State<CitizenReportDetailScreen> {
  late Future<Report> _future;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _future = context.read<ReportRepository>().get(widget.reportId);
  }

  Future<void> _cancelReport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep report')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel report')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _cancelling = true);
    try {
      await ApiClient.instance.delete('/reports/${widget.reportId}');
      setState(() => _future = context.read<ReportRepository>().get(widget.reportId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : 'Could not cancel this report.')));
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.reportId)),
      body: FutureBuilder<Report>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final r = snapshot.data!;
          final editable = r.status == 'Pending' || r.status == 'Verified';

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Row(children: [StatusBadge(status: r.status), const SizedBox(width: 8), SeverityBadge(severity: r.severity, aiAssessed: r.severitySource == 'ai')]),
              const SizedBox(height: AppSpacing.md),
              Text(r.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('${r.category ?? ''} · ${r.subcategory ?? ''}', style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.description),
                    const SizedBox(height: AppSpacing.sm),
                    Text(r.address ?? 'No address provided', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    if (r.severityReasoning != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(AppRadius.input)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.auto_awesome, size: 14, color: AppColors.deep),
                            const SizedBox(width: 6),
                            Expanded(child: Text(r.severityReasoning!, style: const TextStyle(fontSize: 12, color: AppColors.deep))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (r.photos.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: r.photos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      child: CachedNetworkImage(imageUrl: r.photos[i], width: 90, height: 90, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text('Status timeline', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              SectionCard(
                child: Column(
                  children: r.history
                      .map((h) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(margin: const EdgeInsets.only(top: 4), width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(h.status, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text(DateFormat('MMM d, y · h:mm a').format(h.date), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                      if (h.note != null) Text(h.note!, style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              if (r.resolutionDescription != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text('Resolution', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                SectionCard(child: Text(r.resolutionDescription!)),
              ],
              if (editable) ...[
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton(
                  onPressed: _cancelling ? null : _cancelReport,
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                  child: _cancelling ? const Text('Cancelling…') : const Text('Cancel this report'),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}
