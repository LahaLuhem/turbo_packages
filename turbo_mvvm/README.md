# Turbo MVVM

[![Pub Version](https://img.shields.io/pub/v/turbo_mvvm?logo=dart&label=turbo_mvvm)](https://pub.dev/packages/turbo_mvvm)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![GitHub Stars](https://img.shields.io/github/stars/appboypov/turbo_packages?style=social)](https://github.com/appboypov/turbo_packages)

A lightweight MVVM state management solution for Flutter, inspired by the [FilledStacks](https://www.filledstacks.com/) [stacked](https://pub.dev/packages/stacked) package. It simplifies managing view logic, state, and lifecycle in your Flutter applications.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Core Concepts](#core-concepts)
  - [TBaseViewModel](#tbaseviewmodel)
  - [TViewModelBuilder](#tviewmodelbuilder)
  - [TBaseEventViewModel](#tbaseeventviewmodel)
  - [TEventManagement](#teventmanagement)
  - [Mixins](#mixins)
  - [TBusyService](#tbusyservice)
- [Usage Guide](#usage-guide)
  - [1. Create your ViewModel](#1-create-your-viewmodel)
  - [2. Connect ViewModel to your View](#2-connect-viewmodel-to-your-view)
  - [3. Event-Driven ViewModel](#3-event-driven-viewmodel)
  - [4. Managing Busy State](#4-managing-busy-state)
  - [5. Handling Errors](#5-handling-errors)
  - [6. Global Busy State with TBusyService](#6-global-busy-state-with-tbusyservice)
  - [7. Passing Arguments to ViewModel](#7-passing-arguments-to-viewmodel)
- [Example Project](#example-project)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)

## Features

- **ViewModel Lifecycle Management**: Automatic handling of `initialise` and `dispose` methods.
- **Reactive UI Updates**: Widgets rebuild efficiently when ViewModel state changes using `rebuild()` or `ValueNotifier`.
- **Event-Driven ViewModels**: Sequential event processing via `TBaseEventViewModel` with stream-based queue.
- **Standalone Event Management**: Use `TEventManagement` outside of ViewModels for event-driven logic.
- **State Management**: Built-in support for managing `isInitialised`, `isBusy`, and `hasError` states.
- **Context Access**: Safe access to `BuildContext` within ViewModels.
- **Argument Passing**: Simple mechanism to pass arguments to ViewModels during initialization.
- **Global Busy Indicator**: Centralized `TBusyService` for managing application-wide busy states.
- **Helper Mixins**: Utility mixins like `TBusyManagement`, `TErrorManagement`, and `TViewModelHelpers`.

## Installation

Add `turbo_mvvm` to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  turbo_mvvm: ^1.3.0
```

Install the package:

```bash
flutter pub get
```

Import it:

```dart
import 'package:turbo_mvvm/turbo_mvvm.dart';
```

## Core Concepts

### TBaseViewModel

The base class for all ViewModels. Extend `TBaseViewModel<A>` where `A` is the type of arguments passed to the ViewModel.

Key features:
- `initialise()`: Called once when the ViewModel is created. Set up data and listeners here.
- `dispose()`: Called when the ViewModel is removed. Clean up resources here.
- `rebuild()`: Notifies listeners (the `TViewModelBuilder`) to rebuild the UI.
- `isMounted`: Whether the parent widget is still in the widget tree.
- `context`: Safe access to the `BuildContext`.
- `arguments`: Arguments passed via `TViewModelBuilder`.
- `isInitialised`: A `ValueListenable<bool>` indicating initialisation completion.

### TViewModelBuilder

A widget that creates and provides a `TBaseViewModel` to the widget tree. It listens to the ViewModel and rebuilds when `rebuild()` is called.

Key parameters:
- `viewModelBuilder`: Returns an instance of your ViewModel.
- `builder`: Builds the UI with `context`, `model`, `isInitialised`, and optional `child`.
- `argumentBuilder` (optional): Provides arguments to `initialise`.
- `isReactive` (default: `true`): Rebuilds on `notifyListeners()`.
- `shouldDispose` (default: `true`): Auto-calls `dispose()` on removal.
- `minBusyDuration` (optional): Shows global busy overlay during initialisation for at least this duration.
- `onDispose` (optional): Callback when the ViewModel is disposed.

### TBaseEventViewModel

An event-driven ViewModel that processes events sequentially via a stream-based queue. Extend `TBaseEventViewModel<ARGUMENTS, EVENT>` where `EVENT` is an enum or sealed class representing your events.

Key features:
- `events`: Declare the set of events this ViewModel handles.
- `onEvent(EVENT)`: Return a handler for each event.
- `emit(EVENT)`: Fire an event for processing.
- `emitAsync<RESULT>(EVENT)`: Fire an event and await its result.
- Events are processed sequentially via an internal queue.
- Error handling via `onEventError`, `onStreamError`, and `onDone` overrides.

### TEventManagement

A standalone abstract class providing the same event-driven architecture as `TBaseEventViewModel`, but without requiring a ViewModel. Use this when you need sequential event processing in services or other non-widget classes.

### Mixins

- **`TBusyManagement`**: Adds `isBusy` (`ValueListenable<bool>`), `busyTitle`, `busyMessage`, and `setBusy()` for local busy states.
- **`TErrorManagement`**: Adds `hasError` (`ValueListenable<bool>`), `errorTitle`, `errorMessage`, and `setError()` for local error states.
- **`TViewModelHelpers`**: Provides `wait()` (delay) and `addPostFrameCallback()`.
- **`TBusyServiceManagement`**: Integrates with the global `TBusyService` for application-wide busy states.

### TBusyService

A singleton service for managing a global busy state. Useful for showing an overlay loading indicator across the entire app.

- `TBusyService.instance()`: Access the singleton.
- `TBusyService.initialise()`: Configure default message, title, type, and timeout.
- `setBusy(bool isBusy, ...)`: Set the global busy state.
- `isBusyListenable`: A `ValueListenable<TBusyModel>` for changes.
- `TBusyModel`: Contains `isBusy`, `busyTitle`, `busyMessage`, `busyType`, and `payload`.
- `TBusyType`: Enum controlling the indicator appearance (`indicator`, `indicatorBackdrop`, etc.).

## Usage Guide

### 1. Create your ViewModel

Extend `TBaseViewModel` and add your business logic with desired mixins.

```dart
import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';

class MyViewModel extends TBaseViewModel<String>
    with TBusyManagement, TErrorManagement {

  final ValueNotifier<int> _counter = ValueNotifier(0);
  ValueListenable<int> get counter => _counter;

  String? _greeting;
  String? get greeting => _greeting;

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    _greeting = "Hello, $arguments!";
    setBusy(true, message: "Loading data...");
    await Future.delayed(const Duration(seconds: 2));
    _counter.value = 10;
    setBusy(false);
    super.initialise(doSetInitialised: doSetInitialised);
  }

  void incrementCounter() {
    _counter.value++;
  }

  @override
  FutureOr<void> dispose() {
    _counter.dispose();
    disposeBusyManagement();
    disposeErrorManagement();
    super.dispose();
  }
}
```

### 2. Connect ViewModel to your View

Use `TViewModelBuilder` in your widget.

```dart
import 'package:flutter/material.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';

class MyView extends StatelessWidget {
  const MyView({super.key});

  @override
  Widget build(BuildContext context) {
    return TViewModelBuilder<MyViewModel>(
      viewModelBuilder: () => MyViewModel(),
      argumentBuilder: () => "World",
      builder: (context, model, isInitialised, child) {
        if (!isInitialised) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(model.greeting ?? "Turbo MVVM")),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: model.counter,
                  builder: (context, count, _) {
                    return Text(
                      'Counter: $count',
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: model.incrementCounter,
                  child: const Text('Increment'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### 3. Event-Driven ViewModel

Use `TBaseEventViewModel` for ViewModels that process discrete events sequentially.

```dart
import 'package:turbo_mvvm/turbo_mvvm.dart';

enum CounterEvent { increment, decrement, reset }

class CounterViewModel extends TBaseEventViewModel<void, CounterEvent>
    with TBusyManagement {
  int _count = 0;
  int get count => _count;

  @override
  Set<CounterEvent> get events => CounterEvent.values.toSet();

  @override
  TEventHandler<CounterEvent> onEvent(CounterEvent event) {
    return switch (event) {
      CounterEvent.increment => (_) async {
        _count++;
        rebuild();
      },
      CounterEvent.decrement => (_) async {
        _count--;
        rebuild();
      },
      CounterEvent.reset => (_) async {
        _count = 0;
        rebuild();
      },
    };
  }
}
```

Emit events from the UI:

```dart
TViewModelBuilder<CounterViewModel>(
  viewModelBuilder: () => CounterViewModel(),
  builder: (context, model, isInitialised, child) {
    return Column(
      children: [
        Text('Count: ${model.count}'),
        ElevatedButton(
          onPressed: () => model.emit(CounterEvent.increment),
          child: const Text('Increment'),
        ),
      ],
    );
  },
);
```

### 4. Managing Busy State

The `TBusyManagement` mixin provides:
- `isBusy`: A `ValueListenable<bool>` for the busy state.
- `setBusy(bool isBusy, {String? title, String? message})`: Update the busy state.
- `disposeBusyManagement()`: Clean up resources (call in `dispose`).

### 5. Handling Errors

The `TErrorManagement` mixin provides:
- `hasError`: A `ValueListenable<bool>` for the error state.
- `setError(bool hasError, {String? title, String? message})`: Update the error state.
- `disposeErrorManagement()`: Clean up resources (call in `dispose`).

### 6. Global Busy State with TBusyService

For application-wide loading indicators:

```dart
void main() {
  TBusyService.initialise(
    busyMessageDefault: "Please wait...",
    busyTypeDefault: TBusyType.indicatorBackdrop,
    timeoutDurationDefault: const Duration(seconds: 30),
  );
  runApp(MyApp());
}
```

Use `TBusyServiceManagement` mixin in ViewModels to control the global busy state, or use `TViewModelBuilder.minBusyDuration` to show a busy overlay during initialisation.

### 7. Passing Arguments to ViewModel

Pass arguments via `argumentBuilder` and access them in `initialise()`:

```dart
TViewModelBuilder<MyViewModel>(
  viewModelBuilder: () => MyViewModel(),
  argumentBuilder: () => "Hello",
  builder: (context, model, isInitialised, child) { ... },
);
```

The argument is available as `arguments` inside the ViewModel after `initState`.

## Example Project

Check the `/example` directory for a complete Flutter application demonstrating Turbo MVVM features.

## Dependencies

- [`provider`](https://pub.dev/packages/provider): Used internally by `TViewModelBuilder` for efficient state propagation.

## Contributing

Contributions are welcome! Please open issues or pull requests on the [GitHub repository](https://github.com/appboypov/turbo_packages).

## License

This package is licensed under the BSD 3-Clause License. See the [LICENSE](LICENSE) file for details.
