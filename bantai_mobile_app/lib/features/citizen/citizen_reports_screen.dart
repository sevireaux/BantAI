import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/models/report.dart';
import '../../data/repositories/report_repository.dart';
import '../../widgets/severity_badge.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/status_badge.dart';
import 'citizen_report_detail_screen.dart';

class CitizenReportsScreen extends StatefulWidget {
  const CitizenReportsScreen({super.key});

  @override
  State<CitizenReportsScreen> createState() => _CitizenReportsScreenState();
}

class _CitizenReportsScreenState extends State<CitizenReportsScreen> {
  late Future<List<Report>> _future;
  String _statusFilter = 'All';

  static const _statuses = ['All', 'Pending', 'Verified', 'In Progress', 'Resolved', 'Closed'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<ReportRepository>().list(
          filters: _statusFilter == 'All' ? null : {'status': _statusFilter},
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: Column(
        children: [
          const SyncStatusBanner(),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              itemCount: _statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, i) {
                final s = _statuses[i];
                final selected = s == _statusFilter;
                return ChoiceChip(
                  label: Text(s),
                  selected: selected,
                  selectedColor: AppColors.accent,
                  labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontSize: 12),
                  onSelected: (_) => setState(() {
                    _statusFilter = s;
                    _load();
                  }),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(_load);
                await _future;
              },
              child: FutureBuilder<List<Report>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final reports = snapshot.data ?? [];
                  if (reports.isEmpty) {
                    return const EmptyState(icon: Icons.assignment_outlined, message: 'No reports match this filter.');
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: reports.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final r = reports[i];
                      return SectionCard(
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => CitizenReportDetailScreen(reportId: r.id)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  StatusBadge(status: r.status),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${r.id} · ${r.category ?? ''}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              const SizedBox(height: 8),
                              SeverityBadge(severity: r.severity, aiAssessed: r.severitySource == 'ai', compact: true),
                            ],
                          ),
                        ),
                      );
                    },
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
