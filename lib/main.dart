import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/locale/locale_cubit.dart';
import 'package:hajedi/bloc/theme/theme_bloc.dart';
import 'package:hajedi/bloc/theme/theme_state.dart';
import 'package:hajedi/core/theme/theme.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/l10n/fallback_localizations.dart';
import 'package:hajedi/screens/dashboard/main_screen.dart';
import 'package:hajedi/screens/settings/choose_language.dart';
import 'package:hajedi/screens/settings/settings.dart';
import 'package:hajedi/utils/hive_registry.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );
  
  await HiveRegistry.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => ThemeBloc()),
        ],
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, localState) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  routes: {
                     '/choose-language': (context) => const ChooseLanguage(),
                     '/settings': (context) => const Settings(),
                     '/dashboard': (context) => const MainScreen(),
                  },
                  initialRoute: '/dashboard',
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  // themeMode: ThemeMode.dark,
                  themeMode: themeState.themeMode,
                  locale: localState ?? const Locale('en'),
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: const [
                      AppLocalizations.delegate,
                      FallbackMaterialLocalizationsDelegate(),
                      FallbackWidgetsLocalizationsDelegate(),
                      FallbackCupertinoLocalizationsDelegate(),
                    ],
                  localeResolutionCallback: (locale, supported) {
                      if (locale == null) return supported.first;
                      final isSupported = supported.any(
                        (l) => l.languageCode == locale.languageCode,
                      );
                      return isSupported ? locale : const Locale('en');
                    },
                  home: const Settings(),
                );

            },
          );
        },
      ),
    );
  }
}
