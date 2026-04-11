---
name: Dummy Api And Services Mockup
description: Logic/architecture mockup for a dummy data variant of the Turbo Firestore APIs and services with a schema-aware value generator
feature: dummy-data
ability: firestore
subject: dummy-api-and-services
type: logic
status: complete
---

# Dummy Api And Services Mockup

## Phase 1: Actor Steps

### 🎯 End Goal: A consumer can swap any real `TFirestoreApi`/service for a dummy variant that produces realistic fake data derived from the entity's field types and names, with per-feature overrides supplied through the dummy's constructor.

💫 **Sequence**: `Construct a dummy api`

1. 👤 Caller creates a `TDummyFirestoreApi<T>` passing the exact same constructor arguments as the real `TFirestoreApi<T>` — no extra parameters, no wrapper, just a class-name swap
2. 👤 Caller optionally passes `fieldGenerators` (by field name), `typeGenerators` (by runtime type), `defaultCollectionSize`, `dummyDelayDuration` (default 225ms), `dummyDelayRange` (default null, `[min, max]` when set), and `randomFailurePercentage` (default 0)
3. 🧠 Dummy api constructs a probing `Map<String, dynamic>` that answers every `[]` lookup with a type-correct stand-in and records each accessed key
4. 🧠 Dummy api invokes the caller's own `fromJson` with the probing map in place of a real Firestore json payload
5. 🌐 Caller's `fromJson` executes its normal `json['field'] as Type` reads exactly as it does in production
6. 🔄 Probing map records every key accessed together with the cast target observed
7. 🔄 Probing map widens its stand-in for any failing cast and replays `fromJson` until the call completes without throwing
8. 🔄 On a field whose cast target cannot be satisfied by any candidate type, probing map marks the field unresolved and registers a visible hardcoded placeholder generator for it (`'[dummy]'`, `0`, epoch timestamp, etc.)
9. 🔄 Probing map emits a final `Map<String, Type>` schema describing every field the DTO reads, with unresolved fields flagged
10. 🧠 Dummy api merges bundled field-name defaults, unresolved-field placeholders, and caller overrides into a single `TValueGeneratorRegistry`
11. 🧠 Dummy api stores the schema, registry, config, and an empty in-memory document store

💫 **Sequence**: `Generate a single document`

12. 💫 *Event*: `getByIdWithConverter` is called with an id
13. 🧠 Dummy api waits `dummyDelayDuration`, or a uniformly random duration inside `dummyDelayRange` when set, then rolls against `randomFailurePercentage` and returns a failed `TurboResponse` if the roll trips
14. 🧠 Dummy api checks the in-memory store for the id
15. 🧠 Dummy api finds no match and asks the generator for a fresh document map
16. 🔄 Generator walks the schema field-by-field in declaration order
17. 🔄 Generator consults the caller override slot first, then the field-name registry, then the runtime-type fallback, then the unresolved-field placeholder
18. 🔄 On a field-name hit it produces a context-aware value (realistic person name, sentence, email, url, timestamp)
19. 🔄 On a miss it falls back to the type generator for that field's runtime type
20. 🔄 Generator writes the `idFieldName` with the requested id
21. 🔄 Generator returns a complete `Map<String, dynamic>`
22. 🧠 Dummy api pipes the map through the caller's `fromJson` to build a real `T`
23. 🧠 Dummy api stores the entity in its in-memory store keyed by id
24. 🧠 Dummy api returns `TurboResponse.success(entity)`

💫 **Sequence**: `Generate a collection stream`

25. 💫 *Event*: `streamAllWithConverter` is called
26. 🧠 Dummy api opens a broadcast `StreamController<List<T>>` scoped to this call
27. 🧠 Dummy api checks whether the in-memory store is empty
28. 🧠 On an empty store it asks the generator to produce `defaultCollectionSize` fresh documents using the same field-walk sequence
29. 🧠 Dummy api seeds the store with the generated entities
30. 🧠 Dummy api emits the current store snapshot through the controller once
31. 🧠 Dummy api keeps the controller registered and silent until an app-driven write mutates the store

💫 **Sequence**: `Write a document`

32. 💫 *Event*: `createDoc` is called with a `TWriteable`
33. 🧠 Dummy api generates a new id, or uses the explicit id if provided
34. 🧠 Dummy api reads the writeable through `toJson()` and parses it back through `fromJson` to get a `T`
35. 🧠 Dummy api writes the entity into the in-memory store
36. 🧠 Dummy api re-emits the updated snapshot through every open collection stream controller
37. 🧠 Dummy api returns `TurboResponse.success` with a stub `DocumentReference`

