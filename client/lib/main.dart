import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'presentation/router/app_router.dart';
import 'data/datasources/local/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize seed data service
  // In production, this would initialize Drift DB and seed if needed
  await SeedDataService.initialize();
  
  runApp(
    const ProviderScope(
      child: CapacityConnectApp(),
    ),
  );
}

class CapacityConnectApp extends ConsumerWidget {
  const CapacityConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
