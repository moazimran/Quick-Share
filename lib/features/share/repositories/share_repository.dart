import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../models/share_model.dart';

final shareRepositoryProvider = Provider<ShareRepository>((_) => ShareRepository());

class ShareRepository {
  static const String _table   = 'shares';
  static const String _bucket  = 'quick-share-files';

  String _generateCode() {
    final rng = Random.secure();
    return (100000 + rng.nextInt(900000)).toString();
  }

  Future<String> _uniqueCode() async {
    String code;
    bool exists;
    do {
      code = _generateCode();
      final result = await supabase
          .from(_table)
          .select('code')
          .eq('code', code)
          .maybeSingle();
      exists = result != null;
    } while (exists);
    return code;
  }

  Future<String> uploadFile(File file) async {
    final fileName  = p.basename(file.path);
    final code      = await _uniqueCode();
    final storagePath = '$code/$fileName';

    await supabase.storage
        .from(_bucket)
        .upload(storagePath, file,
        fileOptions: const FileOptions(upsert: false));

    final fileUrl = supabase.storage.from(_bucket).getPublicUrl(storagePath);

    await supabase.from(_table).insert({
      'code'      : code,
      'file_url'  : fileUrl,
      'file_name' : fileName,
    });

    return code;
  }

  Future<ShareModel> fetchByCode(String code) async {
    final result = await supabase
        .from(_table)
        .select()
        .eq('code', code.trim())
        .maybeSingle();

    if (result == null) {
      throw CodeNotFoundException('No file found for code: $code');
    }

    return ShareModel.fromJson(result as Map<String, dynamic>);
  }
}

class CodeNotFoundException implements Exception {
  final String message;
  const CodeNotFoundException(this.message);

  @override
  String toString() => message;
}