💫 **Sequence**: `Update and delete`

38. 💫 *Event*: `updateDoc` or `deleteDoc` is called
39. 🧠 Dummy api mutates or removes the entity in the in-memory store
40. 🧠 Dummy api re-emits the updated snapshot to every open collection stream
41. 🧠 Dummy api re-emits the updated entity (or null on delete) to every open document stream
42. 🧠 Dummy api returns `TurboResponse.success`

💫 **Sequence**: `Wire a service with a dummy api`

43. 👤 Caller instantiates their existing `TCollectionService` / `TDocumentService` subclass as normal
44. 👤 Caller passes a `TDummyFirestoreApi<T>` instance into the service constructor in place of the real api
45. 🧠 Service auth-sync, streams, and mutation code run unchanged
46. 🧠 Service observes dummy data flowing up through the same method signatures
47. 🌐 Real Firestore is never contacted during the run

💫 **Sequence**: `Override a generator per feature`

48. 👤 Caller constructs a dummy api with overrides supplied as either declarative value specs (`oneOf(...)`, `rangeInt(...)`, `sentence(...)`, `oneOfEnum(...)`, `pastDate(...)`) or raw generator functions, keyed by field name or runtime type
49. 🧠 Dummy api normalises every override to a common `TValueGenerator` — declarative specs are wrapped by the library, raw functions are adopted as-is
50. 🧠 Dummy api registers the normalised overrides at higher priority than field-name defaults, type fallbacks, and unresolved-field placeholders
51. 🔄 Every subsequent generation walks the override first wherever it matches
52. 📦 Resulting entities reflect the caller's domain rules (e.g. company-scoped emails, bounded ages, curated product names)

## Phase 2: Data Flow & State

```mermaid
flowchart TB
    Caller([👤 Caller])
    CollectionService[[🧠 TCollectionService&lt;T, API&gt;]]
    DocumentService[[🧠 TDocumentService&lt;T, API&gt;]]

    subgraph DummyApi["🧠 TDummyFirestoreApi&lt;T&gt; extends TFirestoreApi&lt;T&gt;"]
        Ctor[/constructor: same signature as real api + fieldGenerators, typeGenerators, defaultCollectionSize, dummyDelayDuration, dummyDelayRange, randomFailurePercentage/]
        Probe[🔄 ProbingMap&lt;String, dynamic&gt;]
        Schema[(Schema&lt;field, Type&gt;)]
        Registry[(TValueGeneratorRegistry)]
        Store[(In-memory store&lt;id, T&gt;)]
        StreamCtrls[(Open collection + doc StreamControllers)]
        Generator[🔄 Document generator]
        LatencyGate[/dummyDelayDuration or dummyDelayRange
randomFailurePercentage roll/]
    end

    subgraph Defaults["🔄 Bundled defaults"]
        NameHeuristics[field-name heuristics
name, email, description, url, etc.]
        TypeFallback[runtime-type fallback
String, int, double, bool, DateTime, Timestamp, List, Map]
        Placeholder[unresolved placeholder
'[dummy]', 0, epoch]
    end

    subgraph Overrides["🔄 Caller overrides"]
        DeclarativeSpecs[declarative specs
oneOf, rangeInt, sentence, oneOfEnum, pastDate]
        RawFunctions[raw generator functions]
    end

    %% CONSTRUCT FLOW
    Caller -->|new TDummyFirestoreApi| Ctor
    Ctor -->|invoke caller's fromJson with probing map| Probe
    Probe -.->|widen stand-ins until fromJson completes| Probe
    Probe -->|field: resolved Type| Schema
    Probe -->|field: unresolved| Placeholder
    DeclarativeSpecs -->|normalise to TValueGenerator| Registry
    RawFunctions -->|adopt as-is| Registry
    NameHeuristics --> Registry
    TypeFallback --> Registry
    Placeholder --> Registry
    Ctor --> Store
    Ctor --> StreamCtrls

    %% READ - SINGLE DOC
    Caller -->|getByIdWithConverter id| LatencyGate
    LatencyGate -->|not failed| Store
    Store -->|miss| Generator
    Schema --> Generator
    Registry --> Generator
    Generator -->|priority: override → name → type → placeholder| GenMap[[Map&lt;String, dynamic&gt;]]
    GenMap -->|caller's fromJson| Entity[[📦 T]]
    Entity --> Store
    Entity -->|TurboResponse.success| Caller
    LatencyGate -.->|failed roll| FailResponse[[TurboResponse.fail]]
    FailResponse -.-> Caller

    %% STREAM - COLLECTION
    Caller -->|streamAllWithConverter| StreamCtrls
    StreamCtrls -->|store empty?| Generator
    Generator -.->|generate defaultCollectionSize entities| Store
    Store -->|emit once| StreamCtrls
    StreamCtrls -->|Stream&lt;List&lt;T&gt;&gt;| CollectionService

    %% WRITE
    Caller -->|createDoc / updateDoc / deleteDoc writeable| LatencyGate
    LatencyGate -->|writeable.toJson → caller's fromJson| Entity
    Entity -->|write / delete| Store
    Store -->|re-emit snapshot| StreamCtrls

    %% SERVICE WIRE-UP
    CollectionService -.->|api field swapped at construction| DummyApi
    DocumentService -.->|api field swapped at construction| DummyApi
    CollectionService -->|docsPerIdNotifier| Caller
    DocumentService -->|doc notifier| Caller

    classDef dummyBox fill:#1f2937,stroke:#60a5fa,color:#e5e7eb
    classDef store fill:#064e3b,stroke:#10b981,color:#d1fae5
    classDef defaults fill:#422006,stroke:#f59e0b,color:#fef3c7
    classDef overrides fill:#4c1d95,stroke:#a78bfa,color:#ede9fe
    class DummyApi dummyBox
    class Store,Schema,Registry,StreamCtrls store
    class Defaults,NameHeuristics,TypeFallback,Placeholder defaults
    class Overrides,DeclarativeSpecs,RawFunctions overrides
```

