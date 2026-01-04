import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page_new.dart';
import '../../features/home/presentation/pages/main_navigation_page.dart';
import '../../features/habits/presentation/pages/habits_page.dart';
import '../../features/habits/presentation/pages/add_habit_page.dart';
import '../../features/habits/presentation/pages/edit_habit_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/pages/settings/notifications_settings_page.dart';
import '../../features/profile/presentation/pages/settings/privacy_settings_page.dart';
import '../../features/profile/presentation/pages/settings/help_support_page.dart';
import '../../features/profile/presentation/pages/settings/settings_page.dart';
import '../../features/analytics/presentation/pages/analytics_page_new.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

// Admin
import '../../features/admin/presentation/pages/admin_access_page.dart';
import '../../features/admin/presentation/pages/admin_sign_in_page.dart';
import '../../features/admin/presentation/pages/admin_main_page.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';

// Leaderboard
import '../../features/leaderboard/presentation/pages/leaderboard_page.dart';

import '../di/injection_container.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static late GoRouter router;

  static GoRouter createRouter(AuthBloc authBloc) => GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: '/splash',
        refreshListenable: GoRouterRefreshStream(authBloc.stream),
        redirect: (context, state) {
          final authState = authBloc.state;
          final currentLocation = state.uri.toString();

          if (currentLocation == '/splash') return null;

          final isOnAuthPage = currentLocation == '/sign-in' ||
              currentLocation == '/sign-up' ||
              currentLocation == '/forgot-password' ||
              currentLocation == '/onboarding';

          if (authState.status == AuthStatus.loading && !isOnAuthPage) {
            return '/splash';
          }

          if (authState.status == AuthStatus.unauthenticated) {
            if (currentLocation.startsWith('/home') ||
                currentLocation.startsWith('/habits') ||
                currentLocation.startsWith('/profile') ||
                currentLocation.startsWith('/analytics') ||
                currentLocation.startsWith('/admin')) {
              return '/onboarding';
            }
          }

          if (authState.status == AuthStatus.authenticated) {
            if (currentLocation == '/onboarding' ||
                currentLocation == '/sign-in' ||
                currentLocation == '/sign-up' ||
                currentLocation == '/forgot-password') {
              return '/home';
            }

            if (currentLocation.startsWith('/admin') &&
                currentLocation != '/admin-access') {
              final user = authState.user;
              final isUserAdmin =
                  user?.isAdmin == true || user?.role == 'admin';

              if (!isUserAdmin) {
                return '/admin-access';
              }
            }
          }

          return null;
        },
        routes: [
          GoRoute(
            path: '/splash',
            builder: (context, state) => const SplashPage(),
          ),
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => const OnboardingPage(),
          ),
          GoRoute(
            path: '/sign-in',
            builder: (context, state) => const SignInPage(),
          ),
          GoRoute(
            path: '/sign-up',
            builder: (context, state) => const SignUpPage(),
          ),
          GoRoute(
            path: '/forgot-password',
            builder: (context, state) => const ForgotPasswordPage(),
          ),
          ShellRoute(
            navigatorKey: _shellNavigatorKey,
            builder: (context, state, child) =>
                MainNavigationPage(child: child),
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
              GoRoute(
                path: '/habits',
                builder: (context, state) => const HabitsPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddHabitPage(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (context, state) {
                      final habitId = state.pathParameters['id']!;
                      return EditHabitPage(habitId: habitId);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsPage(),
              ),
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => BlocProvider<ProfileBloc>(
                      create: (context) => sl<ProfileBloc>(),
                      child: const EditProfilePage(),
                    ),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsPage(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) =>
                        const NotificationsSettingsPage(),
                  ),
                  GoRoute(
                    path: 'privacy',
                    builder: (context, state) => const PrivacySettingsPage(),
                  ),
                  GoRoute(
                    path: 'help',
                    builder: (context, state) => const HelpSupportPage(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/leaderboard',
            builder: (context, state) => const LeaderboardPage(),
          ),
          ShellRoute(
            builder: (context, state, child) {
              return BlocProvider<AdminBloc>(
                create: (context) => sl<AdminBloc>(),
                child: child,
              );
            },
            routes: [
              GoRoute(
                path: '/admin/sign-in',
                builder: (context, state) => const AdminSignInPage(),
              ),
              GoRoute(
                path: '/admin/dashboard',
                builder: (context, state) => const AdminMainPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/admin-access',
            builder: (context, state) => const AdminAccessPage(),
          ),
        ],
      );
}
