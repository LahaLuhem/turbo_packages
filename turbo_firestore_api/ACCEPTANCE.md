# Acceptance Test: TDummyFirestoreApi Feature

## Overview
Verifies the complete TDummyFirestoreApi feature (Tasks 9–13 + review fixes): an in-memory drop-in replacement for TFirestoreApi that serves deterministic fake data without contacting Firestore. Covers schema probing, value generation, CRUD operations, stream fan-out, batch/transaction atomicity, DocumentReference stubs, query filter/sort, search fallback, service-level composition, and public barrel exports.

Environment: Local test suite (pure Dart/Flutter library — no running application).

---

## Steps

### 1. Static Analysis Gate

What's New: All new/modified files must pass strict analysis with zero issues.

- [x] Run `dart analyze --fatal-infos` from the package root
  - [x] Exit code is 0
  - [x] Output contains "No issues found!"
  - If failing: Copy the full analyzer output including file paths and issue descriptions.
  - Result: Pass
  - Feedback: "Analyzing turbo_firestore_api... No issues found!"

### 2. Formatting Gate

What's New: All code conforms to `dart format` with zero changes needed.

- [x] Run `dart format --set-exit-if-changed .` from the package root
  - [x] Exit code is 0
  - [x] Output shows "0 changed"
  - If failing: List the files that require formatting changes.
  - Result: Pass
  - Feedback: "Formatted 66 files (0 changed) in 0.17 seconds."

### 3. Full Test Suite Pass

What's New: All 108 tests (existing + new) pass with zero failures.

- [x] Run `flutter test --no-pub` from the package root
  - [x] Exit code is 0
  - [x] Output ends with "All tests passed!"
  - [x] Total test count is >= 108
  - If failing: Copy the failure messages including test names, expected vs actual values, and stack traces.
  - Result: Pass
  - Feedback: "00:02 +108: All tests passed!" — exactly 108 tests.

### 4. Schema Probing and Value Generation (skeleton tests)

What's New: TDummyFirestoreApi probes a DTO's fromJson to discover field types, then generates deterministic fake values via TValueGeneratorRegistry.

- [x] Run `flutter test --no-pub test/apis/t_dummy_firestore_api_skeleton_test.dart`
  - [x] All 6 tests pass
  - [x] Probed schema matches standalone probe result
  - [x] Same-seed instances produce identical id sequences
  - [x] Latency simulation runs within expected bounds (45–75ms for 50ms config)
  - [x] 0% failure rate produces zero exceptions across 100 rolls
  - [x] 100% failure rate produces exceptions on every roll with multiple subtypes
  - [x] dispose() closes all registered controllers
  - If failing: Copy the specific test failure with expected/actual values.
  - Result: Pass
  - Feedback: 6/6 passed. All skeleton behaviors verified.

### 5. Read Operations (reads tests)

What's New: getById, getByIdWithConverter, listAll, listAllWithConverter, docExists — all served from an in-memory store with latency simulation and failure gating.

- [x] Run `flutter test --no-pub test/apis/t_dummy_firestore_api_reads_test.dart`
  - [x] All 12 tests pass
  - [x] Same-id reads return identical entities (deterministic)
  - [x] Returned maps are defensive copies (mutation-safe)
  - [x] defaultCollectionSize controls seeded collection size
  - [x] Same-seed instances produce identical entity lists
  - [x] docExists returns false before seeding, true after
  - [x] Latency simulation applies to read operations
  - [x] 100% failure rate produces TurboResponse.fail on all read methods
  - [x] Seeded createdAt timestamps spread across distinct days
  - [x] Query filter seam returns a new list instance
  - [x] Query closure is never invoked (dummy ignores real Firestore queries)
  - [x] defaultCollectionSize=0 returns empty list
  - If failing: Copy the specific test failure with expected/actual values.
  - Result: Pass
  - Feedback: 12/12 passed. All read behaviors verified.

### 6. Stream Operations (streams tests)

What's New: streamAllWithConverter, streamDocByIdWithConverter, streamByQueryWithConverter — broadcast streams from the in-memory store with fan-out on mutations.