## Phase 3: Architecture Diagrams

### Construct + trace-probe

```
┌────────────────────────────────────────────────────────────────────────────┐
│  TDummyFirestoreApi<T>(                                                    │
│      firebaseFirestore,   // accepted, ignored                             │
│      collectionPath,                                                       │
│      fromJson,            // reused for probing AND for building T         │
│      toJson,                                                               │
│      ...,                                                                  │
│      fieldGenerators,                                                      │
│      typeGenerators,                                                       │
│      defaultCollectionSize: 20,                                            │
│      dummyDelayDuration:   Duration(milliseconds: 225),                    │
│      dummyDelayRange:      null,                                           │
│      randomFailurePercentage: 0,                                           │
│  )                                                                         │
└───────────────────────────────┬────────────────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                       _TracingMap (probing pass)                           │
│                                                                            │
│   candidates: [String, int, double, num, bool, DateTime, Timestamp,        │
│                List, Map, GeoPoint, DocumentReference, Blob, null]         │
│                                                                            │
│   [] lookup for 'name'  ──▶  returns '' (String)                           │
│   [] lookup for 'age'   ──▶  returns ''          ──╳ caller cast as int    │
│                          ──▶  widen 'age' to 0  (int)                      │
│                          ──▶  replay fromJson(map)                         │
│   [] lookup for 'tags'  ──▶  returns ''          ──╳ caller cast as List   │
│                          ──▶  widen 'tags' to []                           │
│                          ──▶  replay fromJson(map)                         │
│   ...                                                                      │
│   candidate list exhausted for 'customThing':                              │
│                          ──▶  mark field unresolved                        │
│                          ──▶  placeholder generator registered             │
│                                                                            │
│   final Schema<field, Type>:                                               │
│       { name: String, age: int, tags: List,                                │
│         customThing: <unresolved> }                                        │
└───────────────────────────────┬────────────────────────────────────────────┘
                                │
                                ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                       TValueGeneratorRegistry                              │
│                                                                            │
│  priority walk for each field:                                             │
│                                                                            │
│    1. caller override                                                      │
│          fieldGenerators[name] ▶ typeGenerators[runtimeType]               │
│                                                                            │
│    2. bundled field-name heuristics                                        │
│          name, email, description, url, avatarUrl, firstName,              │
│          lastName, title, phoneNumber, createdAt, updatedAt, ...           │
│                                                                            │
│    3. runtime-type fallback                                                │
│          String→word  int→0..1000  double→0..1000  bool→random             │
│          DateTime→recentPast  List→3..5 items  Map→2..3 entries            │
│                                                                            │
│    4. unresolved placeholder                                               │
│          '[dummy]'  0  epoch  false  []  {}                                │
└────────────────────────────────────────────────────────────────────────────┘
```

### Read, stream, write pipeline

