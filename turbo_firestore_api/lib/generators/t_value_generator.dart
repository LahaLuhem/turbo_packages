/// The callback contract every value provider in the dummy generator system
/// implements.
///
/// Consumers encounter this type when supplying field or type overrides to
/// [TValueGeneratorRegistry] or [TDummyFirestoreApi].
typedef TValueGenerator = dynamic Function();
