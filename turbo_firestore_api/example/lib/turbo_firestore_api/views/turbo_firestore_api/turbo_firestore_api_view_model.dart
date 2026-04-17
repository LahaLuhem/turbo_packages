import 'package:firebase_core/firebase_core.dart';
import 'package:turbo_firestore_api_example/turbo_firestore_api/data/apis/example_api.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';

class CloudFirestoreApiViewModel extends TBaseViewModel {
  CloudFirestoreApiViewModel();

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await Firebase.initializeApp();
    ExampleAPI().createExample();
    super.initialise(doSetInitialised: doSetInitialised);
  }

  static CloudFirestoreApiViewModel get locate => CloudFirestoreApiViewModel();
}