```
                        ┌───────────────────────────┐
   getByIdWithConverter │   LatencyGate             │
   getById              │                           │
   listAll*             │   dummyDelayDuration OR   │
   listByQuery*         │   uniform(dummyDelayRange)│
   streamAll*           │   then roll               │
   streamByQuery*       │   randomFailurePercentage │
   createDoc            │                           │
   updateDoc            └─────────┬─────────────────┘
   deleteDoc                      │
                            ┌─────┴──────┐
                            │            │
                       fail roll?      pass
                            │            │
                            ▼            ▼
                    ┌───────────┐   ┌─────────────────────────────────┐
                    │ Turbo     │   │ branch on method type           │
                    │ Response  │   └─┬─────────────┬─────────────────┘
                    │ .fail     │     │             │
                    └───────────┘     │             │
                                      ▼             ▼
                              ┌───────────┐  ┌──────────────┐
                              │   READ    │  │    WRITE     │
                              └─────┬─────┘  └──────┬───────┘
                                    │               │
                        store hit?  │               │ writeable.toJson()
                        yes ◀───────┤               │        │
                                    │ no            │        ▼
                                    ▼               │ caller fromJson()
                          ┌─────────────────┐       │        │
                          │ Generator walk  │       │        ▼
                          │ (Schema +       │       │ store[id] = T
                          │  Registry)      │       │        │
                          └───────┬─────────┘       │        ▼
                                  │                 │ for each open
                                  ▼                 │ StreamController
                         Map<String, dynamic>       │        │
                                  │                 │        ▼
                                  ▼                 │  emit new snapshot
                          caller fromJson()         │
                                  │                 │
                                  ▼                 │
                             store[id] = T          │
                                  │                 │
                                  ▼                 │
                         TurboResponse.success      │
                                  │                 │
                                  ▼                 ▼
                               Caller           Caller
```

### Collection stream lifecycle

```
 screen A opens streamAllWithConverter
        │
        ▼
 ┌──────────────────────────────────────────┐
 │ broadcast StreamController<List<T>> A    │
 │   registered in StreamCtrls              │
 └──────────┬───────────────────────────────┘
            │
            ▼
   store empty ?
            │
      yes ──┴── no
       │         │
       ▼         │
  generate N     │
  (Schema +      │
   Registry)     │
       │         │
       ▼         │
  seed store     │
       │         │
       └────┬────┘
            ▼
  emit store snapshot  ──▶ screen A
            │
            ▼
 (silent until a write mutates the store)

 --- later ---

 screen B opens streamAllWithConverter
        │
        ▼
 ┌──────────────────────────────────────────┐
 │ broadcast StreamController<List<T>> B    │
 │   registered in StreamCtrls              │
 └──────────┬───────────────────────────────┘
            │
            ▼
   store empty ?  ── no (populated by A) ──┐
                                           │
            ▼                               │
  emit store snapshot  ◀────────────────────┘
            │
            ▼
        screen B  (sees exactly the same entities as A)

 --- write happens ---

  createDoc(writeable)
            │
            ▼
  store[newId] = T
            │
            ▼
  for ctrl in StreamCtrls:
    ctrl.add( store.values.toList() )
            │
            ▼
    screen A  ◀── new snapshot
    screen B  ◀── new snapshot
```

### Service wire-up (real vs dummy)

```
 ─── REAL ──────────────────────────────────────────────────────────────────

                                         ┌──────────────────────┐
                                         │  FirebaseFirestore   │
                                         └──────────┬───────────┘
                                                    │
                                                    ▼
 ┌─────────────────────┐        api       ┌──────────────────────┐
 │  UserService        │─────────────────▶│  TFirestoreApi<User> │
 │  extends            │                  │                      │
 │  TCollectionService │                  │   collection, docs,  │
 │  <User, UserApi>    │                  │   streams, mutations │
 └──────────┬──────────┘                  └──────────────────────┘
            │
            ▼
       UI / ViewModel

 ─── DUMMY ─────────────────────────────────────────────────────────────────

                                             (no Firestore contact)

 ┌─────────────────────┐        api       ┌───────────────────────────┐
 │  UserService        │─────────────────▶│  TDummyFirestoreApi<User> │
 │  extends            │                  │                           │
 │  TCollectionService │                  │   Schema, Registry,       │
 │  <User, UserApi>    │                  │   Store, StreamCtrls,     │
 │                     │                  │   LatencyGate             │
 │   UNCHANGED code    │                  └───────────────────────────┘
 └──────────┬──────────┘
            │
            ▼
       UI / ViewModel
        (blind to which api variant is wired)
```

### Prerequisite: extensions → virtual instance methods

