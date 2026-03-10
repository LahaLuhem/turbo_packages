# turbo_plx_cli

A Firestore-like API for local file operations via the plx CLI subprocess.

## Features

- **PlxService**: Manages plx CLI subprocess lifecycle and stdin/stdout communication
- **PlxFileApi**: Provides Firestore-like interface (get, list, create, update, delete, stream)
- **FileDto**: Data transfer object for file data with content and metadata

## Usage

```dart
import 'package:turbo_plx_cli/turbo_plx_cli.dart';

// Create and connect service
final plxService = PlxService();
await plxService.connect('/path/to/project');

// Use the file API
final fileApi = PlxFileApi(plxService: plxService);

// Get a single file
final response = await fileApi.get('specs/auth/spec.md');
if (response.isSuccess) {
  print(response.result.content);
  print(response.result.lastModified);
}

// List files in a directory
final listResponse = await fileApi.list('specs');
if (listResponse.isSuccess) {
  for (final file in listResponse.result) {
    print('${file.path}: ${file.lastModified}');
  }
}

// Stream file changes
fileApi.stream().listen((fileDto) {
  print('File changed: ${fileDto.path}');
});

// Disconnect when done
await plxService.disconnect();
```

## Requirements

- Dart SDK ^3.6.0
- plx CLI must be installed and accessible in PATH
