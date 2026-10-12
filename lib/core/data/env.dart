import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Acesso tipado ao `.env` (ver `.env.example`). Nunca logar estes valores.
abstract final class Env {
  static String get supabaseUrl => _get('SUPABASE_URL');
  static String get supabasePublishableKey => _get('SUPABASE_PUBLISHABLE_KEY');
  static String get revenueCatAndroidKey => _get('REVENUECAT_API_KEY_ANDROID');
  static String get revenueCatIosKey => _get('REVENUECAT_API_KEY_IOS');

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static String _get(String key) =>
      dotenv.isInitialized ? (dotenv.env[key] ?? '') : '';
}
