import 'dart:io';

/// Mock CLI that reads stdin but never responds.
/// Used for testing timeout behavior.
void main() async {
  await for (final _ in stdin) {
    // Intentionally ignore all input - never respond
  }
}
