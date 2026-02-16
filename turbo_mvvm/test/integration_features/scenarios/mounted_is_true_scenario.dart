import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gherkin_integration_test/integration_test.dart';
import 'package:turbo_mvvm/data/abstracts/t_base_view_model.dart';

import '../../models/base_view_model_implementation.dart';

class MountedIsTrueScenario extends IntegrationScenario {
  MountedIsTrueScenario()
    : super(
        description:
            'Testing the mounted method initialisation of the TurboViewModelBuilder',
        steps: [
          Given(
            'The TurboViewModel is built',
            (tester, log, box, mocks, [example, binding]) async {
              log.info('Building the TurboViewModel..');
              final baseViewModel = BaseViewModelImplementation(isMock: false);
              log.success('TurboViewModel built!');
              box.write(#baseViewModel, baseViewModel);
            },
          ),
          When(
            'the TurboViewModelBuilder is initialised',
            (tester, log, box, mocks, [example, binding]) async {
              await tester.pumpWidget(
                TViewModelBuilder<BaseViewModelImplementation>(
                  builder: (context, model, isInitialised, child) =>
                      const SizedBox(),
                  viewModelBuilder: () => box.read(#baseViewModel),
                ),
              );
              await tester.pumpAndSettle();
            },
          ),
          Then(
            'The TurboViewModel.isMounted method should return true',
            (tester, log, box, mocks, [example, binding]) {
              expect(
                box.read<BaseViewModelImplementation>(#baseViewModel).isMounted,
                true,
              );
              log.success('TurboViewModel was mounted!');
            },
          ),
        ],
      );
}
