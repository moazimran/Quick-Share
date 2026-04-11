import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/share_providers.dart';
import '../models/share_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/qs_button.dart';
import '../../widgets/status_card.dart';

class DownloadScreen extends ConsumerStatefulWidget {
  const DownloadScreen({super.key});

  @override
  ConsumerState<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends ConsumerState<DownloadScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    final code = _controller.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snack('Please enter a valid 6-digit code.', isError: true),
      );
      return;
    }
    final fetchFn = ref.read(fetchFileProvider);
    await fetchFn(code);
  }

  SnackBar _snack(String msg, {bool isError = false}) => SnackBar(
    content: Text(msg,
        style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14)),
    backgroundColor: isError ? AppTheme.error : AppTheme.success,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final fetchState = ref.watch(fetchStateProvider);
    final isLoading = fetchState.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),

          _SectionLabel(
            icon: Icons.pin_rounded,
            label: 'Enter your 6-digit code',
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: 10,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '——————',
              hintStyle: GoogleFonts.spaceGrotesk(
                color: AppTheme.textMuted,
                fontSize: 28,
                letterSpacing: 8,
              ),
            ),
            onChanged: (_) {
              if (ref.read(fetchStateProvider).hasValue) {
                ref.read(fetchStateProvider.notifier).state =
                const AsyncData(null);
              }
            },
          ),

          const SizedBox(height: 20),

          QsButton(
            label: 'Fetch File',
            icon: Icons.search_rounded,
            loading: isLoading,
            disabled: isLoading,
            onPressed: _fetch,
          ),

          const SizedBox(height: 24),

          fetchState.when(
            data: (share) => share != null
                ? _ResultCard(share: share)
                : const SizedBox.shrink(),
            loading: () => const _FetchingCard(),
            error: (e, _) => StatusCard(
              type: StatusType.error,
              message: e.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.accent),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: AppTheme.textSecond,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FetchingCard extends StatelessWidget {
  const _FetchingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Looking up code…',
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

class _ResultCard extends StatelessWidget {
  final ShareModel share;
  const _ResultCard({required this.share});

  Future<void> _downloadFile(
      String url, String fileName, BuildContext context) async {

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      PermissionStatus status;

      if (sdkInt >= 33) {
        status = PermissionStatus.granted;
      } else if (sdkInt >= 30) {
        status = await Permission.manageExternalStorage.request();
      } else {
        status = await Permission.storage.request();
      }

      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Storage permission denied. Settings mein ja ke allow karo.',
                style: GoogleFonts.dmSans(color: Colors.white),
              ),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
        return;
      }
    }

    Directory? dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final savePath = '${dir.path}/$fileName';

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Downloading $fileName...',
                  style: GoogleFonts.dmSans(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 60),
          backgroundColor: AppTheme.accent,
        ),
      );
    }

    try {
      await Dio().download(url, savePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Saved to Downloads/$fileName',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Download failed: ${e.toString()}',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _openUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    try {
      final launched =
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Browser open nahi hua',
                style: GoogleFonts.dmSans(color: Colors.white)),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}',
                style: GoogleFonts.dmSans(color: Colors.white)),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Choose an option',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                share.fileName,
                style: GoogleFonts.dmSans(
                  color: AppTheme.textSecond,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 28),

              _OptionTile(
                icon: Icons.download_rounded,
                iconColor: AppTheme.success,
                label: 'Download to Device',
                subtitle: 'Save in Downloads folder',
                onTap: () {
                  Navigator.pop(context);
                  _downloadFile(share.fileUrl, share.fileName, context);
                },
              ),

              const SizedBox(height: 12),

              _OptionTile(
                icon: Icons.open_in_browser_rounded,
                iconColor: AppTheme.accent,
                label: 'View in Browser',
                subtitle: 'Open with default browser',
                onTap: () {
                  Navigator.pop(context);
                  _openUrl(share.fileUrl, context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(0.1),
            AppTheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_zip_rounded,
                  color: AppTheme.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'File found',
                style: GoogleFonts.dmSans(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          _Divider(),
          const SizedBox(height: 16),

          _InfoRow(label: 'File name', value: share.fileName),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Shared on',
            value:
            '${share.createdAt.day}/${share.createdAt.month}/${share.createdAt.year}',
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Download File'),
              onPressed: () => _showOptions(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: iconColor.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.dmSans(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        color: AppTheme.textSecond,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: AppTheme.textMuted, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.dmSans(
            color: AppTheme.textMuted,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.dmSans(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppTheme.border,
    );
  }
}