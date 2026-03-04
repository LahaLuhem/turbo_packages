## ADDED Requirements

### Requirement: TBentoGrid animation controller initializes in initState
The `TBentoGrid` widget SHALL set `_controller.value = 1.0` for fade and scale animations in `initState` instead of the build method. This prevents the animation controller from being reset on every rebuild where `_currentLayout` is null.

#### Scenario: Animation controller value set once during widget initialization
- **WHEN** `TBentoGrid` is first mounted with no current layout
- **THEN** the animation controller value is set to 1.0 in `initState`

#### Scenario: Rebuilds do not reset animation controller
- **WHEN** `TBentoGrid` rebuilds and `_currentLayout` is null
- **THEN** the animation controller value is NOT reassigned in the build method

### Requirement: TBentoGrid formatting complies with dart format
The `TBentoGrid` source file SHALL pass `dart format` with no changes needed.

#### Scenario: File passes dart format check
- **WHEN** running `dart format --set-exit-if-changed` on `t_bento_grid.dart`
- **THEN** the command exits with code 0 (no changes needed)
