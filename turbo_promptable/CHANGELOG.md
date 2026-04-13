# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
