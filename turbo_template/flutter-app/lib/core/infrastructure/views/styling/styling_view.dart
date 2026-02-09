import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_flutter_template/core/infrastructure/views/styling/styling_view_model.dart';
import 'package:turbo_flutter_template/core/ui/enums/emoji.dart';
import 'package:turbo_flutter_template/core/ui/widgets/t_scaffold.dart';
import 'package:turbo_flutter_template/core/ui/widgets/t_sliver_app_bar.dart';
import 'package:turbo_flutter_template/core/ui/widgets/t_sliver_body.dart';
import 'package:turbo_forms/turbo_forms.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

const List<String> _categoryTitles = [
  'Design',
  'Engineering',
  'Marketing',
  'Operations',
  'People',
  'Finance',
  'Legal',
  'Product',
];

const List<String> _categoryImageUrls = [
  'https://images.unsplash.com/photo-1487014679447-9f8336841d58',
  'https://images.unsplash.com/photo-1521737604893-d14cc237f11d',
  'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40',
  'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4',
];

final List<ImageProvider> _categoryImages = _categoryImageUrls
    .map((url) => NetworkImage(url))
    .toList();

const List<IconData> _categoryIcons = [
  Icons.palette_rounded,
  Icons.code_rounded,
  Icons.campaign_rounded,
  Icons.settings_rounded,
  Icons.people_alt_rounded,
  Icons.payments_rounded,
  Icons.balance_rounded,
  Icons.dashboard_rounded,
];

const String _categoryHeaderTitle = 'Browse categories';
const String _categoryHeaderDescription =
    'Explore curated categories with cards and sections that scale from small lists to rich grids.';

const String _collectionHeaderTitle = 'Browse collection items';
const String _collectionHeaderDescription =
    'Explore items within a collection using bento, list, or grid layouts.';

const List<String> _collectionTitles = [
  'Design system audit',
  'Launch checklist',
  'Marketing brief',
  'Engineering roadmap',
  'Research summary',
  'Hiring pipeline',
  'Sales enablement',
  'Product spec',
];

const List<String> _collectionSubtitles = [
  'Updated 2 days ago',
  'Updated 5 hours ago',
  'Updated 1 week ago',
  'Updated yesterday',
  'Updated 3 days ago',
  'Updated today',
  'Updated 4 days ago',
  'Updated 2 weeks ago',
];

const List<String> _collectionMeta = [
  '12 items',
  '8 items',
  '24 items',
  '16 items',
  '5 items',
  '14 items',
  '9 items',
  '11 items',
];

const List<double> _collectionSizes = [
  4,
  2,
  2,
  3,
  1,
  2,
  3,
  1,
];

const List<String> _collectionSortOptions = [
  'Recently updated',
  'Alphabetical',
  'Most items',
];

const List<String> _collectionFilterOptions = [
  'All',
  'Favorites',
  'Archived',
];

const String _entityHeaderTitle = 'Entity details';
const String _entityHeaderDescription =
    'Structured fields and markdown notes for a single entity.';

const List<TKeyValueField> _entityMetadata = [
  TKeyValueField(label: 'ID', value: 'ENT-2048'),
  TKeyValueField(label: 'Category', value: 'Operations'),
  TKeyValueField(label: 'Updated', value: '2 hours ago'),
];

class StylingView extends StatelessWidget {
  const StylingView({super.key});

