import 'package:turbo_serializable/abstracts/t_writeable.dart';

/// A map representing Markdown frontmatter, where each key and value is a String.
typedef TMdFrontmatter = Map<String, dynamic>;

/// Signature for building frontmatter from a TWriteable.
typedef TMdFrontmatterBuilder<T extends TWriteable> =
    TMdFrontmatter Function(
      T writeable,
    );

/// A single Markdown section, represented as a String.
typedef TMdSection = String;

// /// Signature for building a list of Markdown sections from a TWritable and frontmatter.
typedef TMdSectionsBuilder<T extends TWriteable> =
    List<TMdSection> Function(
      T writeable,
      TMdFrontmatter frontmatter,
    );

/// The main Markdown body, represented as a String.
typedef TMdBody = String;

/// Signature for building the Markdown body from a TWriteable, frontmatter, and sections.
typedef TMdBodyBuilder<T extends TWriteable> =
    TMdBody Function(
      T writeable,
      TMdFrontmatter frontmatter,
      List<TMdSection> sections,
    );

/// A full Markdown file, represented as a String.
typedef TMdFile = String;

/// Signature for building a complete Markdown file from a TWriteable, frontmatter, sections, and body.
typedef TMdFileBuilder<T extends TWriteable> =
    TMdFile Function(
      T writeable,
      TMdFrontmatter frontmatter,
      List<TMdSection> sections,
      TMdBody body,
    );
