import 'package:flutter/widgets.dart';

typedef TWriteableItemBuilderDef<DTO> =
    Widget Function(
      BuildContext context,
      DTO item,
      bool isFirst,
      bool isLast,
    );
