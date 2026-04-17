# turbo_promptable

Object-Oriented Prompting framework for the turbo ecosystem. Define AI agent prompts, roles, workflows, and tools as type-safe Dart objects that serialize to JSON, YAML, Markdown, and XML.

## Features

- Type-safe workspace models: `Role`, `Persona`, `Workflow`, `Step`, `Activity`, `Instruction`, `Input`, `Output`, `Goal`, `Issue`, `Context`, `Template`, `Tool`, and more
- Spec models: `Ability`, `Feature`, `Requirement`, `Scenario`, `Journey`, `Task`, `Module`, `Mockup`, `Prototype`
- Tool models: `Api`, `Cli`, `Script`, `Mcp`, together with `ToolCommand`, `ToolParameter`, and `ToolParameterOption` for declarative command schemas
- Spawnable abstraction (`TSpawnable`) with CLI tool and prompt-delivery enums for launching agents against Claude Code, Cursor, Windsurf, and others
- Cross-referencing abstracts (`OfAbilities`, `OfFeatures`, `OfIssues`, `OfJourneys`, `OfMockups`, `OfModules`, `OfPrds`, `OfProjects`, `OfPrototypes`, `OfScenarios`) for composing specs
- JSON serialization on every model via `json_serializable`; YAML, Markdown, and XML output inherited from [`turbo_serializable`](https://pub.dev/packages/turbo_serializable)
- Structured metadata (`TMetaData`) on every promptable

## Installation

```yaml
dependencies:
  turbo_promptable: ^0.4.0
```

## Usage

```dart
import 'package:turbo_promptable/turbo_promptable.dart';

const workflow = Workflow(
  name: 'Review Workflow',
  steps: [
    Step(
      name: 'Analyse',
      input: Input(name: 'Source Code'),
      instructions: 'Analyse the provided source code for quality issues.',
      output: Output(
        name: 'Analysis Report',
        schema: 'markdown',
      ),
    ),
  ],
);

const role = Role(
  name: 'Code Reviewer',
  expertise: 'Static analysis and code quality',
  workflows: [workflow],
);

const persona = Persona(
  name: 'Code Reviewer',
  expertise: 'Static analysis and code quality',
  workflows: [workflow],
  identity: 'A meticulous reviewer focused on maintainability.',
);

print(persona.toJson());
```

## Core Concepts

### TPromptable

Every workspace model extends `TPromptable`, which itself extends `TSerializable` from `turbo_serializable`. Models have:

- `name` — required identifier
- `metaData` — optional `TMetaData` for frontmatter (description, tags, etc.) on models that declare it

### Roles and Personas

- `Role` — a spawnable capability bundle with expertise, activities, checklists, instructions, templates, tools, and workflows
- `Persona` — a `Role` augmented with an `identity` string that describes the persona's character; construct via `Persona(...)` or `Persona.fromRole(role: ..., identity: ...)`

### Workflows and Steps

A `Workflow` contains an ordered list of `Step`s. Each `Step` has a required `Input`, a string `instructions` field, and a required `Output`.

### Specs

Spec models (`Ability`, `Feature`, `Requirement`, `Scenario`, `Journey`, `Task`, `Module`, `Mockup`, `Prototype`) describe intended behaviour and deliverables. They cross-reference each other via the `Of*` abstracts exported from `workspace/abstracts/`.

### Tools

Tool subclasses (`Api`, `Cli`, `Script`, `Mcp`) extend the shared `Tool` base, which carries a list of `ToolCommand`s. Each command declares its parameters via `ToolParameter`, and parameters can enumerate discrete `ToolParameterOption`s.

### Spawnable

`TSpawnable` (used by `Role` and `Persona`) carries `cliTool` (`TCliTool`), `command`, and `promptDelivery` (`TPromptDelivery`) for orchestrating agent launches across tools like Claude Code, Cursor, Windsurf, and custom CLIs.

## License

MIT
