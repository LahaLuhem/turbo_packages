# Turbo Packages Architecture

A Dart/Flutter monorepo providing core infrastructure packages for building production applications.

## Technology Stack

| Technology | Version | Purpose |
|---|---|---|
| Dart SDK | ^3.6.0 | Language runtime |
| Flutter SDK | >=1.17.0 | UI framework (packages requiring widgets) |
| Melos | ^7.3.0 | Monorepo management, versioning, scripts |
| Cloud Firestore | ^6.0.2 | Database (turbo_firestore_api) |
| Firebase Auth | ^6.1.0 | Authentication (turbo_firestore_api) |
| RxDart | ^0.28.0 | Reactive extensions (turbo_firestore_api) |
| Provider | ^6.1.5+1 | DI/state provision (turbo_mvvm) |
| GetIt | ^9.2.0 | Service locator (turbolytics) |
| ShadCN UI | latest | UI framework (turbo_forms, turbo_widgets) |
| Equatable | latest | Equality (turbo_forms) |
| json_annotation | ^4.9.0 | JSON serialization (turbo_promptable, turbo_plx_cli) |
| xml | ^6.3.0 | XML serialization (turbo_serializable) |
| yaml | ^3.1.0 | YAML serialization (turbo_serializable) |
| change_case | ^2.2.0 | Case conversion (turbo_serializable) |

## Project Structure

```
turbo_packages/
├── pubspec.yaml                    # Workspace root with Melos config
├── tool/                           # Shared CI scripts (test_with_coverage.sh, pub_check.sh, pub_publish.sh)
├── openspec/                       # OpenSpec artifacts (non-package)
├── turbo_response/                 # Result type: Success/Fail
├── turbo_serializable/             # Serialization abstractions (JSON, YAML, Markdown, XML)
├── turbo_notifiers/                # Enhanced ValueNotifier + multi-listenable builders
├── turbolytics/                    # Logging, analytics, crash reports
├── turbo_mvvm/                     # MVVM base classes + busy/error management
├── turbo_firestore_api/            # Type-safe Firestore CRUD, streaming, services
├── turbo_forms/                    # Form field configuration + validation (ShadCN)
├── turbo_widgets/                  # Reusable UI widgets, responsive, navigation, playground
├── turbo_promptable/               # OOP prompting framework for AI agents
├── turbo_plx_cli/                  # File operations via plx CLI subprocess
└── turbo_template/                 # Production Flutter app template/scaffold (310+ Dart files)
```

## Architecture Patterns

**Result Type Pattern**: All fallible operations return `TurboResponse<T>` (sealed class with `Success<T>` and `Fail<T>` subtypes) instead of throwing exceptions. Pattern matching via `when()`, `fold()`, `mapSuccess()`, `andThen()`.

**MVVM**: `TBaseViewModel` extends `ChangeNotifier`, provided to the widget tree via `TViewModelBuilder` using the Provider package. View models compose mixins for busy state (`TBusyManagement`), error state (`TErrorManagement`), and helpers (`TViewModelHelpers`).

**Reactive State**: `TNotifier<T>` extends Flutter's `ValueNotifier` with `forceUpdate` flag for collection types, silent updates, and `updateCurrent()` for functional transforms. Multi-value listening via `ValueListenableBuilderX2` through `X6` and `MultiListenableBuilder`.

**Firestore Services**: `TAuthSyncService` syncs data with Firebase Auth state. `TCollectionService` manages collection state with local optimistic updates. `TDocumentService` manages single-document state. Both extend `TAuthSyncService` and wrap `TFirestoreApi`.

**Serialization**: `TWriteable` (toJson + validate) → `TSerializable` (adds toYaml, toMarkdown, toXml via builder pattern). `TWriteableId` / `TWriteableCustomId<T>` add typed identifiers for Firestore documents.

**Dependency Injection**: GetIt via turbolytics for service location. Provider for widget-tree scoped view models.

