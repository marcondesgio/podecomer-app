import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_controller.dart';
import 'group/group_repository.dart';
import 'profile/profile_repository.dart';
import 'supabase_providers.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SupabaseProfileRepository(ref.watch(supabaseClientProvider)),
);

final groupRepositoryProvider = Provider<GroupRepository>(
  (ref) => SupabaseGroupRepository(ref.watch(supabaseClientProvider)),
);

/// Id do usuário logado; muda → perfil e grupo recarregam.
final _userIdProvider = Provider<String?>(
  (ref) => ref.watch(authControllerProvider.select((s) => s.user?.id)),
);

final myProfileProvider = FutureProvider<Profile>((ref) {
  if (ref.watch(_userIdProvider) == null) throw StateError('Sem sessão.');
  return ref.watch(profileRepositoryProvider).fetch();
});

final groupMembersProvider = FutureProvider<List<GroupMember>>((ref) {
  if (ref.watch(_userIdProvider) == null) throw StateError('Sem sessão.');
  return ref.watch(groupRepositoryProvider).list();
});

/// URL assinada de uma foto do bucket `avatars`.
final avatarUrlProvider = FutureProvider.family<String, String>(
  (ref, path) => ref.watch(profileRepositoryProvider).avatarUrl(path),
);
