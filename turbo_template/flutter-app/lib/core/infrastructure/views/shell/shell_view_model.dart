import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:turbo_flutter_template/core/infrastructure/routers/home_router.dart';
import 'package:turbo_flutter_template/core/infrastructure/routers/styling_router.dart';
import 'package:turbo_flutter_template/core/state/manage-state/abstracts/t_view_model.dart';
import 'package:turbo_flutter_template/core/state/manage-state/typedefs/lazy_locator_def.dart';
import 'package:turbo_widgets/turbo_widgets.dart';
import 'package:turbolytics/turbolytics.dart';

typedef ShellViewArguments = ({
  StatefulNavigationShell shell,
  Map<TContextualPosition, TContextualPosition> positionOverrides,
});

class ShellViewModel extends TViewModel<ShellViewArguments> with Turbolytics {
  ShellViewModel({
    required LazyLocatorDef<HomeRouter> homeRouter,
    required LazyLocatorDef<StylingRouter> stylingRouter,
  }) : _homeRouter = homeRouter,
       _stylingRouter = stylingRouter;

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\
  static ShellViewModel get locate => GetIt.I.get();
  static void registerFactory() => GetIt.I.registerFactory(
    () => ShellViewModel(
      homeRouter: () => HomeRouter.locate,
      stylingRouter: () => StylingRouter.locate,
    ),
  );

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  final LazyLocatorDef<HomeRouter> _homeRouter;
  final LazyLocatorDef<StylingRouter> _stylingRouter;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void onHomePressed() {
    _homeRouter().goHomeView(statefulNavigationShell: arguments.shell);
  }

  void onStylingPressed() {
    _stylingRouter().goStylingView(statefulNavigationShell: arguments.shell);
  }
}
