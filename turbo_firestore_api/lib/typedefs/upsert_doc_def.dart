import 'package:turbo_firestore_api/models/t_auth_vars.dart';
import 'package:turbo_serializable/abstracts/t_writeable.dart';

typedef UpsertDocDef<WRITEABLE extends TWriteable> = WRITEABLE Function(WRITEABLE? current, TAuthVars vars);
