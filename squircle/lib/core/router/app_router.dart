import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/verify_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/profile/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_edit_screen.dart';
import '../../features/groups/presentation/screens/group_list_screen.dart';
import '../../features/groups/presentation/screens/group_home_screen.dart';
import '../../features/groups/presentation/screens/create_group_screen.dart';
import '../../features/groups/presentation/screens/join_group_screen.dart';
import '../../features/groups/presentation/screens/invite_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const verify = '/verify';
  static const forgotPassword = '/forgot-password';
  static const onboarding = '/onboarding';
  static const groupList = '/groups';
  static const createGroup = '/groups/create';
  static const joinGroup = '/groups/join';
  static const profileEdit = '/profile/edit';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final loc = state.matchedLocation;
      final isOnAuthPage = loc == AppRoutes.login ||
          loc == AppRoutes.register ||
          loc == AppRoutes.forgotPassword ||
          loc == AppRoutes.verify;

      if (!isLoggedIn && !isOnAuthPage) return AppRoutes.login;
      if (isLoggedIn && isOnAuthPage) return AppRoutes.groupList;
      return null;
    },
    routes: [
      // Auth
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: AppRoutes.verify, builder: (_, __) => const VerifyScreen()),
      GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, __) => const ForgotPasswordScreen()),

      // Onboarding
      GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, __) => const OnboardingScreen()),

      // Groups
      GoRoute(
          path: AppRoutes.groupList,
          builder: (_, __) => const GroupListScreen()),
      GoRoute(
          path: AppRoutes.createGroup,
          builder: (_, __) => const CreateGroupScreen()),
      GoRoute(
          path: AppRoutes.joinGroup,
          builder: (_, __) => const JoinGroupScreen()),

      // Group home with sub-routes
      GoRoute(
        path: '/groups/:groupId',
        builder: (_, state) =>
            GroupHomeScreen(groupId: state.pathParameters['groupId']!),
        routes: [
          GoRoute(
            path: 'invite',
            builder: (_, state) =>
                InviteScreen(groupId: state.pathParameters['groupId']!),
          ),
          GoRoute(
            path: 'analytics',
            builder: (_, state) =>
                AnalyticsScreen(groupId: state.pathParameters['groupId']!),
          ),
        ],
      ),

      // Profile
      GoRoute(
          path: AppRoutes.profileEdit,
          builder: (_, __) => const ProfileEditScreen()),
    ],
    errorBuilder: (context, state) => const LoginScreen(),
  );
});