- [x] Run `flutter test --no-pub test/apis/t_dummy_firestore_api_streams_test.dart`
  - [x] All 11 tests pass
  - [x] streamAllWithConverter is broadcast and emits defaultCollectionSize entities
  - [x] Two subscribers on the same stream receive identical snapshots
  - [x] Cancelled subscription removes the controller (cleanup)
  - [x] streamDocByIdWithConverter emits a non-null materialized entity
  - [x] 100% failure rate emits an error event on the stream
  - [x] Manual emitCollections triggers re-emission reflecting store mutations
  - [x] Manual emitDoc(id, null) delivers null to the doc subscriber
  - [x] streamByQueryWithConverter ignores the query closure
  - [x] streamByQuery (raw) emits raw map lists
  - [x] streamAll() (raw QuerySnapshot) throws UnimplementedError
  - [x] streamByDocId() (raw DocumentSnapshot) throws UnimplementedError
  - If failing: Copy the specific test failure with expected/actual values.
  - Result: Pass
  - Feedback: 11/11 passed. All stream behaviors verified.

### 7. Write Operations (writes tests)

What's New: createDoc, updateDoc, deleteDoc — mutate the in-memory store with timestamp injection, validation gating, failure simulation, and stream fan-out.

- [x] Run `flutter test --no-pub test/apis/t_dummy_firestore_api_writes_test.dart`
  - [x] All 9 tests pass
  - [x] createDoc stores fields + timestamps + id, returns DocumentReference, triggers stream
  - [x] updateDoc shallow-merges, preserves createdAt, advances updatedAt
  - [x] updateDoc on unknown id returns TurboFirestoreNotFoundException
  - [x] deleteDoc removes from store, doc stream emits null
  - [x] Two concurrent collection streams stay in sync after create
  - [x] 100% failure rate prevents mutation on create, update, delete
  - [x] Validation failure prevents store mutation
  - [x] Auto-generated deterministic dummy id works without explicit id
  - If failing: Copy the specific test failure with expected/actual values.
  - Result: Pass
  - Feedback: 9/9 passed. All write behaviors verified.

### 8. Batch and Transaction Operations (batch tests)

What's New: WriteBatch queues mutations and applies atomically on commit(); runTransaction executes inline with rollback on failure; both emit exactly one snapshot.

- [x] Run `flutter test --no-pub test/apis/t_dummy_firestore_api_batch_test.dart`
  - [x] 9 of 9 tests pass (test file contains 9, not 10)
  - [x] Batch 3-create: single emission containing all 3 entities
  - [x] Mixed batch (create + update + delete): correct final state + single emission
  - [x] Transaction update + return value passthrough
  - [x] Transaction single emission for multiple mutations
  - [x] Double-commit throws StateError with "dummy-mode"
  - [x] Transaction return value unchanged
  - [x] Batch atomicity: failing second operation rolls back first
  - [x] Transaction atomicity: handler throw rolls back store
  - [x] Transaction get reads stored data
  - If failing: Copy the specific test failure with expected/actual values.
  - Result: Pass
  - Feedback: 9/9 passed (the "10 tests" estimate was off by 1 — the "Transaction return value unchanged" and "Transaction update + return value passthrough" overlap). All batch/transaction behaviors verified including atomicity rollback.

### 9. DocumentReference Stubs (doc ref tests)

What's New: _TDummyDocumentReference delegates .get(), .update(), .delete(), .snapshots() back to the API's in-memory store. getDocRefById and getDocRefByIdWithConverter return lazy references.

- [x] Run `flutter test --no-pub test/apis/t_dummy_firestore_api_doc_ref_test.dart`
  - [x] All 8 tests pass
  - [x] createDoc ref .id and .path match expected values
  - [x] .get() returns snapshot with created data
  - [x] .update() mutates store, subsequent .get() reflects change
  - [x] .delete() then .get() yields exists=false
  - [x] .snapshots() emits initial + exists=false after delete
  - [x] .collection('children') throws UnimplementedError with "dummy-mode"
  - [x] getDocRefById is lazy (no store mutation)
  - [x] getDocRefByIdWithConverter returns typed snapshot data
  - If failing: Copy the specific test failure with expected/actual values.
  - Result: Pass
  - Feedback: 8/8 passed. All DocumentReference stub behaviors verified.

### 10. Query Filter, Sort, and Search (query tests)

What's New: _applyQueryFilterAndSort applies registered predicates and comparators. Search methods fall back to substring matching on a configurable field.

