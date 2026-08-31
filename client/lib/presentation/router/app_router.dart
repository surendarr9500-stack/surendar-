import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/splash_page.dart';
import '../pages/login_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/troubleshooting_page.dart';
import '../pages/digital_twin_page.dart';
import '../pages/training_page.dart';
import '../pages/diagnostics_page.dart';
import '../pages/documents_page.dart';
import '../pages/search_page.dart';
import '../pages/settings_page.dart';
import '../pages/sync_status_page.dart';
import '../pages/admin_page.dart';
import '../pages/quiz_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/troubleshooting',
        builder: (context, state) => const TroubleshootingPage(),
      ),
      GoRoute(
        path: '/digital-twin',
        builder: (context, state) {
          final meshId = state.uri.queryParameters['meshId'];
          final componentId = state.uri.queryParameters['componentId'];
          return DigitalTwinPage(
            highlightMeshId: meshId,
            highlightComponentId: componentId,
          );
        },
      ),
      GoRoute(
        path: '/training',
        builder: (context, state) => const TrainingPage(),
      ),
      GoRoute(
        path: '/training/:courseId',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return TrainingDetailPage(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/diagnostics',
        builder: (context, state) => const DiagnosticsPage(),
      ),
      GoRoute(
        path: '/documents',
        builder: (context, state) => const DocumentsPage(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/sync',
        builder: (context, state) => const SyncStatusPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPage(),
      ),
      GoRoute(
        path: '/quiz/:quizId',
        builder: (context, state) {
          final quizId = state.pathParameters['quizId']!;
          return QuizPage(quizId: quizId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});
