import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

enum StatusType { success, error, info }

class StatusCard extends StatelessWidget {
  final StatusType type;
  final String message;

  const StatusCard({
    super.key,
    required this.type,
    required this.message,
  });

  Color get _color => switch (type) {
    StatusType.success => AppTheme.success,
    StatusType.error   => AppTheme.error,
    StatusType.info    => AppTheme.accent,
  };

  IconData get _icon => switch (type) {
    StatusType.success => Icons.check_circle_rounded,
    StatusType.error   => Icons.error_rounded,
    StatusType.info    => Icons.info_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.dmSans(
                color: AppTheme.textPrimary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}