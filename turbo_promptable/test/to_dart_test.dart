import 'package:test/test.dart';
import 'package:turbo_promptable/core/helpers/t_dart_string_helper.dart';
import 'package:turbo_promptable/spawn/enums/t_cli_tool.dart';
import 'package:turbo_promptable/workspace/models/root/activity.dart';
import 'package:turbo_promptable/workspace/models/root/agent.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';
import 'package:turbo_promptable/workspace/models/root/goal.dart';
import 'package:turbo_promptable/workspace/models/root/input.dart';
import 'package:turbo_promptable/workspace/models/root/instruction.dart';
import 'package:turbo_promptable/workspace/models/root/issue.dart';
import 'package:turbo_promptable/workspace/models/root/output.dart';
import 'package:turbo_promptable/workspace/models/root/persona.dart';
import 'package:turbo_promptable/workspace/models/root/prompt_field.dart';
import 'package:turbo_promptable/workspace/models/root/role.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';
import 'package:turbo_promptable/workspace/models/root/template.dart';
import 'package:turbo_promptable/workspace/models/root/tool.dart';
import 'package:turbo_promptable/workspace/models/root/workflow.dart';
import 'package:turbo_promptable/workspace/models/workflows/step.dart';

void main() {
  // =========================================================================
  // String escaping
  // =========================================================================
  group('escapeDartString', () {
    test(
      'Given a string with single quotes '
      'when escaped '
      'then single quotes are backslash-escaped',
      () {
        expect(escapeDartString("it's"), equals(r"it\'s"));
      },
    );

    test(
      'Given a string with dollar signs '
      'when escaped '
      'then dollar signs are backslash-escaped',
      () {
        expect(escapeDartString(r'costs $5'), equals(r'costs \$5'));
      },
    );

    test(
      'Given a string with newlines '
      'when escaped '
      'then newlines become literal \\n',
      () {
        expect(escapeDartString('line1\nline2'), equals(r'line1\nline2'));
      },
    );

    test(
      'Given a string with backslashes '
      'when escaped '
      'then backslashes are doubled',
      () {
        expect(escapeDartString(r'path\to'), equals(r'path\\to'));
      },
    );
  });

  // =========================================================================
  // Simple standalone entities
  // =========================================================================
  group('Template.toDart', () {
    test(
      'Given a Template with name '
      'when toDart is called '
      'then output contains import, const variable, and Template constructor',
      () {
        const sut = Template(name: 'Bug Report');
        final result = sut.toDart();

        expect(
          result,
          contains("import 'package:turbo_promptable/turbo_promptable.dart';"),
        );
        expect(result, contains('const bugReport ='));
        expect(result, contains('Template('));
        expect(result, contains("name: 'Bug Report'"));
      },
    );
  });

  group('Tool.toDart', () {
    test(
      'Given a Tool with name '
      'when toDart is called '
      'then output contains import, const variable, and Tool constructor',
      () {
        const sut = Tool(name: 'Linter');
        final result = sut.toDart();

        expect(
          result,
          contains("import 'package:turbo_promptable/turbo_promptable.dart';"),
        );
        expect(result, contains('const linter ='));
        expect(result, contains('Tool('));
        expect(result, contains("name: 'Linter'"));
      },
    );
  });

  // =========================================================================
  // Checklist — standalone + items rendering
  // =========================================================================
  group('Checklist.toDart', () {
    test(
      'Given a Checklist with items '
      'when toDart is called '
      'then output includes all items as string literals',
      () {
        const sut = Checklist(
          name: 'Pre-Deploy',
          items: ['Run tests', 'Check coverage'],
        );
        final result = sut.toDart();

        expect(result, contains('const preDeploy ='));
        expect(result, contains('Checklist('));
        expect(result, contains("'Run tests'"));
        expect(result, contains("'Check coverage'"));
      },
    );
  });

  // =========================================================================
  // Instruction — optional list omission
  // =========================================================================
  group('Instruction.toDart', () {
    test(
      'Given an Instruction with all optional fields populated '
      'when toDart is called '
      'then all fields appear in output',
      () {
        const sut = Instruction(
          name: 'Code Quality',
          principles: ['DRY', 'SOLID'],
          rules: ['No magic numbers'],
          reasons: ['Maintainability'],
          mindset: ['Growth mindset'],
          approach: ['TDD'],
          responsibilities: ['Review PRs'],
          understandings: ['Architecture patterns'],
          examples: ['See module X'],
        );
        final result = sut.toDart();

        expect(result, contains('principles:'));
        expect(result, contains("'DRY'"));
        expect(result, contains('rules:'));
        expect(result, contains('reasons:'));
        expect(result, contains('mindset:'));
        expect(result, contains('approach:'));
        expect(result, contains('responsibilities:'));
        expect(result, contains('understandings:'));
        expect(result, contains('examples:'));
      },
    );

    test(
      'Given an Instruction with null optional fields '
      'when toDart is called '
      'then null fields are omitted from output',
      () {
        const sut = Instruction(name: 'Minimal');
        final result = sut.toDart();

        expect(result, contains("name: 'Minimal'"));
        expect(result, isNot(contains('principles:')));
        expect(result, isNot(contains('rules:')));
        expect(result, isNot(contains('reasons:')));
        expect(result, isNot(contains('mindset:')));
        expect(result, isNot(contains('approach:')));
        expect(result, isNot(contains('responsibilities:')));
        expect(result, isNot(contains('understandings:')));
        expect(result, isNot(contains('examples:')));
      },
    );

    test(
      'Given an Instruction with empty list fields '
      'when toDart is called '
      'then empty lists are omitted from output',
      () {
        const sut = Instruction(
          name: 'Empty Lists',
          principles: [],
          rules: [],
        );
        final result = sut.toDart();

        expect(result, isNot(contains('principles:')));
        expect(result, isNot(contains('rules:')));
      },
    );
  });

  // =========================================================================
  // Nested entity rendering
  // =========================================================================
  group('Workflow.toDart with nested Steps', () {
    test(
      'Given a Workflow with Steps containing nested Input and Output '
      'when toDart is called '
      'then Steps are rendered as inline constructors',
      () {
        const sut = Workflow(
          name: 'Review Flow',
          steps: [
            Step(
              name: 'Gather Context',
              input: Input(
                name: 'Code Diff',
                request: 'Provide the diff',
                fields: [
                  PromptField(
                    name: 'diff',
                    type: 'String',
                    required: true,
                    description: 'The git diff',
                  ),
                ],
              ),
              instructions: [
                Instruction(name: 'Review Carefully'),
              ],
              output: Output(
                name: 'Review Notes',
                fields: [
                  PromptField(
                    name: 'notes',
                    type: 'String',
                    required: true,
                    description: 'Review findings',
                  ),
                ],
              ),
            ),
          ],
        );
        final result = sut.toDart();

        expect(result, contains('Workflow('));
        expect(result, contains('steps: const ['));
        expect(result, contains('Step('));
        expect(result, contains('Input('));
        expect(result, contains('Output('));
        expect(result, contains('PromptField('));
        expect(result, contains("name: 'Gather Context'"));
      },
    );
  });

  // =========================================================================
  // Activity — deeply nested
  // =========================================================================
  group('Activity.toDart', () {
    test(
      'Given an Activity with Input, Output, and Workflow '
      'when toDart is called '
      'then all nested entities are rendered inline',
      () {
        const sut = Activity(
          name: 'Code Review',
          input: Input(
            name: 'Review Input',
            request: 'Review the PR',
            fields: [
              PromptField(
                name: 'prUrl',
                type: 'String',
                required: true,
                description: 'Pull request URL',
              ),
            ],
          ),
          output: Output(
            name: 'Review Output',
            fields: [
              PromptField(
                name: 'summary',
                type: 'String',
                required: true,
                description: 'Review summary',
              ),
            ],
          ),
          workflow: Workflow(
            name: 'Review Steps',
            steps: [
              Step(
                name: 'Read Code',
                input: Input(
                  name: 'Step Input',
                  request: 'Read the code',
                  fields: [],
                ),
                instructions: [],
                output: Output(
                  name: 'Step Output',
                  fields: [],
                ),
              ),
            ],
          ),
        );
        final result = sut.toDart();

        expect(result, contains('const codeReview ='));
        expect(result, contains('Activity('));
        expect(result, contains('input: Input('));
        expect(result, contains('output: Output('));
        expect(result, contains('workflow: Workflow('));
      },
    );
  });

  // =========================================================================
  // Spawnable hierarchy — Role
  // =========================================================================
  group('Role.toDart', () {
    test(
      'Given a Role with all optional fields populated '
      'when toDart is called '
      'then output includes expertise, promptDelivery, and nested entities',
      () {
        const sut = Role(
          name: 'Admin',
          expertise: 'System administration',
          instructions: [
            Instruction(name: 'Security', rules: ['No plaintext passwords']),
          ],
          checklists: [
            Checklist(name: 'Deploy', items: ['Backup first']),
          ],
        );
        final result = sut.toDart();

        expect(result, contains('const admin ='));
        expect(result, contains('Role('));
        expect(result, contains("name: 'Admin'"));
        expect(result, contains("expertise: 'System administration'"));
        expect(result, contains('promptDelivery: TPromptDelivery.system'));
        expect(result, contains('Instruction('));
        expect(result, contains('Checklist('));
      },
    );

    test(
      'Given a Role with null optional entity lists '
      'when toDart is called '
      'then those lists are omitted from output',
      () {
        const sut = Role(name: 'Minimal', expertise: 'None');
        final result = sut.toDart();

        expect(result, isNot(contains('activities:')));
        expect(result, isNot(contains('checklists:')));
        expect(result, isNot(contains('instructions:')));
        expect(result, isNot(contains('templates:')));
        expect(result, isNot(contains('tools:')));
        expect(result, isNot(contains('workflows:')));
        // cliTool is null, should be omitted
        expect(result, isNot(contains('cliTool:')));
        // command is null, should be omitted
        expect(result, isNot(contains('command:')));
      },
    );
  });

  // =========================================================================
  // Persona
  // =========================================================================
  group('Persona.toDart', () {
    test(
      'Given a Persona with identity and expertise '
      'when toDart is called '
      'then output renders as Persona constructor with identity field',
      () {
        const sut = Persona(
          name: 'Alex',
          expertise: 'Full-stack development',
          identity: 'A helpful senior engineer',
        );
        final result = sut.toDart();

        expect(result, contains('const alex ='));
        expect(result, contains('Persona('));
        expect(result, isNot(contains('Role(')));
        expect(result, contains("identity: 'A helpful senior engineer'"));
        expect(result, contains("expertise: 'Full-stack development'"));
      },
    );
  });

  // =========================================================================
  // Agent
  // =========================================================================
  group('Agent.toDart', () {
    test(
      'Given an Agent '
      'when toDart is called '
      'then output renders as standalone Agent constructor (not factory)',
      () {
        const sut = Agent(
          name: 'Codex',
          expertise: 'Code generation',
          identity: 'An autonomous coding agent',
        );
        final result = sut.toDart();

        expect(result, contains('const codex ='));
        expect(result, contains('Agent('));
        expect(result, isNot(contains('Persona(')));
        expect(result, isNot(contains('fromPersona')));
        expect(result, contains("identity: 'An autonomous coding agent'"));
      },
    );

    test(
      'Given an Agent with cliTool set '
      'when toDart is called '
      'then cliTool enum value is rendered',
      () {
        const sut = Agent(
          name: 'Runner',
          expertise: 'Task execution',
          identity: 'A task runner',
          cliTool: TCliTool.codex,
        );
        final result = sut.toDart();

        expect(result, contains('cliTool: TCliTool.codex'));
      },
    );
  });

  // =========================================================================
  // Special character escaping in nested context
  // =========================================================================
  group('Special character escaping', () {
    test(
      'Given an entity with special characters in string fields '
      'when toDart is called '
      'then strings are properly escaped',
      () {
        const sut = Checklist(
          name: "it's a test",
          items: [
            "Don't forget",
            r'Costs $5',
            'Line1\nLine2',
          ],
        );
        final result = sut.toDart();

        expect(result, contains(r"it\'s a test"));
        expect(result, contains(r"Don\'t forget"));
        expect(result, contains(r'Costs \$5'));
        expect(result, contains(r'Line1\nLine2'));
      },
    );
  });

  // =========================================================================
  // Inline-only entities return constructor expression (no import)
  // =========================================================================
  group('Inline-only entities', () {
    test(
      'Given a Goal '
      'when toDart is called '
      'then it returns a constructor expression without import line',
      () {
        const sut = Goal(name: 'Ship Feature');
        final result = sut.toDart();

        expect(result, isNot(contains('import')));
        expect(result, contains('Goal('));
        expect(result, contains("name: 'Ship Feature'"));
      },
    );

    test(
      'Given a Context '
      'when toDart is called '
      'then it returns a constructor expression without import line',
      () {
        const sut = Context(name: 'Project X');
        final result = sut.toDart();

        expect(result, isNot(contains('import')));
        expect(result, contains('Context('));
      },
    );

    test(
      'Given an Issue '
      'when toDart is called '
      'then it returns a constructor expression without import line',
      () {
        const sut = Issue(name: 'Bug #42');
        final result = sut.toDart();

        expect(result, isNot(contains('import')));
        expect(result, contains('Issue('));
      },
    );

    test(
      'Given a Spec '
      'when toDart is called '
      'then it returns a constructor expression without import line',
      () {
        const sut = Spec(name: 'Auth Spec');
        final result = sut.toDart();

        expect(result, isNot(contains('import')));
        expect(result, contains('Spec('));
      },
    );

    test(
      'Given a PromptField '
      'when toDart is called '
      'then it returns a constructor expression with all 4 fields',
      () {
        const sut = PromptField(
          name: 'url',
          type: 'String',
          required: true,
          description: 'The target URL',
        );
        final result = sut.toDart();

        expect(result, isNot(contains('import')));
        expect(result, contains('PromptField('));
        expect(result, contains("name: 'url'"));
        expect(result, contains("type: 'String'"));
        expect(result, contains('required: true'));
        expect(result, contains("description: 'The target URL'"));
      },
    );
  });

  // =========================================================================
  // Input with optional nested lists
  // =========================================================================
  group('Input.toDartInline nested lists', () {
    test(
      'Given an Input with context, goals, issues, checklists, specs '
      'when toDartInline is called '
      'then all nested entity lists are rendered',
      () {
        const sut = Input(
          name: 'Rich Input',
          request: 'Process all',
          fields: [
            PromptField(
              name: 'data',
              type: 'Map',
              required: true,
              description: 'Payload',
            ),
          ],
          context: [Context(name: 'Background')],
          goals: [Goal(name: 'Deliver')],
          issues: [Issue(name: 'Known Bug')],
          checklists: [
            Checklist(name: 'Verify', items: ['Step 1']),
          ],
          specs: [Spec(name: 'API Spec')],
        );
        final result = sut.toDartInline();

        expect(result, contains('context: const ['));
        expect(result, contains('goals: const ['));
        expect(result, contains('issues: const ['));
        expect(result, contains('checklists: const ['));
        expect(result, contains('specs: const ['));
      },
    );

    test(
      'Given an Input with null optional lists '
      'when toDartInline is called '
      'then null lists are omitted',
      () {
        const sut = Input(
          name: 'Simple',
          request: 'Do it',
          fields: [
            PromptField(
              name: 'x',
              type: 'int',
              required: false,
              description: 'a number',
            ),
          ],
        );
        final result = sut.toDartInline();

        expect(result, isNot(contains('context:')));
        expect(result, isNot(contains('goals:')));
        expect(result, isNot(contains('issues:')));
        expect(result, isNot(contains('checklists:')));
        expect(result, isNot(contains('specs:')));
      },
    );
  });
}