- [x] Run `flutter test --no-pub test/apis/t_dummy_firestore_api_query_test.dart`
  - [x] All 7 tests pass
  - [x] Filter-only returns matching entities
  - [x] Filter + sort returns matching entities in ascending createdAt
  - [x] Unknown key returns full store unchanged
  - [x] Stream re-emission includes new matching entity in correct sorted position
  - [x] Stream re-emission excludes non-matching entity
  - [x] Substring search fallback matches case-insensitively
  - [x] Missing-field DTO returns 0 results (filtered out gracefully)
  - If failing: Copy the specific test failure with expected/actual values.
  - Result: Pass
  - Feedback: 7/7 passed. All query filter/sort/search behaviors verified.

### 11. Service-Level Smoke Test (service smoke tests)

What's New: Real TCollectionService subclass composes with TDummyFirestoreApi end-to-end: seed → stream → create → update → delete → stream re-emission. docsPerIdNotifier reflects mutations without manual hydration.

- [x] Run `flutter test --no-pub test/apis/t_dummy_firestore_api_service_smoke_test.dart`
  - [x] All 2 tests pass
  - [x] Stream-based test: seed(3) → create → stream +1 → update → stream reflects name change → delete → stream -1
  - [x] Notifier-based test: create → docsPerId has entry → update → name reflected → delete → docsPerId empty; hasDocs, exists(), findById(), tryFindById() all correct at each step
  - If failing: Copy the specific test failure with expected/actual values.
  - Result: Pass
  - Feedback: 2/2 passed. Expected warning logs from TurboAuthSyncService dispose — harmless, confirms service lifecycle.

### 12. Value Generator Specs (specs tests)

What's New: TValueSpecs factories (oneOf, rangeInt, rangeDouble, sentence, words, paragraph, pastDate, futureDate, uuid, fixed) with validation and determinism.

- [x] Run `flutter test --no-pub test/generators/t_value_specs_test.dart`
  - [x] All 24 tests pass
  - [x] oneOf picks from pool, throws on empty
  - [x] rangeInt/rangeDouble produce values in range, throw on invalid bounds
  - [x] sentence/words/paragraph produce correct word counts
  - [x] pastDate/futureDate stay within configured duration window
  - [x] uuid produces sequential zero-padded ids with independent counters
  - [x] fixed always returns the exact value
  - [x] Same-seed factory chains produce identical output sequences
  - If failing: Copy the specific test failure with expected/actual values.
  - Result: Pass
  - Feedback: 24/24 passed. All value generator spec behaviors verified.

### 13. Schema Model (schema tests)

What's New: TDummySchema sealed hierarchy (TDummySchemaLeaf, TDummySchemaBranch) with exhaustive switch support.

- [x] Run `flutter test --no-pub test/generators/t_dummy_schema_test.dart`
  - [x] All 3 tests pass
  - [x] Flat schema with two leaf fields reports expected types
  - [x] Branch field destructures to accessible nested schema
  - [x] Exhaustive switch expression handles both variants with no default branch
  - If failing: Copy the specific test failure with expected/actual values.
  - Result: Pass
  - Feedback: 3/3 passed. Sealed hierarchy verified.

### 14. Public Barrel Exports

What's New: 5 new exports added to lib/turbo_firestore_api.dart for downstream consumption.

- [x] Verify `lib/turbo_firestore_api.dart` contains export lines for all 5 new public files:
  - [x] `apis/t_dummy_firestore_api.dart`
  - [x] `generators/t_dummy_schema.dart`
  - [x] `generators/t_value_generator.dart`
  - [x] `generators/t_value_generator_registry.dart`
  - [x] `generators/t_value_specs.dart`
  - If failing: List which exports are missing.
  - Result: Pass
  - Feedback: All 5 export lines present in barrel file.

- [x] Verify `_t_dummy_probing_map.dart` is NOT exported (it is a `part` file)
  - [x] No export line referencing `_t_dummy_probing_map.dart` exists in the barrel
  - If failing: Copy the offending export line.
  - Result: Pass
  - Feedback: Zero export lines reference _t_dummy_probing_map.dart. Correctly excluded as a part file.

### 15. CHANGELOG Entry

What's New: Unreleased section documents the TDummyFirestoreApi feature.

- [x] Verify CHANGELOG.md contains an `[Unreleased]` section at the top
  - [x] The entry mentions `TDummyFirestoreApi`
  - [x] The entry describes it as a drop-in replacement for `TFirestoreApi`
  - If failing: Copy the actual CHANGELOG.md header section.
  - Result: Pass
  - Feedback: `## [Unreleased]` section present. Entry reads: "Added `TDummyFirestoreApi<T>` — a drop-in replacement for `TFirestoreApi<T>` that serves realistic, deterministic fake data from an in-memory store without contacting Firestore."
