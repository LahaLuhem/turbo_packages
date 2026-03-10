import 'dart:async';

import 'package:turbo_plx_cli/src/abstracts/plx_client_interface.dart';
import 'package:turbo_plx_cli/src/dtos/file_entry_dto.dart';
import 'package:turbo_plx_cli/src/dtos/watch_event_dto.dart';
import 'package:turbo_plx_cli/src/enums/watch_event_type.dart';
import 'package:turbo_plx_cli/src/exceptions/plx_exception.dart';
import 'package:turbo_response/turbo_response.dart';

class PlxApi {
  PlxApi({required PlxClientInterface plxClient}) : _plxClient = plxClient;

  final PlxClientInterface _plxClient;

  Future<TurboResponse<FileEntryDto>> get(String path) async {
    try {
      final response = await _plxClient.sendRequest(
        WatchEventDto(
          event: WatchEventType.get,
          path: path,
        ),
      );

      if (response.event == WatchEventType.error) {
        return TurboResponse.fail(
          error: PlxException(response.content ?? 'Unknown error'),
          title: 'File Read Error',
          message: response.content,
        );
      }

      return TurboResponse.success(
        result: FileEntryDto(
          path: response.path,
          content: response.content,
          lastModified: response.lastModified,
        ),
      );
    } catch (e, stackTrace) {
      return TurboResponse.fail(
        error: e,
        title: 'File Read Error',
        message: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  Future<TurboResponse<List<FileEntryDto>>> list(String path) async {
    try {
      final response = await _plxClient.sendRequest(
        WatchEventDto(
          event: WatchEventType.list,
          path: path,
        ),
      );

      if (response.event == WatchEventType.error) {
        return TurboResponse.fail(
          error: PlxException(response.content ?? 'Unknown error'),
          title: 'List Error',
          message: response.content,
        );
      }

      final files =
          response.files
              ?.map(
                (entry) => FileEntryDto(
                  path: entry.path,
                  content: entry.content,
                  lastModified: entry.lastModified,
                ),
              )
              .toList() ??
          [];

      return TurboResponse.success(result: files);
    } catch (e, stackTrace) {
      return TurboResponse.fail(
        error: e,
        title: 'List Error',
        message: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  Future<TurboResponse<FileEntryDto>> create(
    String path,
    String content,
  ) async {
    try {
      final response = await _plxClient.sendRequest(
        WatchEventDto(
          event: WatchEventType.create,
          path: path,
          content: content,
        ),
      );

      if (response.event == WatchEventType.error) {
        return TurboResponse.fail(
          error: PlxException(response.content ?? 'Unknown error'),
          title: 'File Create Error',
          message: response.content,
        );
      }

      return TurboResponse.success(
        result: FileEntryDto(
          path: response.path,
          content: response.content,
          lastModified: response.lastModified,
        ),
      );
    } catch (e, stackTrace) {
      return TurboResponse.fail(
        error: e,
        title: 'File Create Error',
        message: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  Future<TurboResponse<FileEntryDto>> update(
    String path,
    String content,
  ) async {
    try {
      final response = await _plxClient.sendRequest(
        WatchEventDto(
          event: WatchEventType.modify,
          path: path,
          content: content,
        ),
      );

      if (response.event == WatchEventType.error) {
        return TurboResponse.fail(
          error: PlxException(response.content ?? 'Unknown error'),
          title: 'File Update Error',
          message: response.content,
        );
      }

      return TurboResponse.success(
        result: FileEntryDto(
          path: response.path,
          content: response.content,
          lastModified: response.lastModified,
        ),
      );
    } catch (e, stackTrace) {
      return TurboResponse.fail(
        error: e,
        title: 'File Update Error',
        message: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  Future<TurboResponse<bool>> delete(String path) async {
    try {
      final response = await _plxClient.sendRequest(
        WatchEventDto(
          event: WatchEventType.delete,
          path: path,
        ),
      );

      if (response.event == WatchEventType.error) {
        return TurboResponse.fail(
          error: PlxException(response.content ?? 'Unknown error'),
          title: 'File Delete Error',
          message: response.content,
        );
      }

      return const TurboResponse.success(result: true);
    } catch (e, stackTrace) {
      return TurboResponse.fail(
        error: e,
        title: 'File Delete Error',
        message: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  Stream<FileEntryDto> stream() {
    return _plxClient.events
        .where((event) => event.event != WatchEventType.error)
        .map(
          (event) => FileEntryDto(
            path: event.path,
            content: event.content,
            lastModified: event.lastModified,
          ),
        );
  }
}
