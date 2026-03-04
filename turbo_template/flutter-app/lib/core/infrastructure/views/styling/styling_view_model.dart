import 'package:get_it/get_it.dart';
import 'package:turbo_flutter_template/core/infrastructure/enums/t_route.dart';
import 'package:turbo_flutter_template/core/infrastructure/forms/entity_detail_form.dart';
import 'package:turbo_flutter_template/core/state/manage-state/abstracts/t_view_model.dart';
import 'package:turbo_flutter_template/core/state/manage-state/models/contextual_button_entry.dart';
import 'package:turbo_flutter_template/core/ux/services/toast_service.dart';
import 'package:turbolytics/turbolytics.dart';

class StylingViewModel extends TViewModel with Turbolytics {
  static StylingViewModel get locate => GetIt.I.get();
  static void registerFactory() => GetIt.I.registerFactory(
    () => StylingViewModel(),
  );

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  ToastService get _toastService => ToastService.locate;
  final _entityDetailForm = EntityDetailForm.locate;

  TRoute? get contextualButtonsRoute => TRoute.styling;

  List<ContextualButtonEntry> get contextualButtons => const [];

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> dispose() async {
    _entityDetailForm.dispose();
    await super.dispose();
  }

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  EntityDetailForm get entityDetailForm => _entityDetailForm;
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void onHeaderSave() => _toastService.showToast(
    context: context,
    title: 'Header saved',
    subtitle: 'Entity header changes were saved.',
  );

  void onSectionSave() => _toastService.showToast(
    context: context,
    title: 'Section saved',
    subtitle: 'Entity section fields were saved.',
  );
}
