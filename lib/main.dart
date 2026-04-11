import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hbamrhelmyzthsmanmyk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhiYW1yaGVsbXl6dGhzbWFubXlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2NzExNTQsImV4cCI6MjA5MTI0NzE1NH0.bF017_epNCLfyC8uoeq_oB6p9RyMHDCw3dzob5Bbq6Y',
  );

  runApp(
    const ProviderScope(
      child: QuickShareApp(),
    ),
  );
}

class QuickShareApp extends StatelessWidget {
  const QuickShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickShare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}