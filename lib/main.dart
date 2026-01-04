import 'package:demo_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection_container.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/utils/system_ui_config.dart';
import 'core/utils/data_preload.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/habits/presentation/bloc/habit_bloc.dart';
import 'features/profile/presentation/bloc/settings/settings_bloc.dart';
import 'features/profile/presentation/bloc/settings/settings_event.dart';
import 'features/profile/presentation/bloc/settings/settings_state.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI
  SystemUIConfig.configureSystemUI();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize dependency injection
  await configureDependencies();

  // Initialize and request notification permissions
  final notificationService = GetIt.instance<NotificationService>();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const WellnessFlowApp());
}

class WellnessFlowApp extends StatefulWidget {
  const WellnessFlowApp({super.key});

  @override
  State<WellnessFlowApp> createState() => _WellnessFlowAppState();
}

class _WellnessFlowAppState extends State<WellnessFlowApp> {
  String? _primedUserId;

  @override
  Widget build(BuildContext context) {
    final authBloc = GetIt.instance<AuthBloc>();

    // Initialize router with auth bloc
    AppRouter.router = AppRouter.createRouter(authBloc);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => authBloc..add(AuthCheckRequested()),
        ),
        BlocProvider<HabitBloc>(
          create: (context) => GetIt.instance<HabitBloc>(),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) => GetIt.instance<SettingsBloc>()
            ..add(const LoadSettings()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.user?.id != current.user?.id,
        listener: (context, state) {
          final userId = state.user?.id;
          if (state.status == AuthStatus.authenticated &&
              userId != null &&
              userId.isNotEmpty &&
              userId != _primedUserId) {
            primeUserData(context, userId: userId);
            _primedUserId = userId;
          }
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp.router(
              title: 'WellnessFlow',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: settingsState.themeMode,
              locale: settingsState.locale,
              supportedLocales: const [
                Locale('en'),
                Locale('es'),
                Locale('fr'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: AppRouter.router,
              builder: (context, child) {
                // Update system UI based on current theme
                final brightness = Theme.of(context).brightness;
                SystemUIConfig.configureSystemUI(
                    isDarkMode: brightness == Brightness.dark);

                return child ?? const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }
}
