import 'package:supabase_flutter/supabase_flutter.dart';

import '../../engine/models.dart';
import '../people.dart';

class GroupMember {
  const GroupMember({
    required this.id,
    required this.name,
    this.birthDate,
    this.sex,
    this.avatarPath,
    this.allergies = const [],
  });

  final String id;
  final String name;
  final DateTime? birthDate;
  final Sex? sex;
  final String? avatarPath;
  final List<PersonAllergy> allergies;
}

/// Dados do formulário de membro; [id] nulo = novo membro.
class MemberDraft {
  const MemberDraft({
    this.id,
    required this.name,
    this.birthDate,
    this.sex,
    this.allergies = const [],
  });

  final String? id;
  final String name;
  final DateTime? birthDate;
  final Sex? sex;
  final List<PersonAllergy> allergies;
}

abstract interface class GroupRepository {
  Future<List<GroupMember>> list();

  /// Cria ou atualiza com as alergias, numa transação.
  /// Lança [FreeMemberLimitReached] se o plano não permitir.
  Future<String> save(MemberDraft draft);
  Future<void> delete(String memberId);
}

class SupabaseGroupRepository implements GroupRepository {
  SupabaseGroupRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<GroupMember>> list() async {
    final rows = await _client
        .from('group_members')
        .select('id, name, birth_date, sex, avatar_url')
        .order('created_at');
    if (rows.isEmpty) return const [];

    final allergyRows = await _client
        .from('person_allergens')
        .select('person_id, allergen_code, severity')
        .eq('person_type', 'member')
        .inFilter('person_id', [for (final r in rows) r['id']]);

    return [
      for (final row in rows)
        GroupMember(
          id: row['id'] as String,
          name: row['name'] as String,
          birthDate: dateFromDb(row['birth_date']),
          sex: Sex.fromCode(row['sex'] as String?),
          avatarPath: row['avatar_url'] as String?,
          allergies: allergiesFromRows(
            allergyRows.where((a) => a['person_id'] == row['id']),
          ),
        ),
    ];
  }

  @override
  Future<String> save(MemberDraft draft) async {
    try {
      return await _client.rpc<String>(
        'save_group_member',
        params: {
          'p_id': draft.id,
          'p_name': draft.name,
          'p_birth_date': dateToDb(draft.birthDate),
          'p_sex': draft.sex?.code,
          'p_allergies': allergiesToJson(draft.allergies),
        },
      );
    } on PostgrestException catch (e) {
      if (e.hint == 'free_member_limit') throw const FreeMemberLimitReached();
      rethrow;
    }
  }

  @override
  Future<void> delete(String memberId) =>
      _client.from('group_members').delete().eq('id', memberId);
}
