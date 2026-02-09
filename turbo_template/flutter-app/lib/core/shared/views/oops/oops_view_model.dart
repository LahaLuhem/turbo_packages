import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:turbo_flutter_template/core/auth/mixins/logout_management.dart';
import 'package:turbo_flutter_template/core/infrastructure/enums/t_route.dart';
import 'package:turbo_flutter_template/core/state/manage-state/abstracts/t_view_model.dart';
import 'package:turbo_flutter_template/core/state/manage-state/models/contextual_button_entry.dart';
import 'package:turbolytics/turbolytics.dart';

class OopsViewModel extends TViewModel with Turbolytics, LogoutManagement {
  OopsViewModel();

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static OopsViewModel get locate => GetIt.I.get();
  static void registerFactory() =>
      GetIt.I.registerFactory(() => OopsViewModel());

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  TRoute? get contextualButtonsRoute => TRoute.oops;

  List<ContextualButtonEntry> get contextualButtons => const [];

  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗 HELPERS ------------------------------------------------------------------------------- \\

  bool canPop(BuildContext context) => Navigator.of(context).canPop();

  void goBack(BuildContext context) {
    if (canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