  ImageProvider? _backgroundForIndex(int index) {
    if (index.isEven) {
      return _categoryImages[index % _categoryImages.length];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => TViewModelBuilder<StylingViewModel>(
    builder: (context, model, isInitialised, child) {
      if (!isInitialised) {
        return const SizedBox.shrink();
      }

      return TScaffold(
        child: TSliverBody(
          appBar: const TSliverAppBar(
            title: 'Styling',
            emoji: Emoji.paintbrush,
            onBackPressed: null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TCategoryHeader(
                  title: _categoryHeaderTitle,
                  description: _categoryHeaderDescription,
                  backgroundImage: _categoryImages.first,
                ),
                const SizedBox(height: 16),
                TCategorySection(
                  title: 'Featured categories',
                  caption: 'Horizontal list with show-all expansion',
                  itemCount: _categoryTitles.length,
                  maxItems: 6,
                  maxLines: 2,
                  itemBuilder: (context, index) => SizedBox(
                    width: 200,
                    child: TCategoryCard(
                      title: _categoryTitles[index],
                      icon: _categoryIcons[index % _categoryIcons.length],
                      backgroundImage: _backgroundForIndex(index),
                      onPressed: () {},
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TCategorySection(
                  title: 'All categories',
                  caption: 'Grid layout for larger lists',
                  layout: TCategorySectionLayout.grid,
                  gridCrossAxisCount: 2,
                  gridChildAspectRatio: 1.6,
                  itemCount: _categoryTitles.length,
                  itemBuilder: (context, index) => TCategoryCard(
                    title: _categoryTitles[index],
                    icon: _categoryIcons[index % _categoryIcons.length],
                    backgroundImage: _backgroundForIndex(index),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 24),
                const _TCollectionWidgetsShowcase(),
                const SizedBox(height: 32),
                _TEntityDetailWidgetsShowcase(
                  model: model,
                ),
              ],
            ),
          ),
        ),
      );
    },
    viewModelBuilder: () => StylingViewModel.locate,
  );
}

class _TCollectionWidgetsShowcase extends StatefulWidget {
  const _TCollectionWidgetsShowcase();

  @override
  State<_TCollectionWidgetsShowcase> createState() =>
      _TCollectionWidgetsShowcaseState();
}

class _TCollectionWidgetsShowcaseState
    extends State<_TCollectionWidgetsShowcase> {
  String _searchQuery = '';
  String _sortValue = _collectionSortOptions.first;
  String _filterValue = _collectionFilterOptions.first;
  TCollectionSectionLayout _layout = TCollectionSectionLayout.bento;

  ImageProvider? _backgroundForIndex(int index) {
    if (index.isEven) {
      return _categoryImages[index % _categoryImages.length];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TCollectionHeader(
          title: _collectionHeaderTitle,
          description: _collectionHeaderDescription,
          backgroundImage: _categoryImages.last,
        ),
        const SizedBox(height: 16),
        TCollectionToolbar(
          searchQuery: _searchQuery,
          onSearchChanged: (value) => setState(() => _searchQuery = value),
          sortLabel: 'Sort',
          sortOptions: _collectionSortOptions,
          sortValue: _sortValue,
          onSortSelected: (value) => setState(() => _sortValue = value),
          filterLabel: 'Filter',
          filterOptions: _collectionFilterOptions,
          filterValue: _filterValue,
          onFilterSelected: (value) => setState(() => _filterValue = value),
          layout: _layout,
          onLayoutChanged: (value) => setState(() => _layout = value),
        ),
        const SizedBox(height: 16),
        TCollectionSection(
          title: 'Collection items',
          caption: 'Layout adapts to bento, list, or grid display',
          layout: _layout,
          itemCount: _collectionTitles.length,
          itemSizeBuilder: (index) => _collectionSizes[index],
          bentoHeight: 360,
          gridCrossAxisCount: 2,
          gridChildAspectRatio: 1.6,
          itemBuilder: (context, index) {
            final title = _collectionTitles[index];
            final subtitle = _collectionSubtitles[index];
            final meta = _collectionMeta[index];
            final thumbnail = _backgroundForIndex(index);

            if (_layout == TCollectionSectionLayout.list) {
              return TCollectionListItem(
                title: title,
                subtitle: subtitle,
                meta: meta,
                leading: thumbnail == null
                    ? null
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image(
                          image: thumbnail,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onPressed: () {},
              );
            }

            return TCollectionCard(
              title: title,
              subtitle: subtitle,
              meta: meta,
              thumbnail: thumbnail,
              onPressed: () {},
            );
          },
        ),
      ],
    );
  }
}

class _TEntityDetailWidgetsShowcase extends StatelessWidget {
  const _TEntityDetailWidgetsShowcase({
    required this.model,
  });

  final StylingViewModel model;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final form = model.entityDetailForm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TDetailHeader(
          title: _entityHeaderTitle,
          description: _entityHeaderDescription,
          metadata: _entityMetadata,
          onSave: model.onHeaderSave,
        ),
        const SizedBox(height: 16),
        TFormSection(
          title: 'Core fields',
          caption: 'Form section using turbo_forms',
          formConfig: form,
          onSave: model.onSectionSave,
          formBuilder: (config) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TFormFieldRow(
                label: 'Title',
                field: form.title,
                builder: (field) => ShadInput(
                  controller: field.textEditingController,
                  focusNode: field.focusNode,
                  onChanged: field.silentUpdateValue,
                ),
                theme: theme,
              ),
              const SizedBox(height: 12),
              _TFormFieldRow(
                label: 'Status',
                field: form.status,
                builder: (field) => ShadSelect<String>(
                  placeholder: const Text('Select'),
                  focusNode: field.focusNode,
                  onChanged: field.silentUpdateValue,
                  controller: field.selectController,
                  enabled: field.isEnabled && !field.isReadOnly,
                  itemCount: field.items?.length ?? 0,
                  optionsBuilder: (context, index) {
                    final item = field.items![index];
                    return ShadOption(
                      value: item,
                      child: Text(item.toString()),
                    );
                  },
                  selectedOptionBuilder: (context, value) =>
                      Text(value.toString()),
                ),
                theme: theme,
              ),
              const SizedBox(height: 12),
              _TFormFieldRow(
                label: 'Owner',
                field: form.owner,
                builder: (field) => ShadInput(
                  controller: field.textEditingController,
                  focusNode: field.focusNode,
                  onChanged: field.silentUpdateValue,
                ),
                theme: theme,
              ),
              const SizedBox(height: 12),
              _TFormFieldRow(
                label: 'Summary',
                field: form.summary,
                builder: (field) => ShadInput(
                  controller: field.textEditingController,
                  focusNode: field.focusNode,
                  minLines: 3,
                  maxLines: 6,
                  onChanged: field.silentUpdateValue,
                ),
                theme: theme,
              ),
              const SizedBox(height: 12),
              _TFormFieldRow(
                label: 'Active',
                field: form.isActive,
                builder: (field) => ShadCheckbox(
                  value: field.cValue ?? false,
                  onChanged: (value) => field.silentUpdateValue(value),
                ),
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TFormFieldRow<T> extends StatelessWidget {
  const _TFormFieldRow({
    required this.label,
    required this.field,
    required this.builder,
    required this.theme,
  });

  final String label;
  final TFormFieldConfig<T> field;
  final Widget Function(TFormFieldConfig<T> field) builder;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return TFormField<T>(
      formFieldConfig: field,
      errorTextStyle: theme.textTheme.small.copyWith(
        color: theme.colorScheme.destructive,
      ),
      label: Text(
        label,
        style: theme.textTheme.small.copyWith(
          color: theme.colorScheme.mutedForeground,
        ),
      ),
      builder: (context, config, child) => builder(config),
    );
  }
}
