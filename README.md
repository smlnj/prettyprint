# prettyprint
A New (2023) SML/NJ Prettyprint library.

This repository contains implementation files and documentation for new pretty printer
library for SML/NJ. This is a two-phase pretty printer where a value to be prettyprinted
is first mapped to a _format_, which is then _rendered_ to printed text (or, potentially,
to some "layout" type, such as string).

This new prettyprinter is intended to be installed in smlnj-lib as an
alternative to the earlier PP prettyprint library, which is derived
from the OCaml Format package.

## Features

- _flat_, _static_ measure of formats

- _memoized_ block measures

- _basic_ and _aligned_ blocks as compound formats

- **FLAT** format constructor (replaces **TRYFLAT** constructor from earlier versions)

- _indented_ formats
  Indentation is a format modifier and is not associated with line breaks.
  Indentation affects the complete content of a format.
  Indentation is conditional: it is activated for an indented format if and only if the
  format begins on a fresh line (immediately following that line's indentation).

- styles for ANSI terminal output and for rendering to HTML 3 (smlnj-lib/HTML).

## Files

The PrettyPrint library is found in smlnj-lib/PRETTYPRINT.

- src/format.sml, the datatypes defining formats

- src/measure.{sig,sml}, computing the static, flat measure of a format

- src/render.{sig,sml}, rendering a format to printed characters

- src/formatting.{sig,sml}, the interface used for writing formatter functions
    Defines `Formatting : FORMATTING`

- src/printformats

- src/source.cm, the CM file for compiling the prettyprinter,

- prettyprint-lib.cm, the CM file for compiling the prettyprinter,
  referring to src/prettyprint.cm.

- CHANGELOG.md, the change log for the new prettyprint library.

## Documentation

The following files are located in the doc directory:
[This documentation is currently for Version 8.5. It needs to be
updated for Version 10.0]

- doc/str-PrettyPrint.{adoc, html}, the interface documentation

- doc/prettyprint-manual.{adoc, html}, the manual for the prettyprinter library

A tech report with deeper documentation of the design and history is
being prepared and should be available by early September, 2023.
