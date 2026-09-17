import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/models/models.dart';
import '../../data/repositories/notification_repository.dart';
import '../../widgets/shared_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<AppNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<NotificationRepository>().list();
  }

  Future<void> _markAllRead() async {
    await context.read<NotificationRepository>().markAllRead();
    setState(() => _future = context.read<NotificationRepository>().list());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), actions: [
        TextButton(onPressed: _markAllRead, child: const Text('Mark all read')),
      ]),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = context.read<NotificationRepository>().list());
          await _future;
        },
        child: FutureBuilder<List<AppNotification>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final items = snapshot.data ?? [];
            if (items.isEmpty) return const EmptyState(icon: Icons.notifications_none, message: 'No notifications yet.');
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final n = items[i];
                return SectionCard(
                  child: InkWell(
                    onTap: () async {
                      if (!n.read) await context.read<NotificationRepository>().markRead(n.id);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4, right: AppSpacing.sm),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: n.read ? Colors.transparent : AppColors.accent, shape: BoxShape.circle),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(n.message, style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(DateFormat('MMM d, h:mm a').format(n.date), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
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
