import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Fallback if .env is missing in dev; will rely on compile-time environment or throw clear message
    }
  }

  static String get supabaseUrl {
    const fromDefine = String.fromEnvironment('SUPABASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    final fromFile = dotenv.env['SUPABASE_URL'];
    if (fromFile != null && fromFile.isNotEmpty) return fromFile;
    throw StateError(
      'SUPABASE_URL is not set. Please provide it in .env or pass via --dart-define=SUPABASE_URL=...',
    );
  }

  static String get supabaseAnonKey {
    const fromDefine = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    final fromFile = dotenv.env['SUPABASE_ANON_KEY'];
    if (fromFile != null && fromFile.isNotEmpty) return fromFile;
    throw StateError(
      'SUPABASE_ANON_KEY is not set. Please provide it in .env or pass via --dart-define=SUPABASE_ANON_KEY=...',
    );
  }
}
