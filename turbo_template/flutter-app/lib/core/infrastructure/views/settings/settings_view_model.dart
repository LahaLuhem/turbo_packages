import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:turbo_flutter_template/core/infrastructure/enums/t_route.dart';
import 'package:turbo_flutter_template/core/infrastructure/services/base_router_service.dart';
import 'package:turbo_flutter_template/core/state/manage-state/abstracts/t_view_model.dart';
import 'package:turbo_flutter_template/core/state/manage-state/models/contextual_button_entry.dart';
import 'package:turbo_widgets/turbo_widgets.dart';
import 'package:turbolytics/turbolytics.dart';

class SettingsViewModel extends TViewModel with Turbolytics {
  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static SettingsViewModel get locate => GetIt.I.get();
  static void registerFactory() =>
      GetIt.I.registerFactory(SettingsViewModel.new);

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  TRoute? get contextualButtonsRoute => TRoute.settings;

  List<ContextualButtonEntry> get contextualButtons => [
    ContextualButtonEntry(
      id: 'settings-back',
      config: TButtonConfig(
        label: 'Back',
        tooltip: 'Go back',
        icon: Icons.arrow_back_rounded,
        onPressed: onBackPressed,
      ),
      position: TContextualPosition.top,
    ),
  ];

  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗 HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void onBackPressed() {
    final currentContext = context;
    if (currentContext != null && currentContext.canPop()) {
      currentContext.pop();
      return;
    }
    BaseRouterService.locate.context.pop();
  }
}
