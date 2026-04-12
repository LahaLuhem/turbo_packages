import 'package:get_it/get_it.dart';

abstract interface class TBaseRouterServiceInterface {
  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static TBaseRouterServiceInterface get locate =>
      GetIt.I.get<TBaseRouterServiceInterface>();

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  String get currentRoute;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void addRouteListener(void Function(String route) listener);
  void removeRouteListener(void Function(String route) listener);
}
