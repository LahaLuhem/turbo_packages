// ignore_for_file: avoid_print

import 'package:turbo_promptable/turbo_promptable.dart';

void main() {
  const instruction = Instruction(
    name: 'Code Quality',
    rules: ['No unused imports', 'All public API must have dartdoc'],
    principles: ['Clarity over cleverness'],
  );

  const workflow = Workflow(
    name: 'Review Workflow',
    steps: [
      Step(
        name: 'Analyse',
        input: Input(
          name: 'Source Code',
          request: 'Analyse the provided source code for quality issues.',
        ),
        instructions: [instruction],
        output: Output(name: 'Analysis Report'),
      ),
    ],
  );

  const role = Role(
    name: 'Code Reviewer',
    expertise: 'Static analysis and code quality',
    instructions: [instruction],
    workflows: [workflow],
  );

  final agent = Agent.fromRole(
    role,
    identity: 'A meticulous reviewer focused on maintainability.',
  );

  print('Agent JSON:\n${agent.toJson()}');
}
