import 'package:test/test.dart';
import 'package:turbo_promptable/turbo_promptable.dart';

void main() {
  test('Goal serializes name via toJson', () {
    final goal = EndGoal(
      'Ship',
      name: 'Ship Goal',
    );
    expect(goal.toJson()['name'], 'Ship');
  });
}
