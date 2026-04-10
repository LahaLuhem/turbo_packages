// ignore_for_file: avoid_print

import 'package:turbo_promptable/turbo_promptable.dart';

void main() {
  // Define an instruction with rules and principles.
  const instruction = Instruction(
    name: 'Code Quality',
    rules: ['No unused imports', 'All public API must have dartdoc'],
    principles: ['Clarity over cleverness'],
  );

  // Define a workflow with steps.
  const workflow = Workflow(
    name: 'Review Workflow',
    steps: [
      Step(
        name: 'Analyse',
        input: Input(
          name: 'Source Code',
          request: 'Analyse the provided source code',
          fields: [
            PromptField(
              name: 'filePath',
              type: 'String',
              required: true,
              description: 'Path to the file to analyse',
            ),
          ],
        ),
        instructions: [instruction],
        output: Output(
          name: 'Analysis Report',
          fields: [
            PromptField(
              name: 'issues',
              type: 'List<String>',
              required: true,
              description: 'List of issues found',
            ),
          ],
        ),
      ),
    ],
  );

  // Define a role that uses the workflow.
  const role = Role(
    name: 'Code Reviewer',
    expertise: 'Static analysis and code quality',
    instructions: [instruction],
    workflows: [workflow],
  );

  // Create an agent from the role.
  final agent = Agent.fromRole(
    role,
    identity: 'A meticulous reviewer focused on maintainability.',
  );

  // Serialize to JSON.
  final json = agent.toJson();
  print('Agent JSON: $json');

  // Serialize to Markdown.
  final markdown = agent.toMd();
  print('\nAgent Markdown:\n$markdown');
}