**Folder Convention**: `{feature}/{concept-folder}/{filename}` with concept folders: abstracts, apis, config, constants, dtos, enums, exceptions, extensions, mixins, models, services, typedefs, utils, views, widgets.

## Component Inventory

### Packages

| Package | Version | Purpose | Dependencies |
|---|---|---|---|
| turbo_response | 1.1.0 | Result type (Success/Fail) for operation outcomes | None |
| turbo_serializable | 1.0.0 | Multi-format serialization abstractions (JSON, YAML, Markdown, XML) | turbo_response, change_case, meta, xml, yaml |
| turbo_notifiers | 1.1.0 | Enhanced ValueNotifier with forceUpdate, silent updates, multi-listenable builders | flutter |
| turbolytics | 1.1.0 | Structured logging, analytics, crash reports with event bus | flutter, get_it |
| turbo_mvvm | 1.1.0 | MVVM base classes, busy/error management, TViewModelBuilder | flutter, provider |
| turbo_firestore_api | 0.9.0 | Type-safe Firestore CRUD, streaming, collection/document services | cloud_firestore, firebase_auth, rxdart, turbo_response, turbo_serializable, turbo_notifiers, turbolytics |
| turbo_forms | 1.0.1 | Type-safe form field configuration and validation with ShadCN UI | flutter, equatable, shadcn_ui, turbo_notifiers, turbolytics |
| turbo_widgets | 1.1.0 | Reusable UI widgets, responsive utilities, navigation, playground | flutter, shadcn_ui, cached_network_image, flutter_hooks, soft_edge_blur |
| turbo_promptable | 0.0.1 | OOP prompting framework for AI agent roles, workflows, tools | turbo_serializable, turbo_response, json_annotation |
| turbo_plx_cli | 0.0.1 | Firestore-like API for local file operations via plx CLI subprocess | turbo_response, json_annotation |
| turbo_template | N/A | Production Flutter app template/scaffold with Firebase integration | All turbo packages |

### Abstract Classes / Interfaces / Mixins

| Name | Path | Purpose |
|---|---|---|
| TWriteable | turbo_serializable/lib/abstracts/t_writeable.dart | Base for JSON-serializable objects with validate() |
| TWriteableId | turbo_serializable/lib/abstracts/t_writeable_id.dart | TWriteable with String id |
| TWriteableCustomId\<T\> | turbo_serializable/lib/abstracts/t_writeable_custom_id.dart | TWriteable with typed id |
| TSerializable | turbo_serializable/lib/abstracts/t_serializable.dart | Multi-format serialization (JSON, YAML, Markdown, XML) |
| TSerializableId | turbo_serializable/lib/abstracts/t_serializable_id.dart | TSerializable with dynamic id |
| TChangeNotifier | turbo_notifiers/lib/t_change_notifier.dart | ChangeNotifier exposing rebuild() publicly |
| TBaseViewModel\<A\> | turbo_mvvm/lib/data/models/t_base_view_model.dart | Base view model with lifecycle, arguments, context |
| TBusyManagement | turbo_mvvm/lib/data/mixins/t_busy_management.dart | Local busy state via ValueNotifier |
| TBusyServiceManagement | turbo_mvvm/lib/data/mixins/t_busy_service_management.dart | Global busy state via TBusyService singleton |
| TErrorManagement | turbo_mvvm/lib/data/mixins/t_error_management.dart | Error state with title/message |
| TViewModelHelpers | turbo_mvvm/lib/data/mixins/t_view_model_helpers.dart | Utility methods (wait, addPostFrameCallback) |
| TFirestoreApi\<T\> | turbo_firestore_api/lib/apis/t_firestore_api.dart | Type-safe Firestore CRUD, streaming, search |
| TAuthSyncService\<T\> | turbo_firestore_api/lib/services/t_auth_sync_service.dart | Auth-state-synced data service base |
| TCollectionService\<T, API\> | turbo_firestore_api/lib/services/t_collection_service.dart | Collection state with local optimistic updates |
| TDocumentService\<T, API\> | turbo_firestore_api/lib/services/t_document_service.dart | Single-document state management |
| TExceptionHandler | turbo_firestore_api/lib/mixins/t_exception_handler.dart | Firestore exception handling mixin |
| TFormConfig | turbo_forms/lib/src/abstracts/t_form_config.dart | Form-level validation and field config map |
| TContextualButtonsServiceInterface | turbo_widgets/lib/src/abstracts/t_contextual_buttons_service_interface.dart | Interface for contextual buttons state |
| TNavigationTabServiceInterface\<T\> | turbo_widgets/lib/src/abstracts/t_navigation_tab_service_interface.dart | Interface for active navigation tab tracking |
| TContextualButtonsManagement | turbo_widgets/lib/src/mixins/t_contextual_buttons_management.dart | Mixin for managing contextual buttons |
| PlxClientInterface | turbo_plx_cli/lib/src/abstracts/plx_client_interface.dart | Interface for plx CLI client |
| CrashReportsInterface | turbolytics/lib/src/crash_reports/crash_reports_interface.dart | Contract for crash reporting providers |
| TAnalyticsInterface | turbolytics/lib/src/analytics/t_analytics_interface.dart | Contract for analytics providers |
| Turbolytics\<D\> | turbolytics/lib/src/turbolytics/turbolytics.dart | Main mixin providing logging, analytics, crashlytics |
| TurboPromptable | turbo_promptable/lib/shared/abstracts/turbo_promptable.dart | Base class for all promptable objects |
| HasToJson | turbo_promptable/lib/abstracts/has_to_json.dart | Interface for JSON-convertible objects |