```
 ─── CURRENT SHAPE (blocks subclass overrides) ─────────────────────────────

 ┌────────────────────────────────────────────────────────────────┐
 │  class TFirestoreApi<T> {                                      │
 │    // constructor + private state                              │
 │  }                                                             │
 │                                                                │
 │  extension TFirestoreCreateApi<T> on TFirestoreApi {           │
 │    Future<TurboResponse<DocumentReference>> createDoc({...})   │
 │  }                                                             │
 │  extension TFirestoreUpdateApi<T> on TFirestoreApi { ... }     │
 │  extension TFirestoreDeleteApi<T> on TFirestoreApi { ... }     │
 │  extension TFirestoreGetApi<T>    on TFirestoreApi { ... }     │
 │  extension TFirestoreListApi<T>   on TFirestoreApi { ... }     │
 │  extension TFirestoreSearchApi<T> on TFirestoreApi { ... }     │
 │  extension TFirestoreStreamApi<T> on TFirestoreApi { ... }     │
 └────────────────────────────────────────────────────────────────┘
                               │
                               │  Dart rule:
                               │  extension methods are resolved
                               │  statically by receiver type, not
                               │  by the runtime class of `this`.
                               │  A subclass CANNOT override them.
                               ▼
 ┌────────────────────────────────────────────────────────────────┐
 │  class TDummyFirestoreApi<T> extends TFirestoreApi<T> {        │
 │    @override                                                   │
 │    Future<TurboResponse<DocumentReference>> createDoc({...})   │
 │      // ╳ compile error: nothing to override                   │
 │  }                                                             │
 └────────────────────────────────────────────────────────────────┘

 ─── REQUIRED SHAPE (unlocks subclass overrides) ───────────────────────────

 ┌────────────────────────────────────────────────────────────────┐
 │  class TFirestoreApi<T> {                                      │
 │    // constructor + private state                              │
 │                                                                │
 │    Future<TurboResponse<DocumentReference>> createDoc({...})   │
 │    Future<TurboResponse<DocumentReference>> updateDoc({...})   │
 │    Future<TurboResponse<void>>              deleteDoc({...})   │
 │    Future<TurboResponse<T>>  getByIdWithConverter({...})       │
 │    Future<TurboResponse<List<T>>> listAllWithConverter()       │
 │    Future<TurboResponse<List<T>>> listByQueryWithConverter({}) │
 │    Stream<List<T>> streamAllWithConverter()                    │
 │    Stream<List<T>> streamByQueryWithConverter({...})           │
 │    Stream<T?>      streamDocByIdWithConverter({...})           │
 │    // ... all former extension methods promoted to             │
 │    //     virtual instance methods on the class                │
 │  }                                                             │
 └────────────────────────────────────────────────────────────────┘
                               │
                               │  now dispatch is virtual on the
                               │  runtime class of `this`
                               ▼
 ┌────────────────────────────────────────────────────────────────┐
 │  class TDummyFirestoreApi<T> extends TFirestoreApi<T> {        │
 │    @override                                                   │
 │    Future<TurboResponse<DocumentReference>> createDoc({...})   │
 │      // ✓ intercepts without touching Firestore                │
 │    @override                                                   │
 │    Stream<List<T>> streamAllWithConverter()                    │
 │      // ✓ emits from the in-memory store                       │
 │    // ... every other method overridden the same way           │
 │  }                                                             │
 └────────────────────────────────────────────────────────────────┘

 Impact on callers of the real api:
   • zero API surface change
   • zero call-site change
   • the file split (t_firestore_*.dart part files) can stay as-is
     as long as the methods move from `extension` to instance level
```

## Phase 4: Service & Entity Construction

Feature: DummyFirestoreApi

### Prerequisite refactor (ships first, blocks everything else)

```
Refactor: TFirestoreApi extensions → virtual instance methods
├── lib/apis/t_firestore_api.dart
│   ├── keep: constructor, private fields, helpers, turboVars, writeBatch,
│   │         collection, doc, genId, docExists, _handleBatchOperation,
│   │         _extractDocumentData
│   └── absorb methods from part files as virtual instance methods on
│       class TFirestoreApi<T>
├── lib/apis/t_firestore_create_api.dart  (part of)
│   └── createDoc, createDocInBatch, createDocInTransaction   (extension → class body)
├── lib/apis/t_firestore_update_api.dart  (part of)
│   └── updateDoc, updateDocInBatch, updateDocInTransaction
├── lib/apis/t_firestore_delete_api.dart  (part of)
│   └── deleteDoc, deleteDocInBatch, deleteDocInTransaction
├── lib/apis/t_firestore_get_api.dart     (part of)
│   └── getById, getByIdWithConverter, getDocRefById,
│       getDocRefByIdWithConverter, getDocSnapshotById,
│       getDocSnapshotByIdWithConverter
├── lib/apis/t_firestore_list_api.dart    (part of)
│   └── listByQuery, listByQueryWithConverter, listAll, listAllWithConverter
├── lib/apis/t_firestore_search_api.dart  (part of)
│   └── listBySearchTerm, listBySearchTermWithConverter
└── lib/apis/t_firestore_stream_api.dart  (part of)
    └── streamAll, streamAllWithConverter, streamByQuery,
        streamByQueryWithConverter, streamByDocId, streamDocByIdWithConverter
```

