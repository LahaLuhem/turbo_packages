import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/turbo_firestore_api.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef TDocStreamBuilderDef<T extends TWriteableId> =
    Stream<T?> Function(
      User user,
      TFirestoreApi<T> api,
      TDocumentService<T> service,
    );