### DTOs / Models / Records

| Name | Path | Purpose |
|---|---|---|
| TurboResponse\<T\> | turbo_response/lib/src/turbo_response.dart | Sealed result type (Success\<T\> / Fail\<T\>) |
| TurboException | turbo_response/lib/src/turbo_exception.dart | Exception with error, title, message, stackTrace |
| TBusyModel | turbo_mvvm/lib/data/models/t_busy_model.dart | Immutable busy state (isBusy, busyType, title, message, payload) |
| TApiVars | turbo_firestore_api/lib/models/t_api_vars.dart | API operation variables (id, now) |
| TAuthVars | turbo_firestore_api/lib/models/t_auth_vars.dart | Auth-scoped API variables (userId) |
| TSensitiveData | turbo_firestore_api/lib/models/t_sensitive_data.dart | Logging context with optional data redaction |
| TWriteBatchWithReference\<T\> | turbo_firestore_api/lib/models/t_write_batch_with_reference.dart | Batch operation result with document reference |
| TFormFieldConfig\<T\> | turbo_forms/lib/src/config/t_form_field_config.dart | Reactive form field configuration (extends TNotifier) |
| TFormFieldState\<T\> | turbo_forms/lib/src/config/t_form_field_config.dart | Immutable form field state (Equatable) |
| TPlaygroundParameterModel | turbo_widgets/lib/src/models/playground/t_playground_parameter_model.dart | Component parameter model for playground |
| TSelectOption\<T\> | turbo_widgets/lib/src/models/playground/t_select_option.dart | Select/enum option wrapper |
| TButtonConfig | turbo_widgets/lib/src/models/navigation/t_button_config.dart | Navigation button configuration |
| TContextualButtonsConfig | turbo_widgets/lib/src/models/t_contextual_buttons_config.dart | Contextual buttons display configuration |
| TProportionalItem | turbo_widgets/lib/src/models/layout/t_proportional_item.dart | Proportional grid item with size weight |
| ProportionalLayoutResult | turbo_widgets/lib/src/models/layout/proportional_layout_result.dart | Computed layout result for proportional grid |
| TBreakpointConfig | turbo_widgets/lib/src/responsive/config/t_breakpoint_config.dart | Responsive breakpoint configuration |
| TData | turbo_widgets/lib/src/responsive/models/t_data.dart | Responsive data (dimensions, orientation, device type) |
| TCardOption | turbo_widgets/lib/src/widgets/forms/interactive_form/models/t_card_option.dart | Card option for interactive form |
| TInteractiveFormStepConfig | turbo_widgets/lib/src/widgets/forms/interactive_form/models/t_interactive_form_step_config.dart | Sealed base for form step configs |
| FileEntryDto | turbo_plx_cli/lib/src/dtos/file_entry_dto.dart | File path, content, lastModified |
| WatchEventDto | turbo_plx_cli/lib/src/dtos/watch_event_dto.dart | File system event (type, path, content, files) |
| WatchConfigDto | turbo_plx_cli/lib/src/dtos/watch_config_dto.dart | Watch configuration (throttle, extensions, ignore) |
| TAnalytic | turbolytics/lib/src/analytics/t_analytic.dart | Analytics event data (subject, type, parameters) |
| CustomAnalytic | turbolytics/lib/src/analytics/t_analytic.dart | Flexible analytics with custom name |
| ActivityDto\<I, O\> | turbo_promptable/lib/activities/dtos/activity_dto.dart | Generic AI activity with typed I/O |
| WorkflowDto | turbo_promptable/lib/workflows/dtos/workflow_dto.dart | Workflow with guard rails and steps |
| WorkflowStep\<I, O\> | turbo_promptable/lib/workflows/dtos/workflow_step.dart | Typed workflow step |
| RoleDto | turbo_promptable/lib/roles/dtos/role_dto.dart | Agent role with expertise and persona |
| ExpertiseDto | turbo_promptable/lib/roles/dtos/expertise_dto.dart | Field, specialization, experience |
| PersonaDto | turbo_promptable/lib/roles/dtos/persona_dto.dart | Agent identity and personality |
| TeamDto | turbo_promptable/lib/teams/dtos/team_dto.dart | Team with areas and roles |
| AreaDto | turbo_promptable/lib/areas/dtos/area_dto.dart | Organizational area with roles |
| SubAgentDto | turbo_promptable/lib/activities/dtos/sub_agent_dto.dart | Sub-agent with role |
| EndGoalDto | turbo_promptable/lib/activities/dtos/end_goal_dto.dart | Goal with acceptance criteria and constraints |
| InstructionDto | turbo_promptable/lib/activities/dtos/instruction_dto.dart | Behavioral instruction |
| GuardRailDto | turbo_promptable/lib/activities/dtos/guard_rail_dto.dart | Execution constraint |
| RepoDto | turbo_promptable/lib/office/dtos/repo_dto.dart | Repository reference |
| TemplateDto | turbo_promptable/lib/office/dtos/template_dto.dart | Reusable pattern with variables |
| CollectionDto | turbo_promptable/lib/office/dtos/collection_dto.dart | Collection of items |
| ReferenceDto | turbo_promptable/lib/office/dtos/reference_dto.dart | Static documentation reference |
| RawBoxDto | turbo_promptable/lib/office/dtos/raw_box_dto.dart | Unprocessed input material |
| ScriptDto\<I, O\> | turbo_promptable/lib/tools/dtos/script_dto.dart | Executable script tool with typed I/O |
| ApiDto | turbo_promptable/lib/tools/dtos/api_dto.dart | HTTP/REST API tool |
| MetaDataDto | turbo_promptable/lib/shared/dtos/meta_data_dto.dart | Name and description metadata |

