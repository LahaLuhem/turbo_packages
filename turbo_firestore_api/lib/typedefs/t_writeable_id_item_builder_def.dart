import 'package:flutter/widgets.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef TWriteableIdItemBuilderDef<WRITEABLE extends TWriteableId> =
    Widget Function(
      BuildContext context,
      WRITEABLE item,
      bool isFirst,
      bool isLast,
    );
