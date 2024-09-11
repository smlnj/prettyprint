# prettyprint
A New (2023) SML/NJ Prettyprint library.
Version 10.2 (2023.02)
Version 11 (2024.09)

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

- **FLAT** format constructor, a format _modifier_ that causes a
  format to be rendered without line breaks.

- _indented_ formats, another format _modifier_.
  Indentation affects the complete content of a format.
  Indentation is conditional: it is activated for an indented format if and only if the
  format begins on a fresh line (immediately following that line's indentation).

- styles (format modifier).
  Generic styles are just strings, which have to be interpreted to
  impose styles for a given output target.
  Output targets supporting styles are ANSI terminals and rendering to HTML 3 (smlnj-lib/HTML).

## Files

The PrettyPrint library is found in the prettyprint/src directory:

- src/format.sml, the datatypes defining formats. The type format is exported as
  an abstract type from Formatting

- src/measure.{sig,sml}, computing the static, flat measure of a format

- src/render.{sig,sml}, rendering a format to printed characters

- src/formatting.{sig,sml}, the interface used for writing formatter functions
    Defines `Formatting : FORMATTING`

- src/printformats

- src/source.cm, the CM file for compiling the prettyprinter,

- prettyprint-lib.cm, the CM file for compiling the prettyprinter,
  referring to src/prettyprint.cm.

- CHANGELOG.md, the change log for the new prettyprint library.

PPDevice is a copy (2024.09.10, 16:45 PDT) of the PPDevice directory
of smlnj-lib/Dev/PPDevice in the smlnj-lib-development branch of
smlnj/smlnj.

jhr is a copy (2024.09.10, 16:30 PDT) of the directory
smlnj-lib/Dev/PrettyPrint/new of the smlnj-lib-development branch of
smlnj/smlnj. This is jhr's version of this PrettyPrint library.

Version 11 is a merge of the jhr version with the main (dbm) version
in the smlnj/prettyprint repository. It contains its own version of
the Device signature that will be matched by the PPDevice device
signature version in PPDevice/src/pp-device.sig.

In Version 11 there are some minor adjustments in formatting.{sig,
sml} to incorporate minor jhr changes. The Device signature
(srcdevice/device.sig) is modified to add style (physical device
style) and token types (the "physical" token representation).  The
renderer requires two mappings, one a stylemap mapping "logical" styles
(e.g. "keyword") to a concrete device style type (e.g. lists of
ANSITerm "modes" like "bold" and "red"), and the other a tokenmap that
map logical tokens (defined in the Token structure) to possibly
device-specific token encodings of the devise "physical" token type.

There is still no support for any form of tab or tabulation
functionality in Version 11.

## Documentation

[The documentation in the two adoc files is currently for Version 8.5, and needs to be
updated for Version 11.0 to document styles, stylemaps, and tokenmaps.]

The following files are located in the doc directory:
- doc/str-PrettyPrint.{adoc, html}, the interface documentation

- doc/prettyprint-manual.{adoc, html}, the manual for the prettyprinter library

The file MLF2023-talk.pdf contains the slides for MacQueen's talk on
the new prettyprint library at the ML Family Workshop, Sept 8, 2023 in
Seattle.

A tech report with deeper and broader documentation of the design and its
background is being prepared and will be available sometime later.
