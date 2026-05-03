// ignore_for_file: avoid_print

import 'package:turbo_promptable/turbo_promptable.dart';

void main() {
  const instruction = Instruction(
    'Code Quality',
    rules: ['No unused imports', 'All public API must have dartdoc'],
    principles: ['Clarity over cleverness'],
  );

  const workflow = Workflow(
    endGoal: EndGoal(
      'Produce a comprehensive analysis report highlighting code quality issues and providing actionable suggestions for improvement.',
      name: 'Code Quality Analysis',
    ),
    name: 'Review Workflow',
    steps: [
      Step(
        name: 'Analyse',
        instructions:
            'Review the source code for quality issues based on the provided instructions.',
        input: Input(
          name: 'Source Code',
        ),
        output: Output(
          name: 'Analysis Report',
          schema: 'A detailed report of code quality issues and suggestions.',
        ),
      ),
    ],
  );

  const role = Role(
    name: 'Code Reviewer',
    expertise: 'Static analysis and code quality',
    instructions: [instruction],
  );

  print(role.toMd());
  print(workflow.toMd());
}
