import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/turbo_firestore_api.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef TCollectionStreamBuilderDef<T extends TWriteableId> =
    Stream<List<T>> Function(
      User user,
      TFirestoreApi<T> api,
      TCollectionService<T> service,
    );

typedef TDocStreamBuilderDef<T extends TWriteableId> =
    Stream<T?> Function(
      User user,
      TFirestoreApi<T> api,
      TDocService<T> service,
    );
