import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'services/storage_service.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

/// Global theme mode notifier so any widget can toggle it
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  await storage.init();
  runApp(CuffNotesApp(storage: storage));
}

class CuffNotesApp extends StatelessWidget {
  final StorageService storage;
  const CuffNotesApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, themeMode, _) {
            return MaterialApp(
              title: 'CuffNotes',
              debugShowCheckedModeBanner: false,
              theme: CuffNotesTheme.light(lightDynamic),
              darkTheme: CuffNotesTheme.dark(darkDynamic),
              themeMode: themeMode,
              home: _AppEntry(storage: storage),
            );
          },
        );
      },
    );
  }
}

class _AppEntry extends StatefulWidget {
  final StorageService storage;
  const _AppEntry({required this.storage});

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  late AppState _appState;
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    _appState = AppState(storage: widget.storage);
    _appState.loadAll();
  }

  void _onSplashComplete() {
    setState(() => _splashDone = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return SplashScreen(onComplete: _onSplashComplete);
    }

    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        if (_appState.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading legislation...',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (_appState.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load content:\n${_appState.error}',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _appState.loadAll(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return HomeScreen(appState: _appState);
      },
    );
  }
}
