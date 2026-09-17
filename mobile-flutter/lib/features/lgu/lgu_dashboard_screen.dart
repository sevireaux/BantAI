import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../widgets/shared_widgets.dart';

class LguDashboardScreen extends StatefulWidget {
  const LguDashboardScreen({super.key});

  @override
  State<LguDashboardScreen> createState() => _LguDashboardScreenState();
}

class _LguDashboardScreenState extends State<LguDashboardScreen> {
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.instance.get('/dashboard/summary');
      setState(() => _summary = res);
    } catch (_) {
      // leave null — UI shows a friendly empty state below
    }
  }

  int _countFor(String key, String value) {
    final list = (_summary?[key] as List?) ?? [];
    for (final row in list) {
      if (row['status'] == value || row['severity'] == value) return (row['count'] as num).toInt();
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _summary == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.6,
                    children: [
                      _kpi('Pending', _countFor('statusCounts', 'Pending'), AppColors.secondary),
                      _kpi('In Progress', _countFor('statusCounts', 'In Progress'), AppColors.accent),
                      _kpi('Resolved', _countFor('statusCounts', 'Resolved'), AppColors.success),
                      _kpi('Critical severity', _countFor('severityCounts', 'Critical'), AppColors.severityCritical),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Avg. verification: ${_summary?['averageVerificationHours'] ?? '—'} hrs · Avg. resolution: ${_summary?['averageResolutionHours'] ?? '—'} hrs',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
      ),
    );
  }

  Widget _kpi(String label, int value, Color color) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$value', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