### TDummyFirestoreApi

```
lib/apis/t_dummy_firestore_api.dart
└── class TDummyFirestoreApi<T> extends TFirestoreApi<T>
    ├── constructor TDummyFirestoreApi
    │   ├── super: firebaseFirestore, collectionPath, toJson, fromJson,
    │   │          fromJsonError, tryAddLocalId, logger,
    │   │          createdAtFieldName, updatedAtFieldName, idFieldName,
    │   │          documentReferenceFieldName, isCollectionGroup,
    │   │          tryAddLocalDocumentReference, getOptions
    │   └── dummy-only
    │       ├── Map<String, TValueGenerator>? fieldGenerators
    │       ├── Map<Type,   TValueGenerator>? typeGenerators
    │       ├── int defaultCollectionSize            = 20
    │       ├── Duration dummyDelayDuration          = Duration(milliseconds: 225)
    │       ├── List<Duration>? dummyDelayRange      = null
    │       └── double randomFailurePercentage       = 0
    ├── private state
    │   ├── final TDummySchema _schema
    │   ├── final TValueGeneratorRegistry _registry
    │   ├── final Map<String, T> _store             = {}
    │   ├── final Set<StreamController<List<T>>> _collectionControllers = {}
    │   ├── final Map<String, Set<StreamController<T?>>> _docControllers = {}
    │   └── final Random _rng
    ├── init
    │   ├── _schema   ← _TDummyProbingMap.probe<T>(fromJson)
    │   └── _registry ← TValueGeneratorRegistry.build(
    │                       fieldGenerators: fieldGenerators,
    │                       typeGenerators:  typeGenerators,
    │                       schema:          _schema,
    │                   )
    ├── internal helpers
    │   ├── Future<void> _applyLatency()
    │   │     waits dummyDelayDuration OR uniform(dummyDelayRange)
    │   ├── bool _rollFailure()
    │   │     rng.nextDouble() * 100 < randomFailurePercentage
    │   ├── T _generateEntity({required String id})
    │   │     walk _schema → _registry → Map<String,dynamic> → fromJson
    │   ├── void _writeToStore(T entity, String id)
    │   ├── void _emitCollections()
    │   │     snapshot ← _store.values.toList();
    │   │     for ctrl in _collectionControllers: ctrl.add(snapshot)
    │   └── void _emitDoc(String id, T? entity)
    │         for ctrl in _docControllers[id] ?? {}: ctrl.add(entity)
    ├── overridden reads
    │   ├── @override Future<TurboResponse<T>> getByIdWithConverter({
    │   │       required String id,
    │   │       String? collectionPathOverride,
    │   │       Transaction? transaction,
    │   │   })
    │   │     → await _applyLatency()
    │   │     → if _rollFailure() return TurboResponse.fail(...)
    │   │     → return _store[id] ?? _generateEntity(id: id) → success
    │   ├── @override Future<TurboResponse<Map<String,dynamic>>> getById({...})
    │   ├── @override Future<TurboResponse<List<T>>> listAllWithConverter()
    │   │     → await _applyLatency()
    │   │     → if _store.isEmpty: seed defaultCollectionSize entities
    │   │     → return TurboResponse.success(_store.values.toList())
    │   ├── @override Future<TurboResponse<List<T>>> listByQueryWithConverter({...})
    │   │     ignores query, behaves like listAllWithConverter
    │   ├── @override Future<TurboResponse<List<T>>> listBySearchTermWithConverter({...})
    │   └── @override Future<bool> docExists({required String id, ...})
    ├── overridden streams
    │   ├── @override Stream<List<T>> streamAllWithConverter()
    │   │     → StreamController<List<T>>.broadcast registered in _collectionControllers
    │   │     → if _store.isEmpty: seed defaultCollectionSize entities
    │   │     → controller.add(snapshot) once after _applyLatency()
    │   │     → onCancel: unregister controller
    │   ├── @override Stream<List<T>> streamByQueryWithConverter({...})
    │   │     ignores query, behaves like streamAllWithConverter
    │   └── @override Stream<T?> streamDocByIdWithConverter({required String id, ...})
    │         → controller registered in _docControllers[id]
    │         → emit _store[id] ?? _generateEntity(id: id) once
    ├── overridden writes
    │   ├── @override Future<TurboResponse<DocumentReference>> createDoc({
    │   │       required TWriteable writeable,
    │   │       String? id,
    │   │       WriteBatch? writeBatch,
    │   │       TTimestampType createTimeStampType = TTimestampType.createdAtAndUpdatedAt,
    │   │       TTimestampType updateTimeStampType = TTimestampType.updatedAt,
    │   │       bool merge = false,
    │   │       List<FieldPath>? mergeFields,
    │   │       String? collectionPathOverride,
    │   │       Transaction? transaction,
    │   │   })
    │   │     → await _applyLatency()
    │   │     → if _rollFailure() return TurboResponse.fail(...)
    │   │     → validate via writeable.validate()
    │   │     → entity ← fromJson(writeable.toJson())
    │   │     → _writeToStore(entity, id ?? _genDummyId())
    │   │     → _emitCollections()
    │   │     → _emitDoc(id, entity)
    │   │     → return TurboResponse.success(_TDummyDocumentReference(id))
    │   ├── @override Future<TurboResponse<DocumentReference>> updateDoc({...})
    │   └── @override Future<TurboResponse<void>> deleteDoc({
    │           required String id,
    │           WriteBatch? writeBatch,
    │           String? collectionPathOverride,
    │           Transaction? transaction,
    │       })
    │         → _store.remove(id); _emitCollections(); _emitDoc(id, null)
    └── @override dispose
        ├── close every controller in _collectionControllers
        ├── close every controller in _docControllers values
        └── super.dispose()
```

