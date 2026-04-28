import 'package:flutter/widgets.dart';
import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_serializable/abstracts/t_writeable.dart';

typedef TModelItemBuilderDef<MODEL extends TModel> =
    Widget Function(
      BuildContext context,
      MODEL item,
      bool isFirst,
      bool isLast,
    );
