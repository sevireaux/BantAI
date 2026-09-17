import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../data/models/report.dart';
import '../../data/repositories/auth_provider.dart';
import '../../data/repositories/report_repository.dart';
import '../../widgets/severity_badge.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/status_badge.dart';

class LguReportDetailScreen extends StatefulWidget {
  const LguReportDetailScreen({super.key, required this.reportId});
  final String reportId;

  @override
  State<LguReportDetailScreen> createState() => _LguReportDetailScreenState();
}

class _LguReportDetailScreenState extends State<LguReportDetailScreen> {
  late Future<Report> _future;
  bool _busy = false;
  final _resolveDescController = TextEditingController();
  final _justificationController = TextEditingController();
  final List<File> _resolvePhotos = [];

  @override
  void initState() {
    super.initState();
    _future = context.read<ReportRepository>().get(widget.reportId);
  }

  void _reload() => setState(() => _future = context.read<ReportRepository>().get(widget.reportId));

  Future<void> _run(Future<void> Function() action, {String? successMessage}) async {
    setState(() => _busy = true);
    try {
      await action();
      _reload();
      if (successMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ApiException ? e.message : 'That action failed.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify(String outcome, {String? reason}) => _run(() async {
        await ApiClient.instance.patch('/reports/${widget.reportId}/verify', data: {'outcome': outcome, if (reason != null) 'reason': reason});
      });

  Future<void> _updateStatus(String status) => _run(() async {
        await ApiClient.instance.patch('/reports/${widget.reportId}/status', data: {'status': status});
      });

  Future<void> _close() => _run(() async {
        await ApiClient.instance.patch('/reports/${widget.reportId}/close');
      });

  Future<void> _resolve() => _run(() async {
        final form = FormData.fromMap({
          'resolutionDescription': _resolveDescController.text.trim(),
          'photos': [for (final f in _resolvePhotos) await MultipartFile.fromFile(f.path)],
        });
        await ApiClient.instance.patch('/reports/${widget.reportId}/resolve', data: form);
      });

  Future<void> _barangayConfirm() => _run(() async {
        await ApiClient.instance.patch('/reports/${widget.reportId}/barangay-confirm', data: FormData.fromMap({}));
      }, successMessage: 'Confirmed locally.');

  Future<void> _endorsePriority() => _run(() async {
        await ApiClient.instance.patch('/reports/${widget.reportId}/endorse-priority', data: {'justification': _justificationController.text.trim()});
      }, successMessage: 'Endorsement submitted.');

  Future<void> _requestAttention(String reason) => _run(() async {
        await ApiClient.instance.patch('/reports/${widget.reportId}/request-attention', data: {'reason': reason});
      }, successMessage: 'LGU attention requested.');

  Future<void> _flagRecurring() => _run(() async {
        await ApiClient.instance.patch('/reports/${widget.reportId}/flag-recurring');
      }, successMessage: 'Flagged as recurring.');

  Future<void> _pickResolvePhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
    if (file != null) setState(() => _resolvePhotos.add(File(file.path)));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;

    return Scaffold(
      appBar: AppBar(title: Text(widget.reportId)),
      body: FutureBuilder<Report>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final r = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Row(children: [StatusBadge(status: r.status), const SizedBox(width: 8), SeverityBadge(severity: r.severity, aiAssessed: r.severitySource == 'ai')]),
              const SizedBox(height: AppSpacing.sm),
              Text(r.title, style: Theme.of(context).textTheme.titleLarge),
              Text('Reported by ${r.reporterName ?? 'a citizen'} · ${r.barangay ?? ''}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.description),
                  const SizedBox(height: AppSpacing.sm),
                  Text(r.address ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  Text('${r.similarReportCount} similar reports nearby', style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
              if (r.photos.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: r.photos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (_, i) => ClipRRect(borderRadius: BorderRadius.circular(AppRadius.input), child: CachedNetworkImage(imageUrl: r.photos[i], width: 80, height: 80, fit: BoxFit.cover)),
                  ),
                ),
              ],
              if (r.barangayConfirmed || r.priorityEndorsed || r.attentionRequested || r.recurringFlagged) ...[
                const SizedBox(height: AppSpacing.md),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  if (r.barangayConfirmed) _signalChip('✓ Confirmed by Barangay', AppColors.secondary),
                  if (r.priorityEndorsed) _signalChip('⚑ Priority endorsed', AppColors.accent),
                  if (r.attentionRequested) _signalChip('⚠ Attention requested', AppColors.danger),
                  if (r.recurringFlagged) _signalChip('↻ Recurring', AppColors.textMuted),
                ]),
              ],
              const SizedBox(height: AppSpacing.lg),

              // -- Barangay Administration panel --------------------------
              if (user.isBarangayAdmin && ['Pending', 'Verified', 'In Progress'].contains(r.status)) ...[
                Text('Barangay Administration', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                SectionCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    OutlinedButton(onPressed: _busy ? null : _barangayConfirm, child: const Text('Confirm locally')),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(controller: _justificationController, decoration: const InputDecoration(labelText: 'Endorsement justification'), maxLines: 2),
                    const SizedBox(height: AppSpacing.xs),
                    OutlinedButton(onPressed: _busy ? null : _endorsePriority, child: const Text('Endorse for higher priority')),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(spacing: 6, children: AttentionReason.options.map((reason) => ActionChip(label: Text(reason), onPressed: _busy ? null : () => _requestAttention(reason))).toList()),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(onPressed: _busy ? null : _flagRecurring, child: const Text('Flag as recurring')),
                  ]),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // -- LGU workflow panel --------------------------------------
              if (user.isLguStaff) ...[
                if (r.status == 'Pending') _actionCard('Verification needed', [
                  ElevatedButton(onPressed: _busy ? null : () => _verify('verified'), child: const Text('Verify')),
                  OutlinedButton(onPressed: _busy ? null : () => _verify('rejected', reason: 'Not a valid civic issue'), child: const Text('Reject')),
                ]),
                if (r.status == 'Verified') _actionCard('Ready to begin work', [
                  ElevatedButton(onPressed: _busy ? null : () => _updateStatus('In Progress'), child: const Text('Mark In Progress')),
                ]),
                if (r.status == 'In Progress')
                  SectionCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Resolve with evidence', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(controller: _resolveDescController, decoration: const InputDecoration(labelText: 'Resolution description'), maxLines: 2),
                      const SizedBox(height: AppSpacing.sm),
                      Row(children: [
                        ..._resolvePhotos.map((f) => Padding(padding: const EdgeInsets.only(right: 6), child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.file(f, width: 50, height: 50, fit: BoxFit.cover)))),
                        IconButton(onPressed: _pickResolvePhoto, icon: const Icon(Icons.add_a_photo_outlined)),
                      ]),
                      const SizedBox(height: AppSpacing.sm),
                      ElevatedButton(
                        onPressed: _busy || _resolveDescController.text.trim().isEmpty || _resolvePhotos.isEmpty ? null : _resolve,
                        child: const Text('Confirm resolved'),
                      ),
                    ]),
                  ),
                if (r.status == 'Resolved') _actionCard('Pending final review', [
                  ElevatedButton(onPressed: _busy ? null : _close, child: const Text('Close report')),
                ]),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }

  Widget _signalChip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.chip), border: Border.all(color: color.withValues(alpha: 0.4))),
        child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );

  Widget _actionCard(String title, List<Widget> actions) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: SectionCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: actions),
          ]),
        ),
      );
}
