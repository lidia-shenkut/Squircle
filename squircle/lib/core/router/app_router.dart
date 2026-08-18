import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/memory_wall/presentation/screens/memory_wall_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/games/presentation/screens/games_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/mood/presentation/screens/mood_screen.dart';

part 'app_router.g.dart';

// Route names
class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const verify = '/verify';
  static const forgotPassword = '/forgot-password';
  static const onboarding = '/onboarding';
  static const groupList = '/groups';
  static const createGroup = '/groups/create';
  static const joinGroup = '/groups/join';
  static const groupHome = '/groups/:groupId';
  static const invite = '/groups/:groupId/invite';
  static const chat = '/groups/:groupId/chat';
  static const memoryWall = '/groups/:groupId/memory';
  static const events = '/groups/:groupId/events';
  static const games = '/groups/:groupId/games';
  static const analytics = '/groups/:groupId/analytics';
  static const mood = '/groups/:groupId/mood';
  static const profileEdit = '/profile/edit';
}

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnAuthPage = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.verify;

      if (!isLoggedIn && !isOnAuthPage) return AppRoutes.login;
      if (isLoggedIn && isOnAuthPage) return AppRoutes.groupList;
      return null;
    },
    routes: [
      // Auth
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: AppRoutes.verify, builder: (_, __) => const VerifyScreen()),
      GoRoute(path: AppRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),

      // Groups
      GoRoute(path: AppRoutes.groupList, builder: (_, __) => const GroupListScreen()),
      GoRoute(path: AppRoutes.createGroup, builder: (_, __) => const CreateGroupScreen()),
      GoRoute(path: AppRoutes.joinGroup, builder: (_, __) => const JoinGroupScreen()),
      GoRoute(
        path: AppRoutes.groupHome,
        builder: (_, state) => GroupHomeScreen(groupId: state.pathParameters['groupId']!),
        routes: [
          GoRoute(
            path: 'invite',
            builder: (_, state) => InviteScreen(groupId: state.pathParameters['groupId']!),
          ),
          GoRoute(
            path: 'chat',
            builder: (_, state) => ChatScreen(groupId: state.pathParameters['groupId']!),
          ),
          GoRoute(
            path: 'memory',
            builder: (_, state) => MemoryWallScreen(groupId: state.pathParameters['groupId']!),
          ),
          GoRoute(
            path: 'events',
            builder: (_, state) => EventsScreen(groupId: state.pathParameters['groupId']!),
          ),
          GoRoute(
            path: 'games',
            builder: (_, state) => GamesScreen(groupId: state.pathParameters['groupId']!),
          ),
          GoRoute(
            path: 'analytics',
            builder: (_, state) => AnalyticsScreen(groupId: state.pathParameters['groupId']!),
          ),
          GoRoute(
            path: 'mood',
            builder: (_, state) => MoodScreen(groupId: state.pathParameters['groupId']!),
          ),
        ],
      ),

      // Profile
      GoRoute(path: AppRoutes.profileEdit, builder: (_, __) => const ProfileEditScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
}
