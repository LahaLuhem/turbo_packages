# turbo_promptable

Object-Oriented Prompting framework for the turbo ecosystem. Define AI agent prompts, roles, workflows, and tools as type-safe Dart objects that serialize to JSON, YAML, Markdown, and XML.

## Features

- Type-safe workspace models: `Role`, `Persona`, `Agent`, `Workflow`, `Step`, `Activity`, `Instruction`, `Input`, `Output`, `Goal`, `Issue`, `Context`, `Template`, `Tool`, and more
- Spec models: `Ability`, `Feature`, `Requirement`, `Scenario`, `Journey`, `Task`, `Module`, `Mockup`, `Prototype`
- Spawnable abstraction (`TSpawnable`) with CLI tool and prompt-delivery enums for launching agents against Claude Code, Cursor, Windsurf, and others
- Cross-referencing abstracts (`OfAbilities`, `OfFeatures`, `OfIssues`, `OfJourneys`, `OfMockups`, `OfModules`, `OfPrds`, `OfProjects`, `OfPrototypes`, `OfScenarios`) for composing specs
- JSON serialization on every model via `json_serializable`; YAML, Markdown, and XML output inherited from [`turbo_serializable`](https://pub.dev/packages/turbo_serializable)
- Structured metadata (`TMetaData`) and body/config control (`TConfig`) on every promptable

## Installation

```yaml
dependencies:
  turbo_promptable: ^0.3.0
```

## Usage

```dart
import 'package:turbo_promptable/turbo_promptable.dart';

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

print(agent.toJson());
```

## Core Concepts

### TPromptable

Every workspace model extends `TPromptable`, which itself extends `TSerializable` from `turbo_serializable`. Models have:

- `name` — required identifier
- `metaData` — optional `TMetaData` for frontmatter (description, tags, etc.)
- `config` — optional `TConfig` for body rendering and inheritance

### Roles, Personas, and Agents

- `Role` — a capability bundle with expertise, activities, checklists, instructions, templates, tools, and workflows
- `Persona` — a `Role` augmented with an `identity` string
- `Agent` — a spawnable `Persona` with CLI tool and command targeting, constructible via `Agent.fromRole(...)` or `Agent.fromPersona(...)`

### Workflows and Steps

A `Workflow` contains an ordered list of `Step`s. Each `Step` has an `Input`, optional `Instruction`s, and an `Output`.

### Specs

Spec models (`Ability`, `Feature`, `Requirement`, `Scenario`, `Journey`, `Task`, `Module`, `Mockup`, `Prototype`) describe intended behaviour and deliverables. They cross-reference each other via the `Of*` abstracts exported from `workspace/abstracts/`.

### Spawnable

`TSpawnable` (used by `Role`, `Persona`, `Agent`) carries `cliTool` (`TCliTool`), `command`, and `promptDelivery` (`TPromptDelivery`) for orchestrating agent launches across tools like Claude Code, Cursor, Windsurf, and custom CLIs.

## License

MIT
