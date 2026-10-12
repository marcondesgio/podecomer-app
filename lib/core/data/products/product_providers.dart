import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../activity_repository.dart';
import '../allergen_engine_provider.dart';
import '../household.dart';
import '../supabase_providers.dart';
import 'off_cache.dart';
import 'open_food_facts_client.dart';
import 'own_products_source.dart';
import 'product_lookup_result.dart';
import 'product_record.dart';
import 'product_repository.dart';
import 'safe_alternatives.dart';

final productRepositoryProvider = FutureProvider<ProductRepository>((
  ref,
) async {
  final engine = await ref.watch(allergenEngineProvider.future);
  final httpClient = http.Client();
  ref.onDispose(httpClient.close);

  return ProductRepository(
    // Sem Supabase configurado (.env vazio) isto lança, e a consulta aparece
    // como falha com "Tentar de novo".
    ownProducts: SupabaseOwnProductsSource(ref.watch(supabaseClientProvider)),
    openFoodFacts: OpenFoodFactsClient(
      httpClient: httpClient,
      cache: SharedPreferencesOffCache(SharedPreferencesAsync()),
      mapTags: engine.dictionary.allergensFromOffTags,
    ),
  );
});

/// Consulta de um código de barras. Para tentar de novo:
/// `ref.invalidate(productLookupProvider(barcode))`.
final productLookupProvider = FutureProvider.autoDispose
    .family<ProductLookupResult, String>((ref, barcode) async {
      final repository = await ref.watch(productRepositoryProvider.future);
      return repository.lookup(barcode);
    });

final safeAlternativesRepositoryProvider =
    FutureProvider<SafeAlternativesRepository>((ref) async {
      final engine = await ref.watch(allergenEngineProvider.future);
      final client = ref.watch(supabaseClientProvider);
      final httpClient = http.Client();
      ref.onDispose(httpClient.close);
      return SafeAlternativesRepository(
        ownProducts: SupabaseOwnProductsSource(client),
        openFoodFacts: OpenFoodFactsClient(
          httpClient: httpClient,
          cache: SharedPreferencesOffCache(SharedPreferencesAsync()),
          mapTags: engine.dictionary.allergensFromOffTags,
        ),
        scanCounts: SupabaseScanCounts(client),
      );
    });

/// Alternativas SEGURAS para as pessoas selecionadas (até 5).
final safeAlternativesProvider = FutureProvider.autoDispose
    .family<List<ProductRecord>, String>((ref, barcode) async {
      final excluded = ref.watch(excludedPeopleProvider);
      final lookup = await ref.watch(productLookupProvider(barcode).future);
      if (lookup is! ProductFound) return const [];
      final people = selectPeople(
        await ref.watch(householdProvider.future),
        excluded,
      );
      final engine = await ref.watch(allergenEngineProvider.future);
      final repository = await ref.watch(
        safeAlternativesRepositoryProvider.future,
      );
      return repository.find(
        product: lookup.record,
        people: people,
        engine: engine,
      );
    });

final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => SupabaseActivityRepository(ref.watch(supabaseClientProvider)),
);