### _TDummyProbingMap (schema discovery)

```
lib/apis/_t_dummy_probing_map.dart   (library-private, part of t_dummy_firestore_api.dart)
└── class _TDummyProbingMap implements Map<String, dynamic>
    ├── static TDummySchema probe<T>(
    │       T Function(Map<String, dynamic> json) fromJson,
    │   )
    │     ├── probing ← _TDummyProbingMap()
    │     ├── attempts ← 0; maxAttempts ← probing.candidateCount × maxFields
    │     ├── loop:
    │     │    try { fromJson(probing); break; }
    │     │    catch (_) {
    │     │       probing.widenLastAccessedKey();
    │     │       attempts++;
    │     │       if attempts >= maxAttempts: mark remaining keys unresolved; break;
    │     │    }
    │     └── return probing.buildSchema()
    ├── state
    │   ├── Map<String, Type> _resolved   = {}
    │   ├── Map<String, _CandidateCursor> _cursors = {}
    │   ├── Set<String> _unresolved       = {}
    │   └── String? _lastKey
    ├── candidate order
    │   └── [String, int, double, num, bool, DateTime, Timestamp, List,
    │        Map, GeoPoint, DocumentReference, Blob, null]
    ├── overrides
    │   ├── @override dynamic operator [](Object? key)
    │   │     → _lastKey ← key as String
    │   │     → advance cursor if needed
    │   │     → return stand-in value for current candidate type
    │   ├── @override bool containsKey(Object? key) → true
    │   ├── @override Iterable<String> get keys     → _resolved.keys
    │   ├── @override int get length                → _resolved.length
    │   └── @override ... (remaining Map members delegate to empty defaults)
    ├── void widenLastAccessedKey()
    │     → advance _cursors[_lastKey] to next candidate type
    │     → if exhausted: add _lastKey to _unresolved
    └── TDummySchema buildSchema()
          → TDummySchema(fields: _resolved, unresolved: _unresolved)
```

### TValueGeneratorRegistry + TValueGenerator

