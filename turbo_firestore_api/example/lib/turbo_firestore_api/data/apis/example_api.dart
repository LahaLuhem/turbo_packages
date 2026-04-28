import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turbo_firestore_api/apis/t_firestore_api.dart';
import 'package:turbo_response/turbo_response.dart';

import '../dtos/example_dto.dart';

class ExampleAPI extends TFirestoreApi<ExampleDTO, ExampleModel> {
  ExampleAPI()
    : super(
        collectionPath: () => 'Examples',
        firebaseFirestore: FirebaseFirestore.instance,
        fromJson: ExampleDTO.fromJson,
        toJson: (dto) => dto.toJson(),
        modelBuilder: (dto) => ExampleModel(dto: dto),
      );

  Future<TurboResponse<DocumentReference>> createExample() {
    final random = Random();
    final dto = ExampleDTO(
      id: 'id',
      thisIsAString: ['yes', 'maybe'][random.nextInt(2)],
      thisIsANumber: random.nextDouble(),
      thisIsABoolean: random.nextBool(),
    );

    return createDoc(writeable: dto);
  }

  Future<TurboResponse<List<ExampleDTO>>> getAllExamples() {
    return listAllWithConverter();
  }

  static ExampleAPI get locate => ExampleAPI();
}
