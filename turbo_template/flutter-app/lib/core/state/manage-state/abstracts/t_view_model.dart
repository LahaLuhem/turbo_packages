import 'package:flutter/foundation.dart';
import 'package:turbo_flutter_template/core/auth/services/auth_service.dart';
import 'package:turbo_mvvm/data/models/t_base_view_model.dart';

abstract class TViewModel<ARGUMENTS> extends TBaseViewModel<ARGUMENTS> {
  // 📍 LOCATOR ------------------------------------------------------------------------------- \\
  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  @protected
  final authService = AuthService.lazyLocate;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @mustCallSuper
  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    super.initialise(doSetInitialised: doSetInitialised);
  }

  @mustCallSuper
  @override
  Future<void> dispose() async {
    super.dispose();
  }

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  ValueListenable<bool> get hasAuth => authService().hasAuth;

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
