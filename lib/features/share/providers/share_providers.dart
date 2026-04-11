import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateProvider;
import '../models/share_model.dart';
import '../repositories/share_repository.dart';

final uploadStateProvider =
StateProvider<AsyncValue<String?>>((ref) => const AsyncData(null));

final uploadFileProvider = Provider<Future<void> Function(File)>((ref) {
  return (File file) async {
    ref.read(uploadStateProvider.notifier).state = const AsyncLoading();
    try {
      final repo = ref.read(shareRepositoryProvider);
      final code = await repo.uploadFile(file);
      ref.read(uploadStateProvider.notifier).state = AsyncData(code);
    } catch (e, st) {
      ref.read(uploadStateProvider.notifier).state = AsyncError(e, st);
    }
  };
});

final codeInputProvider = StateProvider<String>((ref) => '');

final fetchStateProvider =
StateProvider<AsyncValue<ShareModel?>>((ref) => const AsyncData(null));

final fetchFileProvider = Provider<Future<void> Function(String)>((ref) {
  return (String code) async {
    ref.read(fetchStateProvider.notifier).state = const AsyncLoading();
    try {
      final repo  = ref.read(shareRepositoryProvider);
      final share = await repo.fetchByCode(code);
      ref.read(fetchStateProvider.notifier).state = AsyncData(share);
    } catch (e, st) {
      ref.read(fetchStateProvider.notifier).state = AsyncError(e, st);
    }
  };
});