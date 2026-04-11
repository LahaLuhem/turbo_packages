import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

import 'core/enums/showcase_route.dart';
import 'core/globals/locator_service.dart';
import 'core/services/theme_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocatorService.locate.registerInitialDependencies();
  runApp(const TurboWidgetsShopApp());
}

class TurboWidgetsShopApp extends StatelessWidget {
  const TurboWidgetsShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Brightness>(
      valueListenable: ThemeService.locate.brightness,
      builder: (context, brightness, _) {
        return ShadApp(
          title: 'Turbo Widgets Shop',
          debugShowCheckedModeBanner: false,
          themeMode:
              brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark,
          theme: ShadThemeData(
            brightness: Brightness.light,
            colorScheme: const ShadBlueColorScheme.light(),
          ),
          darkTheme: ShadThemeData(
            brightness: Brightness.dark,
            colorScheme: const ShadBlueColorScheme.dark(),
          ),
          home: ContextualButtonsProvider<ShowcaseRoute>(
            contextualButtonBuilders: const {},
            child: TResponsiveBuilder(
              builder: (context, child, constraints, tools, data) {
                return const _ShellPlaceholder();
              },
            ),
          ),
        );
      },
    );
  }
}

/// Temporary placeholder until the real ShowcaseShellView is authored.
class _ShellPlaceholder extends StatelessWidget {
  const _ShellPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Turbo Widgets Shop\nShell placeholder',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
