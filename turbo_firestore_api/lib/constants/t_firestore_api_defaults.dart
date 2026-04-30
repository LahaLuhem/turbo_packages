import 'package:turbo_firestore_api/enums/t_user_id_location.dart';
import 'package:turbo_serializable/constants/ts_defaults.dart';

abstract class TFirestoreApiDefaults {
  TFirestoreApiDefaults._();

  static const unknownValueValue = 'unknown';
  static const defaultIdValue = TSDefaults.defaultIdValue;
  static const createdAtFieldName = 'createdAt';
  static const updatedAtFieldName = 'updatedAt';
  static const idFieldName = 'id';
  static const userIdFieldName = 'userId';
  static const documentReferenceFieldName = 'documentReference';
  static const isCollectionGroup = false;
  static const tryAddLocalDocumentReference = false;
  static const initialiseStream = true;
  static const tryAddLocalId = true;
  static const userIdLocation = UserIdLocation.defaultValue;
}
