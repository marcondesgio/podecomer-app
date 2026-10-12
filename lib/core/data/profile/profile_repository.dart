import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../engine/models.dart';
import '../people.dart';

/// Perfil do titular da conta.
class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.plan,
    this.birthDate,
    this.avatarPath,
    this.healthConsentAt,
    this.allergies = const [],
  });

  final String id;
  final String name;
  final Plan plan;
  final DateTime? birthDate;

  /// Caminho no bucket `avatars` (privado; exibir com URL assinada).
  final String? avatarPath;
  final DateTime? healthConsentAt;
  final List<PersonAllergy> allergies;

  /// Onboarding concluído (LGPD).
  bool get hasHealthConsent => healthConsentAt != null;
}

abstract interface class ProfileRepository {
  Future<Profile> fetch();
  Future<void> update({required String name, DateTime? birthDate});

  /// Consentimento + alergias do titular, numa transação.
  Future<void> completeOnboarding(List<PersonAllergy> allergies);
  Future<void> saveAllergies(List<PersonAllergy> allergies);

  /// Envia a foto (JPEG) e devolve o caminho salvo.
  Future<String> uploadAvatar(Uint8List jpegBytes);

  /// URL temporária para exibir um arquivo do bucket `avatars`.
  Future<String> avatarUrl(String path);

  /// Apaga arquivos, dados e o usuário do Auth (Edge Function).
  Future<void> deleteAccount();

  /// Atualiza `plan` a partir do RevenueCat logo após compra/restauração,
  /// sem esperar o webhook (Edge Function `sync-subscription`).
  Future<void> syncSubscription();
}

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  String get _userId =>
      _client.auth.currentUser?.id ?? (throw StateError('Sem sessão.'));

  @override
  Future<Profile> fetch() async {
    final userId = _userId;
    final row = await _client
        .from('profiles')
        .select('id, name, birth_date, avatar_url, plan, health_consent_at')
        .eq('id', userId)
        .single();
    final allergies = await _client
        .from('person_allergens')
        .select('allergen_code, severity')
        .eq('person_type', 'profile')
        .eq('person_id', userId);
    final consent = row['health_consent_at'] as String?;

    return Profile(
      id: userId,
      name: row['name'] as String? ?? '',
      plan: Plan.fromCode(row['plan'] as String?),
      birthDate: dateFromDb(row['birth_date']),
      avatarPath: row['avatar_url'] as String?,
      healthConsentAt: consent == null ? null : DateTime.parse(consent),
      allergies: allergiesFromRows(allergies),
    );
  }

  @override
  Future<void> update({required String name, DateTime? birthDate}) => _client
      .from('profiles')
      .update({'name': name, 'birth_date': dateToDb(birthDate)})
      .eq('id', _userId);

  @override
  Future<void> completeOnboarding(List<PersonAllergy> allergies) => _client.rpc(
    'complete_onboarding',
    params: {'p_allergies': allergiesToJson(allergies)},
  );

  @override
  Future<void> saveAllergies(List<PersonAllergy> allergies) => _client.rpc(
    'set_person_allergens',
    params: {
      'p_person_type': 'profile',
      'p_person_id': _userId,
      'p_allergies': allergiesToJson(allergies),
    },
  );

  @override
  Future<String> uploadAvatar(Uint8List jpegBytes) async {
    final userId = _userId;
    final previous = await _client
        .from('profiles')
        .select('avatar_url')
        .eq('id', userId)
        .single();
    // Nome novo a cada envio: a URL muda e a foto antiga não fica em cache.
    final path = '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bucket = _client.storage.from('avatars');
    await bucket.uploadBinary(
      path,
      jpegBytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg'),
    );
    await _client
        .from('profiles')
        .update({'avatar_url': path})
        .eq('id', userId);
    if (previous['avatar_url'] case final String old when old != path) {
      await bucket.remove([old]);
    }
    return path;
  }

  @override
  Future<String> avatarUrl(String path) =>
      _client.storage.from('avatars').createSignedUrl(path, 60 * 60);

  @override
  Future<void> syncSubscription() async {
    final response = await _client.functions.invoke('sync-subscription');
    if (response.status != 200) {
      throw StateError('sync-subscription: ${response.status}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    final response = await _client.functions.invoke('delete-account');
    if (response.status != 200) {
      throw StateError('delete-account: ${response.status}');
    }
    // A sessão local não vale mais; limpa sem chamar o servidor.
    await _client.auth.signOut(scope: SignOutScope.local);
  }
}