### Services

| Name | Path | Purpose | Type | Dependencies |
|---|---|---|---|---|
| TBusyService | turbo_mvvm/lib/services/t_busy_service.dart | Global app-wide busy state with mutex | Singleton | TBusyModel, TBusyType |
| TContextualButtonsService | turbo_widgets/lib/src/services/t_contextual_buttons_service.dart | Manages contextual buttons at 4 positions | Singleton | TContextualButtonsConfig |
| TInteractiveFormController | turbo_widgets/lib/src/widgets/forms/interactive_form/controllers/t_interactive_form_controller.dart | Multi-step form pagination and validation | Factory | TInteractiveFormStepConfig |
| TAnalyticsService | turbolytics/lib/src/analytics/t_analytics_service.dart | 97+ predefined analytics event methods | Factory | TLog, TEventBus |
| TAnalyticsFactory | turbolytics/lib/src/analytics/t_analytics_factory.dart | Registers analytics implementations via GetIt | Factory | GetIt |
| PlxClient | turbo_plx_cli/lib/src/services/plx_client.dart | Connects to plx CLI subprocess for file ops | Factory | PlxClientInterface |

### APIs

| Name | Path | Purpose |
|---|---|---|
| TFirestoreApi\<T\> | turbo_firestore_api/lib/apis/t_firestore_api.dart | Type-safe Firestore CRUD, streaming, search, transactions, batches |
| PlxApi | turbo_plx_cli/lib/src/apis/plx_api.dart | Firestore-like API for local file operations (get, list, create, update, delete, stream) |

