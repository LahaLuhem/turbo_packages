import 'package:test/test.dart';
import 'package:turbo_serializable/abstracts/t_serializable.dart';
import 'package:turbo_serializable/extensions/ts_map_extension.dart';

class _FakeSerializable extends TSerializable {
  _FakeSerializable(this._json);

  final Map<String, dynamic> _json;

  @override
  Map<String, dynamic> toJson() => _json;
}

void main() {
  group('Map.toMd well-known key handling', () {
    test(
      'Given a nested map containing every well-known key,'
      ' When toMd renders it,'
      ' Then heading, callout, value, values and items appear in the defined order',
      () {
        final map = {
          'section': {
            'emoji': '🚀',
            'name': 'my section',
            'description': 'line one\nline two',
            'value': 'body text',
            'values': ['first paragraph', 'second paragraph'],
            'items': ['alpha', 'beta'],
          },
        };

        final md = map.toMd();

        expect(
          md,
          '# 🚀 My Section\n'
          '\n'
          '> line one\n'
          '> line two\n'
          '\n'
          'body text\n'
          '\n'
          'first paragraph\n'
          '\n'
          'second paragraph\n'
          '\n'
          '- alpha\n'
          '- beta\n'
          '\n',
        );
      },
    );

    test(
      'Given a deeply nested map with the well-known keys inside a child,'
      ' When toMd renders it,'
      ' Then the child section renders at heading level + 1 with the same structure',
      () {
        final map = {
          'parent': {
            'name': 'parent',
            'child': {
              'name': 'child',
              'value': 'nested body',
              'items': ['one'],
            },
          },
        };

        final md = map.toMd();

        expect(
          md,
          '# Parent\n'
          '\n'
          '## Child\n'
          '\n'
          'nested body\n'
          '\n'
          '- one\n'
          '\n',
        );
      },
    );

    test(
      'Given overridden well-known key names,'
      ' When toMd is called with the overrides,'
      ' Then the overrides are honored through recursion',
      () {
        final map = {
          'section': {
            'label': 'my section',
            'summary': 'summary text',
            'body': 'rendered body',
            'bullets': ['a', 'b'],
          },
        };

        final md = map.toMd(
          nameKey: 'label',
          descriptionKey: 'summary',
          valueKey: 'body',
          itemsKey: 'bullets',
        );

        expect(
          md,
          '# My Section\n'
          '\n'
          '> summary text\n'
          '\n'
          'rendered body\n'
          '\n'
          '- a\n'
          '- b\n'
          '\n',
        );
      },
    );
  });

  group('TSerializable.toMd parameter threading', () {
    test(
      'Given a TSerializable with overridden key names,'
      ' When toMd is called,'
      ' Then the overrides reach the underlying Map extension',
      () {
        final serializable = _FakeSerializable({
          'section': {
            'label': 'custom',
            'body': 'paragraph',
            'bullets': ['x', 'y'],
          },
        });

        final md = serializable.toMd(
          nameKey: 'label',
          valueKey: 'body',
          itemsKey: 'bullets',
        );

        expect(
          md,
          '# Custom\n'
          '\n'
          'paragraph\n'
          '\n'
          '- x\n'
          '- y\n'
          '\n',
        );
      },
    );
  });

  group('Map.toXml parameter forwarding on recursion', () {
    test(
      'Given a nested map with a list of maps,'
      ' When toXml is called with a listItemBuilder,'
      ' Then the listItemBuilder is used for primitive list items at every depth',
      () {
        final map = {
          'root': {
            'inner': {
              'tags': ['one', 'two'],
            },
          },
        };

        final xml = map.toXml(listItemBuilder: (_, v) => '<Tag>$v</Tag>');

        expect(xml.contains('<Tag>one</Tag>'), isTrue);
        expect(xml.contains('<Tag>two</Tag>'), isTrue);
      },
    );
  });
}
