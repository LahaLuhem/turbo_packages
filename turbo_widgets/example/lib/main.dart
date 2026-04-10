import 'package:flutter/material.dart';

void main() {
  runApp(const TurboWidgetsExampleApp());
}

class TurboWidgetsExampleApp extends StatelessWidget {
  const TurboWidgetsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'turbo_widgets example',
      debugShowCheckedModeBanner: false,
      home: _PlaceholderHome(),
    );
  }
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('turbo_widgets example')),
      body: const SizedBox.shrink(),
    );
  }
}