### Widgets / Components

| Name | Path | Purpose |
|---|---|---|
| TViewModelBuilder\<T\> | turbo_mvvm/lib/widgets/t_view_model_builder.dart | Provides view model to widget tree via Provider |
| TViewModelWidget\<T\> | turbo_mvvm/lib/widgets/t_view_model_widget.dart | Abstract widget for view model consumption |
| TNotifier\<T\> | turbo_notifiers/lib/t_notifier.dart | Enhanced ValueNotifier with forceUpdate, silent updates |
| MultiListenableBuilder | turbo_notifiers/lib/src/widgets/multi_listenable_builder.dart | Rebuilds on any Listenable notification |
| ValueListenableBuilderX2-X6 | turbo_notifiers/lib/src/widgets/ | Multi-value listenable builders (2-6 sources) |
| TFormField\<T\> | turbo_forms/lib/src/widgets/t_form_field.dart | Form field with label, description, error display |
| TFormFieldBuilder\<T\> | turbo_forms/lib/src/widgets/t_form_field_builder.dart | Reactive form field content builder |
| TErrorLabel | turbo_forms/lib/src/widgets/t_error_label.dart | Animated error text display |
| VerticalShrink | turbo_forms/lib/src/widgets/vertical_shrink.dart | Animated vertical size/opacity toggle |
| TFeatureCard | turbo_widgets/lib/src/widgets/cards/t_feature_card.dart | Feature card with gradient and icon |
| TCategoryCard | turbo_widgets/lib/src/widgets/category/t_category_card.dart | Interactive category card |
| TCategorySection | turbo_widgets/lib/src/widgets/category/t_category_section.dart | Section with horizontal/grid category items |
| TCollectionCard | turbo_widgets/lib/src/widgets/collection/t_collection_card.dart | Collection item card |
| TCollectionSection | turbo_widgets/lib/src/widgets/collection/t_collection_section.dart | Section with bento/list/grid collection items |
| TCollectionToolbar | turbo_widgets/lib/src/widgets/collection/t_collection_toolbar.dart | Search, sort, filter, layout toggle toolbar |
| TDetailHeader | turbo_widgets/lib/src/widgets/detail/t_detail_header.dart | Detail page header with save action |
| TFormSection | turbo_widgets/lib/src/widgets/detail/t_form_section.dart | Collapsible form section |
| TKeyValueField | turbo_widgets/lib/src/widgets/detail/t_key_value_field.dart | Key-value display field |
| TInteractiveForm | turbo_widgets/lib/src/widgets/forms/interactive_form/t_interactive_form.dart | Multi-step form with PageView |
| TProportionalGrid | turbo_widgets/lib/src/widgets/layout/t_proportional_grid.dart | Squarified treemap layout |
| TContextualAppBar | turbo_widgets/lib/src/widgets/navigation/t_contextual_app_bar.dart | App bar with contextual buttons |
| TContextualBottomNavigation | turbo_widgets/lib/src/widgets/navigation/t_contextual_bottom_navigation.dart | Bottom navigation |
| TContextualSideNavigation | turbo_widgets/lib/src/widgets/navigation/t_contextual_side_navigation.dart | Side navigation |
| TSideNavBar | turbo_widgets/lib/src/widgets/navigation/t_side_nav_bar.dart | Responsive side nav (vertical/horizontal) |
| TContextualButtons | turbo_widgets/lib/src/widgets/t_contextual_buttons.dart | 4-position contextual buttons wrapper |
| TPlayground | turbo_widgets/lib/src/widgets/t_playground.dart | Component prototyping playground |
| TCollapsibleSection | turbo_widgets/lib/src/widgets/t_collapsible_section.dart | Collapsible card section |
| TShowcaseItem | turbo_widgets/lib/src/widgets/t_showcase_item.dart | Showcase item with badge title |
| TShowcaseSection | turbo_widgets/lib/src/widgets/t_showcase_section.dart | Collapsible showcase section |
| TResponsiveBuilder | turbo_widgets/lib/src/responsive/widgets/t_responsive_builder.dart | Responsive layout builder |

