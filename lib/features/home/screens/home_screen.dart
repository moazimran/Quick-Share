import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../share/screens/upload_screen.dart';
import '../../share/screens/download_screen.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            _TabBar(controller: _tab),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: const [
                  UploadScreen(),
                  DownloadScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accentGlow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'QuickShare',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Share files instantly with a 6-digit code.',
            style: GoogleFonts.dmSans(
              color: AppTheme.textSecond,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: controller,
          indicator: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textSecond,
          dividerColor: Colors.transparent,
          labelStyle: GoogleFonts.dmSans(
              fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 14),
          tabs: const [
            Tab(
              height: 42,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_rounded, size: 17),
                  SizedBox(width: 7),
                  Text('Upload'),
                ],
              ),
            ),
            Tab(
              height: 42,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_download_rounded, size: 17),
                  SizedBox(width: 7),
                  Text('Download'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}