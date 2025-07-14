import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/utils/system_ui_config.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/habits/presentation/bloc/habit_bloc.dart';
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

  runApp(const WellnessFlowApp());
}

class WellnessFlowApp extends StatelessWidget {
  const WellnessFlowApp({super.key});

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
      ],
      child: MaterialApp.router(
        title: 'WellnessFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          // Update system UI based on current theme
          final brightness = Theme.of(context).brightness;
          SystemUIConfig.configureSystemUI(
              isDarkMode: brightness == Brightness.dark);

          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}
