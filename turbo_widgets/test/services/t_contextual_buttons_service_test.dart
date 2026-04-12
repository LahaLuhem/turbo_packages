import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_widgets/src/enums/t_contextual_position.dart';
import 'package:turbo_widgets/src/models/t_contextual_buttons_config.dart';
import 'package:turbo_widgets/src/services/t_contextual_buttons_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TContextualButtonsService', () {
    tearDown(() {
      TContextualButtonsService.resetInstance();
    });

    group('constructor', () {
      test(
        '''
        Given no initial config
        When service is created
        Then value is empty TContextualButtonsConfig
      ''',
        () {
          // Arrange & Act
          final service = TContextualButtonsService();

          // Assert
          expect(service.value, const TContextualButtonsConfig());
        },
      );

      test(
        '''
        Given initial config with hidden positions
        When service is created
        Then value contains those hidden positions
      ''',
        () {
          // Arrange
          const config = TContextualButtonsConfig(
            hiddenPositions: {
              TContextualPosition.top,
              TContextualPosition.bottom,
            },
          );

          // Act
          final service = TContextualButtonsService(config);

          // Assert
          expect(service.value.hiddenPositions, {
            TContextualPosition.top,
            TContextualPosition.bottom,
          });
        },
      );
    });

    group('singleton', () {
      test(
        '''
        Given no prior access
        When instance is accessed twice
        Then same instance is returned
      ''',
        () {
          // Act
          final instance1 = TContextualButtonsService.instance;
          final instance2 = TContextualButtonsService.instance;

          // Assert
          expect(identical(instance1, instance2), isTrue);
        },
      );

      test(
        '''
        Given existing singleton instance
        When resetInstance is called
        Then next access creates new instance
      ''',
        () {
          // Arrange
          final oldInstance = TContextualButtonsService.instance;

          // Act
          TContextualButtonsService.resetInstance();
          final newInstance = TContextualButtonsService.instance;

          // Assert
          expect(identical(oldInstance, newInstance), isFalse);
        },
      );
    });

    group('update', () {
      test(
        '''
        Given a service
        When update is called with new config
        Then value is updated
      ''',
        () {
          // Arrange
          final service = TContextualButtonsService();
          const newConfig = TContextualButtonsConfig(
            hiddenPositions: {TContextualPosition.left},
          );

          // Act
          service.update(newConfig);

          // Assert
          expect(service.value.hiddenPositions, {TContextualPosition.left});
        },
      );

      test(
        '''
        Given a service with listener
        When update is called with doNotifyListeners true
        Then listener is notified
      ''',
        () {
          // Arrange
          final service = TContextualButtonsService();
          var notificationCount = 0;
          service.addListener(() => notificationCount++);
          const newConfig = TContextualButtonsConfig(
            hiddenPositions: {TContextualPosition.top},
          );

          // Act
          service.update(newConfig, doNotifyListeners: true);

          // Assert
          expect(notificationCount, 1);
        },
      );

      test(
        '''
        Given a service with listener
        When update is called with doNotifyListeners false
        Then listener is not notified
      ''',
        () {
          // Arrange
          final service = TContextualButtonsService();
          var notificationCount = 0;
          service.addListener(() => notificationCount++);
          const newConfig = TContextualButtonsConfig(
            hiddenPositions: {TContextualPosition.top},
          );

          // Act
          service.update(newConfig, doNotifyListeners: false);

          // Assert
          expect(notificationCount, 0);
          expect(service.value.hiddenPositions, {TContextualPosition.top});
        },
      );

      test(
        '''
        Given a service with existing config
        When update is called with identical config
        Then listener is not notified
      ''',
        () {
          // Arrange
          const config = TContextualButtonsConfig(
            hiddenPositions: {TContextualPosition.top},
          );
          final service = TContextualButtonsService(config);
          var notificationCount = 0;
          service.addListener(() => notificationCount++);

          // Act
          service.update(config);

          // Assert
          expect(notificationCount, 0);
        },
      );

      test(
        '''
        Given a disposed service
        When update is called
        Then value remains unchanged
      ''',
        () {
          // Arrange
          final service = TContextualButtonsService();
          final originalValue = service.value;
          service.dispose();

          // Act
          service.update(
            const TContextualButtonsConfig(
              hiddenPositions: {TContextualPosition.top},
            ),
          );

          // Assert
          expect(service.value, originalValue);
        },
      );
    });

    group('updateWith', () {
      test(
        '''
        Given a service
        When updateWith is called with updater function
        Then value is updated based on current value
      ''',
        () {
          // Arrange
          final service = TContextualButtonsService(
            const TContextualButtonsConfig(
              hiddenPositions: {TContextualPosition.top},
            ),
          );

          // Act
          service.updateWith(
            (current) => current.copyWith(
              hiddenPositions: {
                ...current.hiddenPositions,
                TContextualPosition.bottom,
              },
            ),
          );

          // Assert
          expect(service.value.hiddenPositions, {
            TContextualPosition.top,
            TContextualPosition.bottom,
          });
        },
      );
    });

    group('updateContextualButtons', () {
      test(
        '''
        Given a service
        When updateContextualButtons is called with animated false
        Then config is updated immediately without animation
      ''',
        () async {
          // Arrange
          final service = TContextualButtonsService();
          const newConfig = TContextualButtonsConfig(
            hiddenPositions: {TContextualPosition.right},
          );

          // Act
          await service.updateContextualButtons(
            (_) => newConfig,
            animated: false,
          );

          // Assert
          expect(service.value.hiddenPositions, {TContextualPosition.right});
        },
      );

      test(
        '''
        Given a service with identical config
        When updateContextualButtons is called
        Then no update occurs
      ''',
        () async {
          // Arrange
          const config = TContextualButtonsConfig(
            hiddenPositions: {TContextualPosition.top},
          );
          final service = TContextualButtonsService(config);
          var notificationCount = 0;
          service.addListener(() => notificationCount++);

          // Act
          await service.updateContextualButtons((_) => config);

          // Assert
          expect(notificationCount, 0);
        },
      );
    });

    group('hideAllButtons', () {
      test(
        '''
        Given a service with no hidden positions
        When hideAllButtons is called
        Then all positions are hidden
      ''',
        () {
          // Arrange
          final service = TContextualButtonsService();

          // Act
          service.hideAllButtons();

          // Assert
          expect(
            service.value.hiddenPositions,
            TContextualPosition.values.toSet(),
          );
        },
      );
    });

    group('showAllButtons', () {
      test(
        '''
        Given a service with all positions hidden
        When showAllButtons is called
        Then no positions are hidden
      ''',
        () {
          // Arrange
          final service = TContextualButtonsService(
            TContextualButtonsConfig(
              hiddenPositions: TContextualPosition.values.toSet(),
            ),
          );

          // Act
          service.showAllButtons();

          // Assert
          expect(service.value.hiddenPositions, isEmpty);
        },
      );
    });

    group('hidePosition', () {
      test(
        '''
        Given a service with no hidden positions
        When hidePosition is called for top
        Then only top is hidden
      ''',
        () {
          // Arrange
          final service = TContextualButtonsService();

          // Act
          service.hidePosition(TContextualPosition.top);

          // Assert
          expect(service.value.hiddenPositions, {TContextualPosition.top});
        },
      );

      test(
        '''
        Given a service with bottom already hidden
        When hidePosition is called for top
        Then both top and bottom are hidden
      ''',
        () {
          // Arrange
          final service = TContextualButtonsService(
            const TContextualButtonsConfig(
              hiddenPositions: {TContextualPosition.bottom},
            ),
          );

          // Act
          service.hidePosition(TContextualPosition.top);

          // Assert
          expect(service.value.hiddenPositions, {
            TContextualPosition.top,
            TContextualPosition.bottom,
          });
        },
      );
    });

    group('showPosition', () {
      test(
        '''
        Given a service with top hidden
        When showPosition is called for top
        Then top is no longer hidden
      ''',
        () {
          // Arrange
          final service = TContextualButtonsService(
            const TContextualButtonsConfig(
              hiddenPositions: {
                TContextualPosition.top,
                TContextualPosition.bottom,
              },
            ),
          );

          // Act
          service.showPosition(TContextualPosition.top);

          // Assert
          expect(service.value.hiddenPositions, {TContextualPosition.bottom});
        },
      );
    });

    group('reset', () {
      test(
        '''
        Given a service with custom config
        When reset is called
        Then value is empty TContextualButtonsConfig
      ''',
        () {
          // Arrange
          final service = TContextualButtonsService(
            TContextualButtonsConfig(
              hiddenPositions: TContextualPosition.values.toSet(),
              animationDuration: const Duration(seconds: 1),
            ),
          );

          // Act
          service.reset();

          // Assert
          expect(service.value, const TContextualButtonsConfig());
        },
      );
    });

    group('config equality', () {
      test(
        '''
        Given two configs with the same function references
        When the configs are compared
        Then they are treated as equal
      ''',
        () {
          // Arrange
          List<Widget> topBuilder(BuildContext _) => const [
            SizedBox(key: ValueKey('top-primary')),
          ];

          final first = TContextualButtonsConfig(top: topBuilder);
          final second = TContextualButtonsConfig(top: topBuilder);

          // Assert
          expect(first, second);
          expect(first.hashCode, second.hashCode);
        },
      );

      test(
        '''
        Given two configs with different function references
        When the configs are compared
        Then they are not equal
      ''',
        () {
          // Arrange
          final first = TContextualButtonsConfig(
            top: (_) => const [SizedBox(key: ValueKey('top-primary'))],
          );
          final second = TContextualButtonsConfig(
            top: (_) => const [SizedBox(key: ValueKey('top-primary'))],
          );

          // Assert
          expect(first, isNot(equals(second)));
        },
      );
    });

    group('dispose', () {
      test(
        '''
        Given a service
        When dispose is called
        Then subsequent updates are ignored
      ''',
        () {
          // Arrange
          final service = TContextualButtonsService();
          final originalValue = service.value;

          // Act
          service.dispose();
          service.hideAllButtons();

          // Assert
          expect(service.value, originalValue);
        },
      );
    });
  });
}
