import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turbo_firestore_api/turbo_firestore_api.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

class TFirestoreCollection<WRITEABLE extends TWriteableId> {
  const TFirestoreCollection({
    required this.apiName,
    required this.collectionName,
    required this.fromJson,
    required this.toJson,
    this.createdAtFieldName = TFirestoreApiDefaults.createdAtFieldName,
    this.documentReferenceFieldName = TFirestoreApiDefaults.documentReferenceFieldName,
    this.fromJsonError,
    this.idFieldName = TFirestoreApiDefaults.idFieldName,
    this.isCollectionGroup = TFirestoreApiDefaults.isCollectionGroup,
    this.tryAddLocalDocumentReference = TFirestoreApiDefaults.tryAddLocalDocumentReference,
    this.tryAddLocalId = TFirestoreApiDefaults.tryAddLocalId,
    this.updatedAtFieldName = TFirestoreApiDefaults.updatedAtFieldName,
  });

  final Map<String, dynamic> Function(WRITEABLE value) toJson;
  final String apiName;
  final String collectionName;
  final String createdAtFieldName;
  final String documentReferenceFieldName;
  final String idFieldName;
  final String updatedAtFieldName;
  final WRITEABLE Function(Map<String, dynamic> json) fromJson;
  final WRITEABLE Function(Map<String, dynamic> json)? fromJsonError;
  final bool isCollectionGroup;
  final bool tryAddLocalDocumentReference;
  final bool tryAddLocalId;

  TFirestoreApi<WRITEABLE> api({
    FirebaseFirestore? firebaseFirestore,
    GetOptions? getOptions,
    String Function(String collectionName)? path,
    TFirestoreLogger? logger,
    bool? isCollectionGroup,
  }) => TFirestoreApi<WRITEABLE>(
    collectionPath: () => path?.call(collectionName) ?? collectionName,
    createdAtFieldName: createdAtFieldName,
    documentReferenceFieldName: documentReferenceFieldName,
    firebaseFirestore: firebaseFirestore ?? FirebaseFirestore.instance,
    fromJson: fromJson,
    fromJsonError: fromJsonError,
    getOptions: getOptions,
    idFieldName: idFieldName,
    isCollectionGroup: isCollectionGroup ?? this.isCollectionGroup,
    logger: logger,
    toJson: toJson,
    tryAddLocalDocumentReference: tryAddLocalDocumentReference,
    tryAddLocalId: tryAddLocalId,
    updatedAtFieldName: updatedAtFieldName,
  );

  TCollectionService<WRITEABLE> collectionService({
    TCollectionApiBuilderDef<WRITEABLE>? apiBuilder,
    TCollectionStreamBuilderDef<WRITEABLE>? streamBuilder,
    TCollectionValueBuilderDef<WRITEABLE>? initialValue,
    TCollectionValueBuilderDef<WRITEABLE>? defaultValue,
    bool initialiseStream = true,
  }) => TCollectionService(
    collection: this,
    apiBuilder: apiBuilder,
    defaultValue: defaultValue,
    initialValue: initialValue,
    streamBuilder: streamBuilder,
    initialiseStream: initialiseStream,
  );

  TDocService<WRITEABLE> docService({
    required TDocValueBuilderDef<WRITEABLE> defaultValue,
    TDocApiBuilderDef<WRITEABLE>? apiBuilder,
    TDocStreamBuilderDef<WRITEABLE>? streamBuilder,
    TDocValueBuilderDef<WRITEABLE>? initialValue,
    bool initialiseStream = true,
  }) => TDocService(
    collection: this,
    apiBuilder: apiBuilder,
    defaultValue: defaultValue,
    initialValue: initialValue,
    streamBuilder: streamBuilder,
    initialiseStream: initialiseStream,
  );
}
