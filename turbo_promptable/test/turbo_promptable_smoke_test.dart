import 'package:test/test.dart';
import 'package:turbo_promptable/turbo_promptable.dart';

void main() {
  test('Goal serializes name via toJson', () {
    const goal = EndGoal('Ship');
    expect(goal.toJson()['name'], 'Ship');
  });
}
