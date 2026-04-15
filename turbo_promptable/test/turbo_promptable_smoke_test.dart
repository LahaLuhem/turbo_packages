import 'package:test/test.dart';
import 'package:turbo_promptable/turbo_promptable.dart';

void main() {
  test('Goal serializes name via toJson', () {
    const goal = Goal(name: 'Ship');
    expect(goal.toJson()['name'], 'Ship');
  });
}
