import 'package:turbo_mvvm/data/abstracts/t_base_view_model.dart';
import 'package:turbo_mvvm/data/mixins/t_busy_management.dart';
import 'package:turbo_mvvm/data/mixins/t_error_management.dart';

class BaseViewModelImplementation<T> extends TBaseViewModel<T>
    with TErrorManagement, TBusyManagement {
  BaseViewModelImplementation({
    required bool isMock,
  }) : _isMock = isMock;

  final bool _isMock;
  late double stubbedTextScaleFactor;
  late double stubbedCurrentWidth;
  late double stubbedCurrentHeight;

  @override
  void rebuild() {
    if (!_isMock) {
      super.rebuild();
    }
  }
}
