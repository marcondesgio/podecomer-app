import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/app.dart';
import 'package:pode_comer/core/data/account_providers.dart';
import 'package:pode_comer/core/data/auth/auth_controller.dart';
import 'package:pode_comer/core/data/auth/auth_repository.dart';
import 'package:pode_comer/core/data/group/group_repository.dart';
import 'package:pode_comer/core/data/people.dart';
import 'package:pode_comer/core/data/profile/profile_repository.dart';
import 'package:pode_comer/core/engine/models.dart';

const confirmedUser = AppUser(
  id: 'user-1',
  email: 'ana@email.com',
  emailConfirmed: true,
);

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.currentUser});

  final _changes = StreamController<AuthChange>.broadcast();
  final calls = <String>[];

  @override
  AppUser? currentUser;

  @override
  Stream<AuthChange> get changes => _changes.stream;

  void emit(AuthEvent event, AppUser? user) {
    currentUser = user;
    _changes.add(AuthChange(event, user));
  }

  @override
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    calls.add('signUp:$name:$email');
    return true;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    calls.add('signIn:$email');
    if (email.startsWith('pendente')) {
      throw const AuthFailure(AuthFailureKind.emailNotConfirmed);
    }
    if (password != 'senha-certa') {
      throw const AuthFailure(AuthFailureKind.invalidCredentials);
    }
    emit(AuthEvent.signedIn, confirmedUser);
  }

  @override
  Future<void> signInWith(SocialProvider provider) async =>
      calls.add('oauth:${provider.name}');

  @override
  Future<void> resendVerification(String email) async =>
      calls.add('resend:$email');

  @override
  Future<void> refreshUser() async => calls.add('refresh');

  @override
  Future<void> sendPasswordReset(String email) async =>
      calls.add('reset:$email');

  @override
  Future<void> updatePassword(String password) async =>
      calls.add('updatePassword');

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    emit(AuthEvent.signedOut, null);
  }
}

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository(this.profile);

  Profile profile;
  final calls = <String>[];
  List<PersonAllergy>? onboardingAllergies;

  @override
  Future<Profile> fetch() async => profile;

  @override
  Future<void> update({required String name, DateTime? birthDate}) async {
    calls.add('update:$name');
    profile = _copy(name: name, birthDate: birthDate);
  }

  @override
  Future<void> completeOnboarding(List<PersonAllergy> allergies) async {
    onboardingAllergies = allergies;
    profile = _copy(consent: DateTime.utc(2026, 10, 8), allergies: allergies);
  }

  @override
  Future<void> saveAllergies(List<PersonAllergy> allergies) async {
    calls.add('saveAllergies');
    profile = _copy(allergies: allergies);
  }

  @override
  Future<String> uploadAvatar(Uint8List jpegBytes) async => 'user-1/a.jpg';

  @override
  Future<String> avatarUrl(String path) async => 'https://example.test/$path';

  @override
  Future<void> deleteAccount() async => calls.add('deleteAccount');

  /// Simula o RevenueCat: depois da compra, o plano vira Família.
  Plan? planAfterSync;

  @override
  Future<void> syncSubscription() async {
    calls.add('syncSubscription');
    if (planAfterSync case final plan?) {
      profile = Profile(
        id: profile.id,
        name: profile.name,
        plan: plan,
        birthDate: profile.birthDate,
        avatarPath: profile.avatarPath,
        healthConsentAt: profile.healthConsentAt,
        allergies: profile.allergies,
      );
    }
  }

  Profile _copy({
    String? name,
    DateTime? birthDate,
    DateTime? consent,
    List<PersonAllergy>? allergies,
  }) => Profile(
    id: profile.id,
    name: name ?? profile.name,
    plan: profile.plan,
    birthDate: birthDate ?? profile.birthDate,
    avatarPath: profile.avatarPath,
    healthConsentAt: consent ?? profile.healthConsentAt,
    allergies: allergies ?? profile.allergies,
  );
}

class FakeGroupRepository implements GroupRepository {
  FakeGroupRepository(this.profiles, [List<GroupMember>? members])
    : members = members ?? [];

  final FakeProfileRepository profiles;
  final List<GroupMember> members;
  var _nextId = 1;

  @override
  Future<List<GroupMember>> list() async => List.of(members);

  @override
  Future<String> save(MemberDraft draft) async {
    if (draft.id == null &&
        !profiles.profile.plan.allowsAnotherMember(members.length)) {
      throw const FreeMemberLimitReached();
    }
    final id = draft.id ?? 'm${_nextId++}';
    final member = GroupMember(
      id: id,
      name: draft.name,
      birthDate: draft.birthDate,
      sex: draft.sex,
      allergies: draft.allergies,
    );
    final index = members.indexWhere((m) => m.id == id);
    if (index < 0) {
      members.add(member);
    } else {
      members[index] = member;
    }
    return id;
  }

  @override
  Future<void> delete(String memberId) async =>
      members.removeWhere((m) => m.id == memberId);
}

Profile profileOf({
  String name = 'Ana',
  Plan plan = Plan.free,
  bool consent = true,
  List<PersonAllergy> allergies = const [],
}) => Profile(
  id: confirmedUser.id,
  name: name,
  plan: plan,
  healthConsentAt: consent ? DateTime.utc(2026) : null,
  allergies: allergies,
);

class AppHarness {
  AppHarness({
    AppUser? user,
    Profile? profile,
    List<GroupMember>? members,
    this.overrides = const [],
  }) : auth = FakeAuthRepository(currentUser: user),
       profiles = FakeProfileRepository(profile ?? profileOf()) {
    groups = FakeGroupRepository(profiles, members);
  }

  final FakeAuthRepository auth;
  final FakeProfileRepository profiles;
  late final FakeGroupRepository groups;

  /// Overrides extras (produtos, câmera, histórico...).
  final List<Override> overrides;

  Future<void> pump(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profiles),
          groupRepositoryProvider.overrideWithValue(groups),
          ...overrides,
        ],
        child: const PodeComerApp(),
      ),
    );
    await tester.pumpAndSettle();
  }
}
