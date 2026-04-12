import 'package:flutter/widgets.dart';
import 'package:turbo_mvvm/data/abstracts/t_base_view_model.dart';

typedef TViewModelBuilderDef<T extends TBaseViewModel> =
    Widget Function(
      BuildContext context,
      T model,
      bool isInitialised,
      Widget? child,
    );
