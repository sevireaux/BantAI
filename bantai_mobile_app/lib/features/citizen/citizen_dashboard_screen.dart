import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/models/report.dart';
import '../../data/repositories/auth_provider.dart';
import '../../data/repositories/report_repository.dart';
import '../../widgets/severity_badge.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/status_badge.dart';
import 'citizen_report_detail_screen.dart';

class CitizenDashboardScreen extends StatefulWidget {
  const CitizenDashboardScreen({super.key});

  @override
  State<CitizenDashboardScreen> createState() => _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState extends State<CitizenDashboardScreen> {
  late Future<List<Report>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ReportRepository>().list();
  }

  Future<void> _refresh() async {
    setState(() => _future = context.read<ReportRepository>().list());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('BantAI')),
      body: Column(
        children: [
          const SyncStatusBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<Report>>(
                future: _future,
                builder: (context, snapshot) {
                  final reports = snapshot.data ?? [];
                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      Text('Welcome back, ${user?.name.split(' ').first ?? 'there'}',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: AppSpacing.md),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (reports.isEmpty)
                        const EmptyState(icon: Icons.assignment_outlined, message: 'You haven\'t reported anything yet.')
                      else
                        ...reports.take(6).map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: SectionCard(
                                child: InkWell(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => CitizenReportDetailScreen(reportId: r.id)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 4),
                                            Text('${r.id} · ${r.category ?? ''}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          StatusBadge(status: r.status),
                                          const SizedBox(height: 4),
                                          SeverityBadge(severity: r.severity, aiAssessed: r.severitySource == 'ai', compact: true),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