### Enums / Constants / Config

| Name | Path | Purpose |
|---|---|---|
| TBusyType | turbo_mvvm/lib/data/enums/t_busy_type.dart | Busy indicator variants (none, indicator, backdrop, ignorePointer) |
| TurboMvvmDefaults | turbo_mvvm/lib/data/constants/turbo_mvvm_defaults.dart | Default durations and flags |
| TTimestampType | turbo_firestore_api/lib/enums/t_timestamp_type.dart | Timestamp field behavior (createdAt, updatedAt, both, none) |
| TSearchTermType | turbo_firestore_api/lib/enums/t_search_term_type.dart | Search strategies (startsWith, arrayContains) |
| TOperationType | turbo_firestore_api/lib/enums/t_operation_type.dart | Operation categories (read, write, create, update, delete, stream) |
| TErrorCodes | turbo_firestore_api/lib/constants/t_error_codes.dart | Firestore error codes and default messages |
| TFieldType | turbo_forms/lib/src/enums/t_field_type.dart | 20 form field types (textInput, select, datePicker, etc.) |
| TurboFormsDefaults | turbo_forms/lib/src/constants/turbo_forms_defaults.dart | Animation durations, padding, opacity defaults |
| TLogLevel | turbolytics/lib/src/enums/t_log_level.dart | Log levels (trace, debug, info, analytic, warning, error, fatal) |
| TAnalyticsType | turbolytics/lib/src/enums/t_analytics_type.dart | 97 analytics event types |
| TCrashReportType | turbolytics/lib/src/enums/t_crash_report_type.dart | Crash report format (location, tagLocation, iconTagLocation) |
| TurboWidgetsDefaults | turbo_widgets/lib/src/constants/turbo_widgets_defaults.dart | Animation, hover, throttle, debounce durations |
| TCategorySectionLayout | turbo_widgets/lib/src/enums/t_category_section_layout.dart | horizontal, grid |
| TCollectionSectionLayout | turbo_widgets/lib/src/enums/t_collection_section_layout.dart | bento, list, grid |
| TContextualPosition | turbo_widgets/lib/src/enums/t_contextual_position.dart | top, bottom, left, right |
| TDeviceType | turbo_widgets/lib/src/responsive/enums/t_device_type.dart | mobile, tablet, desktop |
| WatchEventType | turbo_plx_cli/lib/src/enums/watch_event_type.dart | create, modify, delete, error, get, list |
| TurboPlxCliDefaults | turbo_plx_cli/lib/src/constants/turbo_plx_cli_defaults.dart | Throttle, extensions, ignore folders, timeout |
| WorkflowStepType | turbo_promptable/lib/activities/enums/workflow_step_type.dart | assess, research, enrich, align, refine, plan, act, review, test, deliver |
| MetaDataKeys | turbo_promptable/lib/shared/constants/meta_data_keys.dart | Metadata key constants |

