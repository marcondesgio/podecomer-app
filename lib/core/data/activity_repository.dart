import 'package:supabase_flutter/supabase_flutter.dart';

import '../engine/verdict_status.dart';

/// `public.verdict_status`.
String verdictStatusCode(VerdictStatus status) => switch (status) {
  VerdictStatus.safe => 'seguro',
  VerdictStatus.caution => 'atencao',
  VerdictStatus.doNotConsume => 'nao_consumir',
  VerdictStatus.inconclusive => 'inconclusivo',
};

/// Histórico de scans e "Isso está errado?". Ficam só no banco do usuário
/// (RLS); nunca em logs ou analytics.
abstract interface class ActivityRepository {
  Future<void> saveScan(String barcode, VerdictStatus groupStatus);
  Future<void> report(String barcode, String message);
}

class SupabaseActivityRepository implements ActivityRepository {
  SupabaseActivityRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> saveScan(String barcode, VerdictStatus groupStatus) =>
      _client.from('scans').insert({
        'barcode': barcode,
        'group_status': verdictStatusCode(groupStatus),
      });

  @override
  Future<void> report(String barcode, String message) =>
      _client.from('reports').insert({'barcode': barcode, 'message': message});
}
