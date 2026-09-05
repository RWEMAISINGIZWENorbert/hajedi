import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hajedi/bloc/auth/auth_bloc.dart';
import 'package:hajedi/bloc/locale/locale_cubit.dart';
import 'package:hajedi/bloc/theme/theme_bloc.dart';
import 'package:hajedi/bloc/theme/theme_state.dart';
import 'package:hajedi/bloc/user/user_bloc.dart';
import 'package:hajedi/core/network/sync_coordinator.dart';
import 'package:hajedi/core/network/sync_manager.dart';
import 'package:hajedi/core/theme/theme.dart';
import 'package:hajedi/data/product.dart';
import 'package:hajedi/data/sync_queue_item.dart';
import 'package:hajedi/data/user.dart';
import 'package:hajedi/l10n/app_localizations.dart';
import 'package:hajedi/l10n/fallback_localizations.dart';
import 'package:hajedi/repository/auth_repository.dart';
import 'package:hajedi/screens/auth/sign_in.dart';
import 'package:hajedi/screens/dashboard/main_screen.dart';
import 'package:hajedi/screens/product/new_product.dart';
import 'package:hajedi/screens/settings/choose_language.dart';
import 'package:hajedi/screens/settings/settings.dart';
import 'package:hajedi/utils/auth_utils.dart';
import 'package:hajedi/utils/hive_registry.dart';
import 'package:hajedi/widgets/loading.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hajedi/bloc/product/product_bloc.dart';

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
  // await HiveRegistry.clearALlBoxes();
  await dotenv.load(fileName: ".env");
  
  // final syncManager = SyncManager(
  //    queueBox: Hive.box('syncQueue'),
  //    handlers: handlers,
  // );
  final syncManager = SyncManager.create(
     queueBox: Hive.box<SyncQueueItem>('syncQueue'),
     userBox: Hive.box<User>('users'),
     productBox: Hive.box<Product>('products'),
);

  await syncManager.start();

  final syncCoordinator = SyncCoordinator(syncManager);
  syncCoordinator.start();

  runApp(MyApp(syncManager: syncManager, syncCoordinator: syncCoordinator));
}

class MyApp extends StatelessWidget {
  final SyncManager syncManager;
  final SyncCoordinator syncCoordinator;

  const MyApp({super.key, required this.syncManager, required this.syncCoordinator});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(create: (context) => UserBloc(Hive.box('users'), syncManager)),
        BlocProvider(create: (_) => AuthBloc(authRepository: AuthRepository(),)),
        BlocProvider(create: (_) => ProductBloc(Hive.box('products'),syncManager)..add(LoadLocalProducts()),), 
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
                     '/sign-in': (context) => const SignIn(),
                     '/new-product': (context) => const NewProduct()
                  },
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  // themeMode: ThemeMode.light,
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
                  home: const AuthGate(),
                );

            },
          );
        },
      ),
    );
  }
}


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthUtils.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Loading(),
            ),
          );
        }

        if (snapshot.data == true) {
          return const MainScreen();
        }

        return const SignIn();
      },
    );
  }
}
