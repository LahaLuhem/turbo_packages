# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.0] - 2026-05-03

### Added
- `TCliTool.spawn()` method for constructing CLI spawn commands with configurable system prompt, allowed tools, model, yolo mode, and headless flags
- `TCliTool` resume, system prompt, allowed tools, yolo, and model parameter builders
- `TConfigSource` enum for distinguishing configuration origins
- `TSpawnable` base class (under `workspace/models/meta/`) for agent-like models with `id`, `allowedTools`, `yolo`, `model`, and `headless` fields

### Changed
- **BREAKING**: Moved `TSpawnable` from `spawn/abstracts/` to `workspace/models/meta/` with a new constructor API (`name` as positional, `id` as required named, plus `allowedTools`, `yolo`, `model`, `headless` fields)
- **BREAKING**: `Agent` now extends the new `TSpawnable` and requires `id`, `allowedTools`, `yolo`, `model`, `headless` parameters
- `EndGoal` now requires `name` as a required named parameter
- Regenerated all JSON serialization files to match updated model signatures

### Fixed
- Removed unused imports and unnecessary import directives flagged by the analyzer

## [0.4.0] - 2026-04-17

### Added
- Tool command model `ToolCommand` for declaring individual operations that a `Tool` exposes (CLI subcommands, REST endpoints, MCP functions, etc.)
- Tool parameter models `ToolParameter` and `ToolParameterOption` for describing command inputs, enumerated options, defaults, and required flags
- Tool ability model `ToolAbility` for describing the capabilities surfaced by a tool
- `Mcp` tool model for declaring Model Context Protocol servers alongside the existing `Api`, `Cli`, and `Script` tool kinds
- `TMetaData` is now re-exported from `meta/t_promptable.dart` so downstream models that depend on it no longer need a separate import

### Changed
- **BREAKING**: Removed the `Agent` root model. Use `Persona` extended with `TSpawnable` fields (`cliTool`, `command`, `promptDelivery`) to represent a launchable agent.
- **BREAKING**: Dropped the `metaData` constructor parameter from leaf context/root models that do not need it (`Actor`, `Concept`, `Documentation`, `Project`, `Stakeholder`, `Subject`, `Checklist`, `Context`, and related models). Pass metadata only on the models that still declare the parameter.
- **BREAKING**: Removed barrel exports for internal/auxiliary members: `core/constants/tp_keys.dart`, `core/models/t_config.dart`, `core/models/t_embed_type.dart`, `core/models/t_md_section.dart`, `core/models/t_render_type.dart`, `core/typedefs/t_body_builder_def.dart`, `workspace/models/checklists/acceptance_criteria.dart`, `workspace/models/checklists/constraints.dart`, `workspace/models/checklists/non_goals.dart`, and `workspace/models/meta/t_tag.dart`. Consumers that relied on those names should import the deep paths directly or model their own equivalents.
- `TPromptable.mdFactory` now derives its body from `toJson()` (minus the metadata key) so frontmatter/body separation is consistent across every subclass.
- Bumped minimum `turbo_serializable` constraint to `^0.5.0` (pulls in the `ts_map_extension` rename and the wider barrel exposure from that release).

### Fixed
- Removed unused and unnecessary imports flagged by the analyzer in `workspace/models/context/collection.dart`, `workspace/models/root/activity.dart`, and `workspace/models/root/persona.dart`.

## [0.3.0] - 2026-04-15

### Changed
* **BREAKING**: Remove Dart source rendering from workspace entities (per-entity emission methods, helper mixins/classes under `lib/core/helpers/`, and the dedicated rendering test file). JSON, YAML, Markdown, and XML serialization remain.
* Document public members on `Ability` so pub.dev documentation scoring stays at or above the 20% API threshold.

## [0.2.0] - 2026-04-13

### Added
* `TSpawnable` base class for promptable models that can be spawned as CLI processes
* `TCliTool` enum for supported CLI tools (Claude Code, Cursor, Windsurf, etc.)
* `TPromptDelivery` enum for prompt delivery methods (system, user, stdin, file)
* Spawn module with `TFile`, `TFolder`, and `TSpawnConfig` models
* New root models: `Activity`, `Agent`, `Checklist`, `Context`, `Goal`, `Input`, `Instruction`, `Issue`, `Output`, `Persona`, `PromptField`, `Role`, `Spec`, `Template`, `Tool`, `Workflow`
* New spec models: `Mockup`, `Module`, `Prototype`, `Task` with cross-referencing via `Of*` interfaces
* `TDartRenderHelper` mixin for rendering models as Dart constructor calls
* `TDartStringHelper` for Dart-safe string escaping
* Workspace abstracts: `OfAbilities`, `OfFeatures`, `OfIssues`, `OfJourneys`, `OfMockups`, `OfModules`, `OfPrds`, `OfProjects`, `OfPrototypes`, `OfScenarios`
* `Project` context model
* `Step` workflow model with ordering and substep support

