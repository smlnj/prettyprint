# prettyprint
A New (2023-4) SML/NJ Prettyprint library.
Version 11 (2024.09)

This repository contains implementation files and documentation for new pretty printer
library for SML/NJ. This is a two-phase pretty printer where a value to be prettyprinted
is first translated to a _format_, which is then _rendered_ to an
output medium (a display, printed text, or a string). A format might also be
translated another formatting language like HTML.

This new prettyprinter is intended to be installed in smlnj-lib as an
alternative to the earlier PP prettyprint library, which was derived
from the OCaml Format package.

## Features

- _flat_, _static_ measure of formats

- _memoized_ block measures

- _basic_ and _aligned_ blocks as compound formats

- **FLAT** format constructor, a format _modifier_ that causes a
  format to be rendered without line breaks.

- _indented_ formats, another format _modifier_.
  Indentation affects the complete content of a format.
  Indentation is conditional: it is activated if and only if the indented
  format begins on a fresh line (immediately following that line's indentation).

- styles (format modifier).
  Generic styles are just strings, which have to be interpreted to
  impose styles for a given output target.
  Output targets supporting styles are ANSI terminals and rendering to HTML 3 (smlnj-lib/HTML).

## Files

The PrettyPrint library is found in the prettyprint/src directory:

- src/format.sml: the datatypes defining formats. The type format is re-exported as
  from the Formatting structure as a quasi-abstract type
  (i.e. Formatting.format == Format.format, but no data constructors
  are exported from Formatting.)

- src/measure.{sig,sml}: computing the static, flat measure of a format

- src/formatting.{sig,sml}, the interface used for writing formatter functions
    Defines `Formatting : FORMATTING`

- src/render.sig, src/renderfn.sml: rendering a format to printed characters

- src/printformats

- src/source.cm: the CM file for compiling the prettyprinter,

- prettyprint-lib.cm, the CM file for compiling the prettyprinter,
  referring to src/prettyprint.cm. (??? sourc.cm vs prettyprint-lib.cm ???)

## The device model.

The render functor is parameterized over the DEVICE
signature defined in device/device.sig. It is possible that this device
model is "compatible" with the PPDevice library (which JHR is developing
the smlnj-lib library). I claim that the implementation of the ANSI
term device here is simpler and cleaner than the one found in PPDevice.

- device/device.cm

- device/device.sig

- device/plain-device.sml: plain text output device with no device
  styles or tokens
  
- device/ansiterm-device.sml: ANSI terminal device with device styles and tokens

## Other files

- CHANGELOG.md: the change log for the new prettyprint library.

- PPDevice (directory)
 
- jhr (directory)

The directory PPDevice is a copy (2024.09.10, 16:45 PDT) of the PPDevice directory
from smlnj-lib/Dev/PPDevice in the smlnj-lib-development branch of smlnj/smlnj.

The temporary directory jhr is a copy (as of 2024.09.10, 16:30 PDT) of
smlnj-lib/Dev/PrettyPrint/new from the smlnj-lib-development branch of smlnj/smlnj. This
is jhr's modified version of this PrettyPrint library. Some, but not all, of his suggested
changes have been adopted. See CHANGELOG.md for Version 11.

Version 11 incorporates some changes from the jhr version with the main (dbm) version in the
smlnj/prettyprint repository. It uses its own version of the Device signature that will be
matched by the PPDevice device signature (PPDevice/src/pp-device.sig).

In Version 11 there are some minor adjustments in formatting.{sig, sml} to incorporate
several minor jhr changes. The Device signature (srcdevice/device.sig) is modified to add style
(physical device style) and token types (the "physical" token representation). The
renderer requires two mappings, one a stylemap mapping "logical" styles (e.g. "keyword")
to a concrete device style type (e.g. lists of ANSITerm "modes" like "bold" and "red"),
and the other a tokenmap that map logical tokens (defined in the Token structure) to
possibly device-specific token encodings of the devise "physical" token type.

The device interface (DEVICE) includes the "withStyle" function, formerly known as
"renderStyled".

There is still no support for any form of tab or tabulation functionality in Version 11.
Some such functionality may be added in a future version. (For
instance, once we understand Sam Westrick's "scoped" tabs.)

## Documentation

[The documentation in the two adoc files is currently for Version 8.5,
so they need to be updated for Version 11.0 to document devices, styles (logical and
"physical"), tokens (logical and "physical"), stylemaps, and
tokenmaps, and changes to the FORMATTING interface.]

The following files are located in the doc directory:

- doc/str-PrettyPrint.{adoc, html}, the interface documentation

- doc/prettyprint-manual.{adoc, html}, the manual for the prettyprinter library

The file MLF2023-talk.pdf contains the slides for MacQueen's talk on
the new prettyprint library at the ML Family Workshop, Sept 8, 2023 in
Seattle.

A tech report with deeper and broader documentation of the design and its
background is being prepared and will be available sometime later.
