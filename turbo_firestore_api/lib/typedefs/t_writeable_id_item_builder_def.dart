import 'package:flutter/widgets.dart';
import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef TWriteableIdItemBuilderDef<DTO> =
    Widget Function(
      BuildContext context,
      DTO item,
      bool isFirst,
      bool isLast,
    );
