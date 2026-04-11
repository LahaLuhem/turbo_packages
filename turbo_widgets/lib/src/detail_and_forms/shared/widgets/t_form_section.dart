import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_forms/turbo_forms.dart';

class TFormSection extends StatelessWidget {
  const TFormSection({
    required this.title,
    super.key,
    this.caption,
    this.formConfig,
    this.formBuilder,
    this.children,
    this.onSave,
    this.saveLabel = 'Save',
    this.sectionSpacing = 12,
  });

  final String title;
  final String? caption;
  final TFormConfig? formConfig;
  final Widget Function(TFormConfig config)? formBuilder;
  final List<Widget>? children;
  final VoidCallback? onSave;
  final String saveLabel;
  final double sectionSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final content = _resolveContent(context);

    return ShadCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TFormSectionHeader(
            title: title,
            caption: caption,
            theme: theme,
            onSave: onSave,
            saveLabel: saveLabel,
          ),
          SizedBox(height: sectionSpacing),
          content,
        ],
      ),
    );
  }

  Widget _resolveContent(BuildContext context) {
    final config = formConfig;
    if (config != null) {
      if (formBuilder != null) {
        return formBuilder!(config);
      }
      if (children != null) {
        return _TFormSectionChildren(children: children!);
      }
      return _TFormSectionDefaults(formConfig: config);
    }

    if (children != null) {
      return _TFormSectionChildren(children: children!);
    }

    return const SizedBox.shrink();
  }
}

class _TFormSectionHeader extends StatelessWidget {
  const _TFormSectionHeader({
    required this.title,
    required this.theme,
    this.caption,
    this.onSave,
    this.saveLabel = 'Save',
  });

  final String title;
  final String? caption;
  final ShadThemeData theme;
  final VoidCallback? onSave;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    final showSave = onSave != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.large.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: 4),
                Text(
                  caption!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.muted,
                ),
              ],
            ],
          ),
        ),
        if (showSave) ...[
          const SizedBox(width: 12),
          ShadButton(
            onPressed: onSave,
            child: Text(saveLabel),
          ),
        ],
      ],
    );
  }
}

class _TFormSectionChildren extends StatelessWidget {
  const _TFormSectionChildren({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          children[index],
        ],
      ],
    );
  }
}

class _TFormSectionDefaults extends StatelessWidget {
  const _TFormSectionDefaults({
    required this.formConfig,
  });

  final TFormConfig formConfig;

  @override
  Widget build(BuildContext context) {
    final configsMap =
        (formConfig as dynamic).formFieldConfigs as Map<Enum, TFormFieldConfig>;
    final configs = configsMap.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int index = 0; index < configs.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          _TFormSectionField(config: configs[index]),
        ],
      ],
    );
  }
}

class _TFormSectionField extends StatelessWidget {
  const _TFormSectionField({
    required this.config,
  });

  final TFormFieldConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return TFormField(
      formFieldConfig: config,
      errorTextStyle: theme.textTheme.small.copyWith(
        color: theme.colorScheme.destructive,
      ),
      builder: (context, fieldConfig, child) {
        return switch (fieldConfig.fieldType) {
          TFieldType.checkbox => ShadCheckbox(
            value: fieldConfig.cValue as bool? ?? false,
            onChanged: (value) => fieldConfig.silentUpdateValue(value),
          ),
          TFieldType.select || TFieldType.selectMulti => ShadSelect(
            placeholder: const Text('Select'),
            focusNode: fieldConfig.focusNode,
            onChanged: fieldConfig.silentUpdateValue,
            controller: fieldConfig.selectController,
            enabled: fieldConfig.isEnabled && !fieldConfig.isReadOnly,
            itemCount: fieldConfig.items?.length ?? 0,
            optionsBuilder: (context, index) {
              final item = fieldConfig.items![index];
              return ShadOption(
                value: item,
                child: Text(item.toString()),
              );
            },
            selectedOptionBuilder: (context, value) => Text(value.toString()),
          ),
          _ => ShadInput(
            controller: fieldConfig.textEditingController,
            focusNode: fieldConfig.focusNode,
            initialValue: fieldConfig.initialValue?.toString(),
            readOnly: fieldConfig.isReadOnly,
            enabled: fieldConfig.isEnabled && !fieldConfig.isReadOnly,
            minLines: fieldConfig.fieldType == TFieldType.textArea ? 3 : 1,
            maxLines: fieldConfig.fieldType == TFieldType.textArea ? 6 : 1,
            onChanged: (value) => fieldConfig.silentUpdateValue(value),
          ),
        };
      },
    );
  }
}
