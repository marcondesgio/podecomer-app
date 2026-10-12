import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lança se o Supabase não foi inicializado (`.env` sem chaves).
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

/// Deep link de retorno do Supabase Auth (confirmação de e-mail, OAuth e
/// recuperação de senha). Precisa estar em Auth › URL Configuration ›
/// Redirect URLs no painel do Supabase.
const authRedirectUrl = 'com.podecomer.app://login-callback';