### Changed
* **BREAKING**: Removed `TTask` root model — replaced by the richer `Task` spec model
* **BREAKING**: Expanded `Role` from a simple model to a full spawnable with activities, checklists, instructions, templates, tools, and workflows
* **BREAKING**: `Persona` and `Agent` now extend `TSpawnable` with CLI tool and command support
* Enriched `Activity` with `persona`, `goal`, `input`, `output`, `context`, and `workflow` fields
* Enriched `Input` with `format`, `constraints`, and `validations` fields
* Enriched `Output` with `format`, `constraints`, `validations`, and `deliverables` fields
* Enriched `Instruction` with `scope`, `priority`, `applicability`, and `examples` fields
* Enriched spec models (`Ability`, `Feature`, `Requirement`, `Scenario`) with cross-referencing IDs

## [0.1.0] - 2026-04-10

### Added
- Workspace model system with 8 domain groups: checklists, context, instructions, memories, meta, root, specs, tools, and workflows
- Checklist models: `TAcceptanceCriteria`, `TConstraints`, `TNonGoals` with JSON serialization
- Context models: `TActor`, `TCollection`, `TConcept`, `TDocumentation`, `TReference`, `TStakeholder`, `TSubject` with JSON serialization
- Instruction models: `TConvention`, `TSkill` with JSON serialization
- Memory models: `TDecision`, `TEvent`, `TInsight`, `TMeeting`, `TProgress` with JSON serialization
- Meta models: `TMetaData`, `TPromptable` with JSON serialization
- Root models: `TActivity`, `TAgent`, `TChecklist`, `TContext`, `TGoal`, `TInput`, `TInstruction`, `TIssue`, `TMemory`, `TOutput`, `TPersona`, `TPromptField`, `TRole`, `TSpec`, `TTask`, `TTemplate`, `TTool`, `TWorkflow` with JSON serialization
- Spec models: `TAbility`, `TFeature`, `TJourney`, `TRequirement`, `TScenario` with JSON serialization
- Tool models: `TApi`, `TCli`, `TScript` with JSON serialization
- Workflow model: `TStep` with JSON serialization
- Enums: `TBodyType`, `TRefType`
- Core extensions: `TCollectionExtensions` for YAML and XML serialization of lists/maps
- Core models: `TConfig`, `TEmbedType`, `TMdSection`, `TRenderType`
- Spawn models: `TFile`, `TFolder`, `TSpawnConfig`
- `json_annotation` dependency for generated JSON serialization

### Changed
- **BREAKING**: Restructured from flat DTO-based architecture to domain-grouped workspace model system
- **BREAKING**: Removed all previous DTO classes (TeamDto, AreaDto, RoleDto, CollectionDto, InstructionDto, etc.)
- **BREAKING**: Removed example files and export configuration system (ExportConfig, ExportType, ExportResult)
- Replaced `path` dependency on `turbo_serializable` with versioned constraint `^0.3.0`

## [0.0.2] - 2026-03-19

### Fixed
- Included generated `.g.dart` files in package

### Changed
- Restructured into 6 domain groups with shared infrastructure

## [0.0.1] - 2026-01-01

### Added
- Initial release
- TurboPromptable base class extending TurboSerializable
- Convenience `name` and `description` constructor parameters on all DTOs
- Automatic FrontmatterDto creation from name/description
- ExportConfig with fileType, bodyType, shouldExport, fileName
- ExportType enum (md, yaml, json, xml, txt, dart)
- BodyType enum (markdown, yaml, json, xml, dart)
- Tree structure with config inheritance via resolveConfig
- YAML frontmatter generation via generateFrontmatter
- Body export via exportBody
- FrontmatterDto for structured metadata (name, description, values)
- ExportResult for export output (body, frontmatter, config, promptable)
- export() method with shouldExport filtering
- exportTree() method for recursive tree export
- Hierarchy DTOs: TeamDto, AreaDto, RoleDto
- Knowledge DTOs: CollectionDto, InstructionDto, WorkflowDto, ReferenceDto, TemplateDto, RawBoxDto, ActivityDto, AgentDto, RepoDto
- Tool DTOs: ToolDto, ApiDto, ScriptDto, ToolMethodDto, ToolParameterDto
- PersonaDto for agent identity
