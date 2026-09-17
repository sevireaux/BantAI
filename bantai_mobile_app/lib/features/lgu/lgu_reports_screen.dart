import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/models/report.dart';
import '../../data/repositories/report_repository.dart';
import '../../widgets/severity_badge.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/status_badge.dart';
import 'lgu_report_detail_screen.dart';

class LguReportsScreen extends StatefulWidget {
  const LguReportsScreen({super.key});

  @override
  State<LguReportsScreen> createState() => _LguReportsScreenState();
}

class _LguReportsScreenState extends State<LguReportsScreen> {
  late Future<List<Report>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ReportRepository>().list();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = context.read<ReportRepository>().list());
          await _future;
        },
        child: FutureBuilder<List<Report>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final reports = snapshot.data ?? [];
            if (reports.isEmpty) return const EmptyState(icon: Icons.inbox_outlined, message: 'No reports in your jurisdiction yet.');
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final r = reports[i];
                return SectionCard(
                  child: InkWell(
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => LguReportDetailScreen(reportId: r.id)))
                        .then((_) => setState(() => _future = context.read<ReportRepository>().list())),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(child: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                                if (r.attentionRequested) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.priority_high, size: 16, color: AppColors.danger)),
                              ]),
                              const SizedBox(height: 4),
                              Text('${r.id} · ${r.barangay ?? r.category ?? ''}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          StatusBadge(status: r.status),
                          const SizedBox(height: 4),
                          SeverityBadge(severity: r.severity, compact: true),
                        ]),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
