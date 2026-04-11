import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/share_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/qs_button.dart';
import '../../widgets/status_card.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  PlatformFile? _pickedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
      ref.read(uploadStateProvider.notifier).state = const AsyncData(null);
    }
  }

  Future<void> _upload() async {
    if (_pickedFile?.path == null) return;
    final uploadFn = ref.read(uploadFileProvider);
    await uploadFn(File(_pickedFile!.path!));
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadStateProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),

          _PickZone(
            pickedFile: _pickedFile,
            onTap: uploadState.isLoading ? null : _pickFile,
          ),

          const SizedBox(height: 20),

          QsButton(
            label: 'Upload & Generate Code',
            icon: Icons.cloud_upload_rounded,
            loading: uploadState.isLoading,
            disabled: _pickedFile == null || uploadState.isLoading,
            onPressed: _upload,
          ),

          const SizedBox(height: 24),

          uploadState.when(
            data: (code) => code != null
                ? _CodeCard(code: code)
                : const SizedBox.shrink(),
            loading: () => const _LoadingCard(),
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

class _PickZone extends StatelessWidget {
  final PlatformFile? pickedFile;
  final VoidCallback? onTap;

  const _PickZone({required this.pickedFile, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasFile = pickedFile != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 180,
        decoration: BoxDecoration(
          color: hasFile
              ? AppTheme.accent.withOpacity(0.08)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasFile ? AppTheme.accent : AppTheme.border,
            width: hasFile ? 1.5 : 1,
          ),
        ),
        child: hasFile
            ? _FileInfo(file: pickedFile!)
            : _EmptyPickHint(),
      ),
    );
  }
}

class _EmptyPickHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceAlt,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add_rounded,
              color: AppTheme.textSecond, size: 28),
        ),
        const SizedBox(height: 14),
        Text(
          'Tap to select a file',
          style: GoogleFonts.dmSans(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Any file type supported',
          style: GoogleFonts.dmSans(
            color: AppTheme.textMuted,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _FileInfo extends StatelessWidget {
  final PlatformFile file;
  const _FileInfo({required this.file});

  String get _size {
    final bytes = file.size;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file_rounded,
              color: AppTheme.accent, size: 40),
          const SizedBox(height: 12),
          Text(
            file.name,
            style: GoogleFonts.dmSans(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _size,
            style: GoogleFonts.dmSans(
              color: AppTheme.textSecond,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap to change file',
            style: GoogleFonts.dmSans(
              color: AppTheme.accent,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

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
            'Uploading your file…',
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

class _CodeCard extends StatefulWidget {
  final String code;
  const _CodeCard({required this.code});

  @override
  State<_CodeCard> createState() => _CodeCardState();
}

class _CodeCardState extends State<_CodeCard> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2),
            () => mounted ? setState(() => _copied = false) : null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.success.withOpacity(0.12),
            AppTheme.accent.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.success.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.success, size: 18),
              const SizedBox(width: 8),
              Text(
                'Upload successful!',
                style: GoogleFonts.dmSans(
                  color: AppTheme.success,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Share this code',
            style: GoogleFonts.dmSans(
              color: AppTheme.textSecond,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.code,
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textPrimary,
              fontSize: 44,
              fontWeight: FontWeight.w700,
              letterSpacing: 12,
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: _copy,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _copied
                    ? AppTheme.success.withOpacity(0.15)
                    : AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _copied
                      ? AppTheme.success.withOpacity(0.4)
                      : AppTheme.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _copied
                        ? Icons.check_rounded
                        : Icons.copy_rounded,
                    size: 15,
                    color: _copied
                        ? AppTheme.success
                        : AppTheme.textSecond,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    _copied ? 'Copied!' : 'Copy Code',
                    style: GoogleFonts.dmSans(
                      color: _copied
                          ? AppTheme.success
                          : AppTheme.textSecond,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