### Exceptions

| Name | Path | Purpose |
|---|---|---|
| TurboException | turbo_response/lib/src/turbo_exception.dart | Exception with error, title, message, stackTrace |
| TFirestoreException (sealed) | turbo_firestore_api/lib/exceptions/t_firestore_exception.dart | Firestore exception hierarchy (PermissionDenied, Unavailable, NotFound, AlreadyExists, Cancelled, DeadlineExceeded, Generic) |
| InvalidJsonException | turbo_firestore_api/lib/exceptions/invalid_json_exception.dart | Invalid JSON data exception |
| PlxException | turbo_plx_cli/lib/src/exceptions/plx_exception.dart | CLI communication exception |

### Extensions

| Name | Path | Purpose |
|---|---|---|
| TurboResponseX\<T\> | turbo_response/lib/src/turbo_response.dart | isSuccess, isFail, when, mapSuccess, mapFail, andThen, recover, unwrap, cast, ensure, swap, traverse, sequence |
| TMapExtension | turbo_firestore_api/lib/extensions/t_map_extension.dart | Add/remove local ID, document reference, timestamps |
| TListExtension | turbo_firestore_api/lib/extensions/t_list_extension.dart | List utilities for Firestore operations |
| CompleterExtension | turbo_firestore_api/lib/extensions/completer_extension.dart | Completer utilities |
| FormFieldConfigStringExtension | turbo_forms/lib/src/config/t_form_field_config.dart | valueTrimIsEmpty for string form fields |
| TurboFormNumExtension | turbo_forms/lib/src/extensions/turbo_form_field_extensions.dart | tHasDecimals |
| TurboFormStringExtension | turbo_forms/lib/src/extensions/turbo_form_field_extensions.dart | tTryAsDouble, tTryAsInt, tNaked, tTrimIsEmpty |
| TurboFormObjectExtension | turbo_forms/lib/src/extensions/turbo_form_field_extensions.dart | tAsType\<E\> |
| BoxConstraintsExtension | turbo_widgets/lib/src/responsive/extensions/box_constraints_extension.dart | orientation, deviceType |
| TScaleExtension | turbo_widgets/lib/src/responsive/extensions/t_scale_extension.dart | scaledPerWidth, scaledPerHeight, scaledPerWidthAndHeight |
| LogLevelExtensions | turbolytics/lib/src/extensions/log_type_extensions.dart | tag, iconTag for log levels |
| DateTimeExtensions | turbolytics/lib/src/extensions/date_time_extensions.dart | hourMinuteSecond formatting |

### Utils / Helpers

| Name | Path | Purpose |
|---|---|---|
| TFirestoreLogger | turbo_firestore_api/lib/util/t_firestore_logger.dart | Structured logging with sensitive data redaction |
| TMutex | turbo_firestore_api/lib/util/t_mutex.dart | Mutex for thread-safe operations |
| TLog | turbolytics/lib/src/log/t_log.dart | Structured multi-level logger (trace through fatal) |
| TEventBus | turbolytics/lib/src/turbolytics/t_event_bus.dart | Chronological event processing via streams |
| ProportionalLayoutCalculator | turbo_widgets/lib/src/utils/proportional_layout_calculator.dart | Squarified treemap layout algorithm |
| TTools | turbo_widgets/lib/src/responsive/utils/t_tools.dart | Responsive scaling utilities |
| TurboWidgetsDevices | turbo_widgets/lib/src/constants/turbo_widgets_devices.dart | Device mappings for screen types |

