import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'core/bootstrap/app_init.dart';
import 'providers/pokedex_provider.dart';
import 'screens/screens.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final deps = await initApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: deps.game),
        ChangeNotifierProvider.value(value: deps.fusionPedia),
        ChangeNotifierProvider.value(value: deps.fusionCollection),
        ChangeNotifierProvider.value(value: deps.homeSlots),
        ChangeNotifierProvider.value(value: deps.settings),
        ChangeNotifierProvider.value(value: deps.dailyMissions),
        ChangeNotifierProvider(create: (_) => PokedexProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// ------------------------------------------------------
// ROOT APP
// ------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WakeLockHost();
  }
}

class _WakeLockHost extends StatefulWidget {
  const _WakeLockHost();

  @override
  State<_WakeLockHost> createState() => _WakeLockHostState();
}

class _WakeLockHostState extends State<_WakeLockHost>
    with WidgetsBindingObserver {
  Future<void> _enableWakeLock() async {
    await WakelockPlus.enable();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableWakeLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _enableWakeLock();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      WakelockPlus.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData(),
      routes: {
        '/': (_) => const LoadingScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
