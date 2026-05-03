# Changelog

## 1.0.3

### Changed
- Made `errorTextStyle` optional in `TErrorLabel`, `TFormField`, and `StatelessTFormField`
- Added `mainAxisSize: MainAxisSize.min` to form field column layout to prevent unnecessary vertical expansion

## 1.0.2

### Changed
- Updated `shadcn_ui` dependency from `^0.45.1` to `^0.53.5`

## 1.0.1

- Initial release as part of turbo_packages monorepo
- Form field configuration with `TFormFieldConfig` and `TFormFieldState`
- Field type enumeration with `TFieldType`
- Form validation with `TFormConfig` abstract class
- Widgets: `TFormField`, `TFormFieldBuilder`, `TErrorLabel`, `VerticalShrink`
- Extensions: `TurboFormNumExtension`, `TurboFormStringExtension`, `TurboFormObjectExtension`
- Constants: `TurboFormsDefaults` for animation durations and sizing
- ShadCN UI integration for controllers
