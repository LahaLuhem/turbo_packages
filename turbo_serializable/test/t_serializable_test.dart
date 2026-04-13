import 'package:test/test.dart';
import 'package:turbo_serializable/abstracts/t_serializable.dart';
import 'package:turbo_serializable/abstracts/t_writeable.dart';
import 'package:turbo_serializable/markdown/factories/t_md_factory.dart';

// ---------------------------------------------------------------------------
// Test fixture — minimal concrete subclass of TSerializable.
// Returns a fresh Map on every toJson() call to avoid mutation bleed from
// the map-extension fallbacks (which call remove('metaData')).
// ---------------------------------------------------------------------------
class _TestSerializable extends TSerializable {
  const _TestSerializable({
    super.yamlBuilder,
    super.mdFactory,
    super.xmlBuilder,
    super.dartBuilder,
  });

  @override
  Map<String, dynamic> toJson() => {
        'name': 'TestEntity',
        'value': 42,
      };
}

void main() {
  // =========================================================================
  // toDart()
  // =========================================================================
  group('TSerializable.toDart', () {
    test(
      'Given no dartBuilder and no override '
      'when toDart is called '
      'then it throws UnimplementedError',
      () {
        // Given
        const sut = _TestSerializable();

        // When / Then
        expect(() => sut.toDart(), throwsA(isA<UnimplementedError>()));
      },
    );

    test(
      'Given a dartBuilder is provided '
      'when toDart is called '
      'then it returns the builder output',
      () {
        // Given
        const expectedOutput = "const Role(name: 'Admin');";
        final sut = _TestSerializable(
          dartBuilder: (TWriteable writeable) => expectedOutput,
        );

        // When
        final result = sut.toDart();

        // Then
        expect(result, equals(expectedOutput));
      },
    );

    test(
      'Given a dartBuilder is provided '
      'when toDart is called '
      'then the builder receives the serializable instance',
      () {
        // Given
        TWriteable? receivedWriteable;
        final sut = _TestSerializable(
          dartBuilder: (TWriteable writeable) {
            receivedWriteable = writeable;
            return 'output';
          },
        );

        // When
        sut.toDart();

        // Then
        expect(receivedWriteable, same(sut));
      },
    );
  });

  // =========================================================================
  // Regression — existing serialization methods still work after constructor
  // change.
  // =========================================================================
  group('TSerializable regression', () {
    test(
      'Given no yamlBuilder '
      'when toYaml is called '
      'then it falls back to map extension output',
      () {
        // Given
        const sut = _TestSerializable();

        // When
        final result = sut.toYaml();

        // Then — the map extension produces YAML with snake_case keys
        expect(result, contains('name:'));
        expect(result, contains('TestEntity'));
        expect(result, contains('value:'));
        expect(result, contains('42'));
      },
    );

    test(
      'Given a yamlBuilder is provided '
      'when toYaml is called '
      'then builder output wins over fallback',
      () {
        // Given
        const expectedYaml = 'custom_yaml: true';
        final sut = _TestSerializable(
          yamlBuilder: (TWriteable writeable, bool includeMeta) => expectedYaml,
        );

        // When
        final result = sut.toYaml();

        // Then
        expect(result, equals(expectedYaml));
      },
    );

    test(
      'Given no xmlBuilder '
      'when toXml is called '
      'then it falls back to map extension output',
      () {
        // Given
        const sut = _TestSerializable();

        // When
        final result = sut.toXml();

        // Then — the map extension produces XML with PascalCase tags
        expect(result, contains('<Name>TestEntity</Name>'));
        expect(result, contains('<Value>42</Value>'));
      },
    );

    test(
      'Given an xmlBuilder is provided '
      'when toXml is called '
      'then builder output wins over fallback',
      () {
        // Given
        const expectedXml = '<Custom>xml</Custom>';
        final sut = _TestSerializable(
          xmlBuilder: (TWriteable writeable, bool includeMeta) => expectedXml,
        );

        // When
        final result = sut.toXml();

        // Then
        expect(result, equals(expectedXml));
      },
    );

    test(
      'Given no mdFactory '
      'when toMd is called '
      'then it falls back to map extension output',
      () {
        // Given
        const sut = _TestSerializable();

        // When
        final result = sut.toMd();

        // Then
        expect(result, contains('TestEntity'));
        expect(result, contains('42'));
      },
    );

    test(
      'Given an mdFactory '
      'when toMd is called with includeMetaData true '
      'then it returns the factory build output',
      () {
        // Given
        final sut = _TestSerializable(
          mdFactory: TMdFactory<_TestSerializable>(
            writeable: const _TestSerializable(),
            mdFileBuilder: (writeable, frontmatter, sections, body) =>
                'full-md-output',
          ),
        );

        // When
        final result = sut.toMd();

        // Then
        expect(result, equals('full-md-output'));
      },
    );

    test(
      'Given an mdFactory '
      'when toMd is called with includeMetaData false '
      'then it returns the factory buildBody output',
      () {
        // Given
        final sut = _TestSerializable(
          mdFactory: TMdFactory<_TestSerializable>(
            writeable: const _TestSerializable(),
            mdBodyBuilder: (writeable, frontmatter, sections) =>
                'body-only-output',
          ),
        );

        // When
        final result = sut.toMd(includeMetaData: false);

        // Then
        expect(result, equals('body-only-output'));
      },
    );
  });
}
