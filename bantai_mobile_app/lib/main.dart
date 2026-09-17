import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'data/local/app_database.dart';
import 'data/repositories/auth_provider.dart';
import 'data/repositories/directory_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/report_repository.dart';
import 'data/repositories/report_sync_service.dart';
import 'features/auth/login_screen.dart';
import 'features/shared/app_shell.dart';

void main() {
  runApp(const BantaiApp());
}

class BantaiApp extends StatelessWidget {
  const BantaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AppDatabase is the single source of truth for the offline queue —
        // provided once, at the top, so every repository below shares the
        // same Drift connection.
        Provider<AppDatabase>(create: (_) => AppDatabase(), dispose: (_, db) => db.close()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()..restoreSession()),
        ProxyProvider<AppDatabase, ReportRepository>(update: (_, db, __) => ReportRepository(db)),
        ProxyProvider<AppDatabase, DirectoryRepository>(update: (_, db, __) => DirectoryRepository(db)),
        Provider<NotificationRepository>(create: (_) => NotificationRepository()),
        ChangeNotifierProxyProvider<ReportRepository, ReportSyncService>(
          create: (context) => ReportSyncService(context.read<ReportRepository>())..start(),
          update: (_, repo, previous) => previous ?? (ReportSyncService(repo)..start()),
        ),
      ],
      child: MaterialApp(
        title: 'BantAI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _RootRouter(),
      ),
    );
  }
}

/// Decides between the login screen and the main app shell based on
/// restored session state — waits for restoreSession() so a returning user
/// never sees a login flash before landing on their dashboard.
class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return auth.isAuthenticated ? const AppShell() : const LoginScreen();
  }
}
