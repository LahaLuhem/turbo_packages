import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shake_gesture/shake_gesture.dart';
import 'package:turbo_flutter_template/core/generated/l10n.dart';
import 'package:turbo_flutter_template/core/infrastructure/views/my_app/my_app_view_model.dart';
import 'package:turbo_flutter_template/core/state/manage-state/extensions/context_extension.dart';
import 'package:turbo_flutter_template/core/state/manage-state/widgets/is_busy_icon.dart';
import 'package:turbo_flutter_template/core/state/manage-state/widgets/unfocusable.dart';
import 'package:turbo_flutter_template/core/state/manage-state/widgets/value_listenable_builder_x2.dart'
    show ValueListenableBuilderX2;
import 'package:turbo_flutter_template/core/ui/config/no_thumb_scroll_behaviour.dart';
import 'package:turbo_flutter_template/core/ui/constants/spacings.dart';
import 'package:turbo_flutter_template/core/ui/constants/t_durations.dart';
import 'package:turbo_flutter_template/core/ui/constants/t_widget.dart';
import 'package:turbo_flutter_template/core/ui/enums/t_theme_mode.dart';
import 'package:turbo_flutter_template/core/ui/widgets/color_extension.dart';
import 'package:turbo_flutter_template/core/ui/widgets/t_provider.dart';
import 'package:turbo_flutter_template/core/ui/widgets/t_provider_builder.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  static const String path = 'app';

  @override
  Widget build(BuildContext context) => TViewModelBuilder<MyAppViewModel>(
    isReactive: false,
    builder: (context, model, isInitialised, _) {
      if (!isInitialised) return TWidgets.nothing;
      return ValueListenableBuilderX2(
        valueListenable: model.themeMode,
        valueListenable2: model.language,
        builder: (context, turboThemeMode, language, _) => AnnotatedRegion(
          value: turboThemeMode.themeMode,
          child: ShadApp.router(
            key: ValueKey(language.languageCode),
            locale: language.toLocale,
            materialThemeBuilder: (context, theme) {
              final backgroundColor = switch (turboThemeMode) {
                TThemeMode.dark => TColors.backgroundDark,
                TThemeMode.light => TColors.backgroundLight,
              };
              final foregroundColor = backgroundColor.onColor;
              return theme.copyWith(
                scaffoldBackgroundColor: backgroundColor,
                iconTheme: IconThemeData(color: foregroundColor),
                colorScheme: switch (turboThemeMode) {
                  TThemeMode.dark => ColorScheme.dark(
                    onSurface: backgroundColor,
                  ),
                  TThemeMode.light => ColorScheme.light(
                    onSurface: backgroundColor,
                  ),
                },
              );
            },
            theme: TThemeMode.light.themeData,
            darkTheme: TThemeMode.dark.themeData,
            themeMode: turboThemeMode.themeMode,
            routerConfig: model.coreRouter,
            scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              Strings.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: Strings.supportedLocales,
            builder: (context, child) => TProviderBuilder(
              tSupportedLanguage: language,
              tThemeMode: turboThemeMode,
              builder:
                  (
                    deviceType,
                    themeMode,
                    tools,
                    data,
                    texts,
                    colors,
                    sizes,
                    decorations,
                    context,
                  ) => Unfocusable(
                    child: MediaQuery(
                      data: context.media.copyWith(
                        textScaler: TextScaler.noScaling,
                      ),
                      child: Overlay(
                        initialEntries: [
                          OverlayEntry(
                            builder: (_) {
                              return ValueListenableBuilderX2<TBusyModel, bool>(
                                valueListenable: model.busyListenable,
                                valueListenable2: model.hasInternetConnection,
                                builder:
                                    (
                                      context,
                                      busyModel,
                                      hasInternetConnection,
                                      _,
                                    ) {
                                      return Stack(
                                        fit: StackFit.expand,
                                        alignment: AlignmentDirectional.center,
                                        children: [
                                          Positioned.fill(
                                            child: Container(
                                              color: context.colors.background,
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: AnimatedOpacity(
                                              duration: TDurations.animation,
                                              opacity: busyModel.isBusy
                                                  ? Spacings.opacityDisabled
                                                  : 1,
                                              child: IgnorePointer(
                                                ignoring:
                                                    busyModel.isBusy || !hasInternetConnection,
                                                child: deviceType.isMobile
                                                    ? ShakeGesture(
                                                        onShake: () => model.onShakeDetected(
                                                          context: context,
                                                        ),
                                                        child: child!,
                                                      )
                                                    : child!,
                                              ),
                                            ),
                                          ),
                                          IsBusyIcon(
                                            busyModel: busyModel,
                                            height: 112,
                                          ),
                                        ],
                                      );
                                    },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ),
        ),
      );
    },
    viewModelBuilder: () => MyAppViewModel.locate,
  );
}
