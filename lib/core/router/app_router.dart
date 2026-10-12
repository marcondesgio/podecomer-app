import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/password_screens.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/group/presentation/group_screen.dart';
import '../../features/group/presentation/member_form_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screens.dart';
import '../../features/paywall/presentation/paywall_screen.dart';
import '../../features/product_submission/presentation/product_submission_screen.dart';
import '../../features/profile/presentation/profile_allergies_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/result/presentation/result_screen.dart';
import '../../features/scanner/presentation/scanner_screen.dart';
import '../data/scan_metrics.dart';
import 'home_shell.dart';
import 'routes.dart';
import 'session.dart';

export 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  // O roteador é criado uma vez; mudanças de sessão só reavaliam o redirect.
  final session = ValueNotifier<SessionStatus>(ref.read(sessionStatusProvider));
  ref.listen(sessionStatusProvider, (_, next) => session.value = next);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.home,
    refreshListenable: session,
    redirect: (context, state) =>
        sessionRedirect(session.value, state.uri.path),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(path: AppRoutes.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(path: AppRoutes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (_, _) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, _) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingAllergies,
        builder: (_, _) => const OnboardingAllergiesScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingGroup,
        builder: (_, _) => const OnboardingGroupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.group,
                builder: (_, _) => const GroupScreen(),
                routes: [
                  // Telas cheias, por cima da barra inferior.
                  GoRoute(
                    path: 'member/new',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const MemberFormScreen(),
                  ),
                  GoRoute(
                    path: 'member/:id',
                    parentNavigatorKey: _rootKey,
                    builder: (_, state) =>
                        MemberFormScreen(memberId: state.pathParameters['id']),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'allergies',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const ProfileAllergiesScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.paywall,
        builder: (_, _) => const PaywallScreen(),
      ),
      // Tela cheia: a câmera só fica ligada enquanto o scanner está aberto.
      GoRoute(
        path: AppRoutes.scanner,
        builder: (_, _) => const ScannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (_, state) => ResultScreen(
          barcode: state.pathParameters['barcode']!,
          trace: state.extra is ScanTrace ? state.extra! as ScanTrace : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.productSubmission,
        builder: (_, state) =>
            ProductSubmissionScreen(barcode: state.pathParameters['barcode']!),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    session.dispose();
  });
  return router;
});