### Factories

| Name | Path | Purpose |
|---|---|---|
| TMdFactory\<T\> | turbo_serializable/lib/markdown/factories/t_md_factory.dart | Markdown file builder (frontmatter, sections, body) |
| TYamlFactory\<T\> | turbo_serializable/lib/yaml/factories/t_yaml_factory.dart | YAML document builder |
| TXmlFactory\<T\> | turbo_serializable/lib/xml/factories/t_xml_factory.dart | XML document builder |

## Data Flow

```
External Source (Firestore, plx CLI, REST API)
    │
    ▼
API Layer (TFirestoreApi, PlxApi)
    │  Returns TurboResponse<T> (Success/Fail)
    ▼
Service Layer (TCollectionService, TDocumentService, custom services)
    │  Manages local state via TNotifier
    │  Optimistic updates before remote sync
    ▼
View Model Layer (TBaseViewModel subclasses)
    │  Composes services, manages UI state
    │  Exposes ValueListenable<T> for reactive UI
    ▼
View Layer (StatelessWidget via TViewModelBuilder)
    │  Rebuilds on view model changes via Provider/Consumer
    │  Delegates actions to view model methods
    ▼
Widget Layer (Stateless UI components with primitive parameters)
```

## Dependency Graph

```
turbo_response (no dependencies)
    ▲
    │
turbo_serializable ──► turbo_response
    ▲
    │
turbo_notifiers (flutter only)
    ▲
    │
turbolytics (flutter, get_it)
    ▲
    │
turbo_mvvm ──► flutter, provider
    │
turbo_firestore_api ──► turbo_response, turbo_serializable, turbo_notifiers, turbolytics
    │                     cloud_firestore, firebase_auth, rxdart
    │
turbo_forms ──► turbo_notifiers, turbolytics, shadcn_ui, equatable
    │
turbo_widgets ──► flutter, shadcn_ui, cached_network_image, flutter_hooks
    │
turbo_promptable ──► turbo_serializable, turbo_response, json_annotation
    │
turbo_plx_cli ──► turbo_response, json_annotation
    │
turbo_template ──► all turbo packages + Firebase + third-party
```

## Configuration

**Melos Workspace** (pubspec.yaml): Manages all packages as a Dart workspace with shared scripts for analyze, format, test, build_runner, pub-check, and pub-publish.

**Analysis Options**: Each package has its own `analysis_options.yaml`. Root workspace enforces `dart analyze --fatal-infos`.

**Publishing**: Packages are published to pub.dev via `melos run pub-publish`. `turbo_template` is excluded from publishing.

## Testing Structure

| Package | Test Location | Framework | Coverage |
|---|---|---|---|
| turbo_response | turbo_response/test/ | test | 70+ tests covering all public APIs |
| turbo_notifiers | turbo_notifiers/test/ | flutter_test, mockito | 47 tests covering TNotifier behavior |
| turbo_mvvm | turbo_mvvm/test/ | gherkin_unit_test, gherkin_integration_test | Unit + integration (BDD Gherkin style) |
| turbo_firestore_api | turbo_firestore_api/test/ | flutter_test | Service and API tests |
| turbo_plx_cli | turbo_plx_cli/test/ | test | Unit + integration tests with mock CLI |
| turbolytics | turbolytics/test/ | flutter_test | Placeholder test |
| turbo_serializable | turbo_serializable/test/ | (empty) | No tests |
| turbo_forms | (none) | (none) | No tests |
| turbo_promptable | (none) | (none) | No tests |
| turbo_widgets | turbo_widgets/test/ | flutter_test | Service tests |

**Test Execution**: `melos run test` runs tests with coverage across all packages that have a `test/` directory. Coverage output goes to `coverage/lcov.info` per package.