```
lib/generators/t_value_generator.dart
└── typedef TValueGenerator = dynamic Function()

lib/generators/t_dummy_schema.dart
└── class TDummySchema
    ├── final Map<String, Type> fields
    └── final Set<String> unresolved

lib/generators/t_value_generator_registry.dart
└── class TValueGeneratorRegistry
    ├── factory TValueGeneratorRegistry.build({
    │       Map<String, TValueGenerator>? fieldGenerators,
    │       Map<Type,   TValueGenerator>? typeGenerators,
    │       required TDummySchema schema,
    │   })
    │     ├── merge fieldGenerators over _bundledFieldHeuristics
    │     ├── merge typeGenerators  over _bundledTypeFallbacks
    │     ├── register _placeholderGenerator for every schema.unresolved
    │     └── return TValueGeneratorRegistry(...)
    ├── private maps
    │   ├── Map<String, TValueGenerator> _fieldGenerators
    │   ├── Map<Type,   TValueGenerator> _typeGenerators
    │   └── Map<String, TValueGenerator> _placeholders
    ├── dynamic generate({required String field, required Type type})
    │     priority walk:
    │       1. _fieldGenerators[field]               (override or heuristic)
    │       2. _fieldGenerators.matchSubstring(field) (heuristic fallback)
    │       3. _typeGenerators[type]                  (override or fallback)
    │       4. _placeholders[field]                   (unresolved visible stub)
    └── static Map<String, TValueGenerator> _bundledFieldHeuristics = {
          'id': uuid, 'uid': uuid, 'userId': uuid, 'ownerId': uuid,
          'name': lorem.name, 'firstName': lorem.firstName,
          'lastName': lorem.lastName, 'fullName': lorem.name,
          'displayName': lorem.name, 'username': lorem.username,
          'email': lorem.email, 'phone': lorem.phoneNumber,
          'phoneNumber': lorem.phoneNumber,
          'description': lorem.sentence, 'title': lorem.words,
          'summary': lorem.sentence, 'content': lorem.paragraph,
          'body': lorem.paragraph,
          'url': lorem.url, 'avatarUrl': lorem.imageUrl,
          'imageUrl': lorem.imageUrl, 'thumbnailUrl': lorem.imageUrl,
          'address': lorem.address, 'street': lorem.street,
          'city': lorem.city, 'country': lorem.country,
          'zip': lorem.postalCode, 'postalCode': lorem.postalCode,
          'createdAt': () => DateTime.now().subtract(...),
          'updatedAt': () => DateTime.now(),
          'deletedAt': () => null,
          'timestamp': () => DateTime.now(),
          'age': () => rng.nextInt(80),
          'count': () => rng.nextInt(1000),
          'quantity': () => rng.nextInt(100),
          'price': () => rng.nextDouble() * 1000,
          'amount': () => rng.nextDouble() * 1000,
          'rating': () => rng.nextDouble() * 5,
          'score': () => rng.nextInt(100),
          'isActive': () => rng.nextBool(),
          'isDeleted': () => false,
          'enabled': () => rng.nextBool(),
        }
```

### Declarative value spec factories

```
lib/generators/t_value_specs.dart
├── TValueGenerator oneOf<V>(List<V> values)
├── TValueGenerator oneOfEnum<E extends Enum>(List<E> values)
├── TValueGenerator rangeInt(int min, int max)
├── TValueGenerator rangeDouble(double min, double max)
├── TValueGenerator sentence({int wordCount = 8})
├── TValueGenerator words({int min = 1, int max = 3})
├── TValueGenerator paragraph({int sentences = 3})
├── TValueGenerator pastDate({Duration within = const Duration(days: 365)})
├── TValueGenerator futureDate({Duration within = const Duration(days: 365)})
├── TValueGenerator uuid()
└── TValueGenerator fixed<V>(V value)
```

### Service wire-up (unchanged existing services)

```
lib/services/t_collection_service.dart  (unchanged)
└── abstract class TCollectionService<T extends TWriteableId, API extends TFirestoreApi<T>>
    └── final API api                    ← satisfied by TDummyFirestoreApi<T>

lib/services/t_document_service.dart  (unchanged)
└── abstract class TDocumentService<T extends TWriteableId, API extends TFirestoreApi<T>>
    └── final API api                    ← satisfied by TDummyFirestoreApi<T>

Caller wire-up in a feature:
  registerLazySingleton<UserApi>(
    () => isDummyMode
        ? TDummyFirestoreApi<User>(
              firebaseFirestore: firestore,
              collectionPath:    () => 'users',
              fromJson:          User.fromJson,
              toJson:            (u) => u.toJson(),
              tryAddLocalId:     true,
              fieldGenerators: {
                'email': oneOf(['a@acme.com', 'b@acme.com']),
                'age':   rangeInt(18, 80),
              },
            )
        : TFirestoreApi<User>(
              firebaseFirestore: firestore,
              collectionPath:    () => 'users',
              fromJson:          User.fromJson,
              toJson:            (u) => u.toJson(),
              tryAddLocalId:     true,
            ),
  )
```

### Public export surface

```
turbo_firestore_api.dart  (public exports)
├── existing
│   └── apis/t_firestore_api.dart
├── new
│   ├── apis/t_dummy_firestore_api.dart
│   ├── generators/t_value_generator.dart
│   ├── generators/t_dummy_schema.dart
│   ├── generators/t_value_generator_registry.dart
│   └── generators/t_value_specs.dart
└── private (not exported)
    └── apis/_t_dummy_probing_map.dart
```

