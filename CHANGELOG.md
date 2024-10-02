# CHANGELOG for PrettyPrint, aka the New DBM_PP Prettyprinter Library

## PrettyPrint Change Log:

**Version 7.1**

1. make the interface more consistent and orthogonal by introducing
"alignment" datatype and currying basic block constructing functions
with respect to alignment and indentation (bindent).

2. add "generic" version of formatList taking an alignment argument.


**Version 7.2**

1. BLOCK format constructor renamed ABLOCK (for aligned block).

2. Alignment replaces separator argument for several functions, such
as formatSeq and formatClosedSeq, and the alignment argument is
incorporated into the record argument as a field.

3. Added several functions to the interface: sequence, tupleFormats,
and listFormats, acting on format lists. alignedBlock, the general
constructor for aligned block, takes curried alignment and bindent
arguments.

4. Added functions for managing the line width: setLineWidthFun,
resetLineWidthFun, getLineWidth. These are used to isolate the prettyprinter
library from compiler internals like Control.Print.lineWidth.


**Version 7.3**

1. Added functions to the interface: labeled, printFormat, etc.

2. Added a new alignment constructor (alignment mode) named "C", for
"compact".  This mode introduces no separators between format
elements.  So cblock is the same as concat, which is now depricated as
redundant and will be removed in the next version.

3. Added a new EMPTY constructor for blocks.  This means the EMPTY
block is now _first class_.  EMPTY will act as an _identity_ element
for binary format operators like ccat, hcat, vcat, pcat, and it will
"disappear" (be absorbed) when it occurs within a block.  So, for instance,
a format like hcat (text "abc", empty) when rendered will not produce a
spurious space character after the text "abc", because

     hcat (fmt,empty) == fmt.

4. New sequence operators specializing the general "sequence" function.: E.g.

     psequence sepfmt fmts == sequence {alignment = P, sep = sepfmt} fmts

5. New str-NewPP.adoc file to document the NEWPP signature in the style
   of the smlnj-lib documentation.

6. Created newpp/doc directory and put design-notes.txt and
   manual.adoc in the new doc directory.


**Version 7.4**

1. Renamings:

  NewPP --> NewPrettyPrint    (newprettyprint.sml)
  NEW_PP --> NEW_PRETTYPRINT  (newprettyprint.sig)

  format.sml:
    separator --> break
	SEP --> BRK
	SBLOCK --> BLOCK

  newprettyprint.sml/sig
    specialBlock --> basicBlock
    sblock --> block
	siblock --> iblock

2. Added:

  format.sml (Format)
    NullBreak constructor of type break (was separator)

  newprettyprint.sig/sml (NewPrettyPrint: NEW_PRETTYPRINT)
	vHeaders, vHeaderFormats (from NewPPUtil)

3. Removed:

  newprettyprint.sig/sml
    tuple (use tupleFormat instead)


**Version 8.0**

0. Major change in the handling of indentation. Indentation is
   represented by two new format datacons: HINDENT, SINDENT. The
   bindent type is removed, as well as "indented block" functions.

1. Renamed:

2. Removed:

  format.sml, newprettyprint.{sig,sml}, measure.sml, render.sml
    bindent type removed

  NewPrettyPrint: NEW_PRETTYPRINT
    iblock, hiblock, piblock, viblock, ciblock

3. Added:

  format.sml
    format constructors: HINDENT, SINDENT (hard and soft indented formats)

4. Changed:

  newprettyprint.sig, sml (structure NewPrettyPrint)

	Implementation of hardIndent and softIndent have been changed. These
	functions are defined directly in terms of the HINDENT and SINDENT
	constructors, but are curried.


**Version 8.1 [2023.1.2]**

0. Merged HINDENT and SINDENT into a single format constructor INDENT
   that retains the behavior of SINDENT.  Function softIndent renamed
   to indent, and hardIndent replaced by breakIndent in NewPrettyPrint.

1. Renamed

   format.sml
     SINDENT --> INDENT  (* same semantics *)

   newprettyprint.sig,sml
     softIndent --> indent

2. Removed

   format.sml
     HINDENT

   newprettyprint.sig, sml
     hardIndent

3. Added

   newprettyprint.sig,sml
     breakIndent : int -> format -> format


**Version 8.2**

  NewPrettyPrint renamed PrettyPrint, and the corresponding change is made to file names,
  signatures, etc, and all former references to NewPrettyPrint throughout the compiler are
  replaced by references to PrettyPrint. The old PrettyPrint structure that was defined in
  Basics/print/prettyprint.sml is no longer used (or even compiled).

    NewPrettyPrint --> PrettyPrint
	NEW_PRETTYPRINT --> PRETTYPRINT
    smlnj-lib/NEWPP --> smlnj-lib/PRETTYPRINT
	src/newprettyprint.{sig,sml} --> src/prettyprint{sig,sml}
	smlnj-lib/NEWPP/newpp-lib.cm -> smlnj-lib/PRETTYPRINT/prettyprint-lib.cm


**Version 8.3**

  The PrettyPrint.breakIndent function is removed from PrettyPrint and PRETTYPRINT.
  It did not work correctly, because it was defined in terms of block, which resets
  the blm relative to which the indentation is taken.

  The smlnj-lib/PRETTYPRINT directory is renamed smlnj-lib/PrettyPrint.


**Version 8.4 [2023.2.22]**

Renamed:
  HardLine -> Hard
  SoftLine -> Soft
  NullBreak -> Null
  tupleFormats -> tuple
  list -> listMap (and removed)
  formatSeq -> sequenceMap  (and removed)
  formatClosedSeq -> closedSequenceMap (and removed)
  vHeaders -> vHeadersMap (and removed)
  vHeaderFormats -> vHeaders
Removed:
  tuple [i.e. the function that should have been "tupleMap"]

  _The binary xcat functions, replaced by calls of corresponding xblock but with lists of 2 formats:_
  hcat [hcat (f1, f2) -> hblock [f1,f2]]
  pcat [-> pblock]
  vcat [-> vblock]
  ccat [-> cblock]

  _The map versions of various functions:_
  sequenceMap
  closedSequenceMap
  listMap
  alignedListMap
  optionMap


**Version 8.5**
  - render and printFormat functions moved to new PrintFormat structure
  - signature PRETTYPRINT --> signature FORMATTING
  - structure PrettyPrint --> structure Formatting


**Version 9.1**

Introduced rendering with styled text for ANSI terminals and for rendering to HTML 3.

- Added a functor RenderFn over a DEVICE structure (render-fct.sml).
- Added DefaultDevice (default/device.sml) and ANSITermDevice (term/device.sml) structures
    to serve as arguments to RenderFn. These Device structures are associated their
    own Style structures, defined in default/style.sml and term/style.sml, respectively.
- default/render.sml and term/render.sml define two Render structures by applying RenderFn to
    DefaultDevice and ANSITermDevice, respectively.
- Added html directory with files render.sig, render.sml, and style.sml which define a third
    Render structure that produces HTML 3 abstract syntax as defined in smlnj-lib/HTML/html.sml.
- There are three cm description files:
    prettyprint.cm: Render = RenderFn (DefaultDevice)
    prettyprint-term.cm: Render = RenderFn (ANSITermDevice)
	prettyprint-html.cm: Render defined in html/render.sml


**Version 10.0 (2023.8)**

- Simplified styles (represented by strings).
- Two models for implementing styles
    -- device model, where their are two variants
       -- plain text (no style support)
	   -- ANSI terminal styles
    -- rendering to another markup language, such as HTML
- Device-based render function takes a device argument
    -- devices are record values of type DeviceType.device containing lineWidth plus
	   a collection of output functions
	   (src/device/device-type.sml)
    -- devices are responsible for "implementing" styles through a "renderStyle" function
    -- the device-based render function performs output directly using the device output
	   functions
- Rendering to HTML is handled by a specialized render function (src/html/html-render.sml)
    -- the HTML renderer produces the smlnj-lib/HTML representation of HTML 3, which then
	   needs to be translated to textual HTML code and rendered using (e.g.) a browser or
	   other HTML rendering engine.
- Major reorganization of the src directories. The src subdirectories are:
  base (Style, Token structures)
  device (DeviceType, PlainDevice, and ANSITermDevice)
  formatting (Format, Measure, Formatting)
  render (Render, PrintFormat)
  html (HTMLStyle, Render)

  The base directory was added to avoid a conflict because both formatting and smlnj-lib
  export a structure named "Format". This caused a CM error because device.cm was importing
  both formatting.cm and smlnj-lib. This was corrected by having device.cm import base.cm
  instead of formatting.cm. device.cm imports smlnj-lib for the
  ANSITerm structure.

  Note, however, that the smlnj-lib ANSITerm structure only has style constructor BF (for
  bold), and no italics style. Whether BF has any affect depends on whether the (default)
  typeface for the particular ANSITerm terminal has a bold font in its font family.  (The
  inconsolata type face I use in emacs does not, so no bold effect is available.

**Version 10.2 [2024.1]**

- Removed:
	setLineWidth   -- lineWidth is now a fixed attribute of a device
	resetLine
	getLineWidth
	render
	printFormat    -- moved to PRINT_FORMAT
	printFormatLW
	printFormatNL

- Revised version of Device: DEVICE such that a device is a simple record value rather
  than an "object-like" record of functions. A device type needs to specify and output
  stream and also a line width.

- A "logical" style is represented by a string (`Style.style == string`).

- Added Mode structures (as substructures of Device structures) that define the "mode" or
  "physical style" associated with a class of devices. Also introduced the stylemap type
  relative to a device class mode: (`stylemap = string -> mode`) which is used to
  translate logical style names into the desired physical style or mode for a given
  device. The definition of a stylemap is the responsibility of the writter of a
  particular formatter, who has to decide what "logical styles" to introduce and how they
  should translate to device modes.

- The Render structure is replaced by a RenderFn functor that takes a DEVICE structure
  as its argument.

- The render function now takes a stylemap and a device as arguments in addition to a
  (concrete, i.e. Format.format) format. The device provides the value of the line width.

- Two device structures are defined: `Plain_Device` and `ANSITerm_Device`. The Device
  model is not appropriate for the problem of, for instance, rendering formats to HTML.

- The name of the library remains as "Prettyprint" for the time being, but may change.


**Note on ANSI terminal variations**

For prettyprinting, we are only interested those ANSI escape codes that control
attributes of displayed text (font, color, underlining, weight, density, and blinking).

However, the implementation of such codes in a particular terminal (emulator) is sometimes
optional and is not consistent between terminal emulators. For instance, the Ubuntu
(Linux?) xterm program implements the boldface code using boldface, while the macOS
terminal program presents boldface text as boldfaced red text, while in the terminal
emulation in the emacs shell the boldface code has a very small effect (dependent on the
typeface used by emacs for the shell buffer).In general, the effect of some codes (like BF
for boldface) may depend on the typeface used by the terminal emulator, in particular on
the set of fonts available for that typeface. What happens when multiple codes are
combined can also vary between terminal emulations.


**Version 11.0 [2024.09]**

- Made some of the changes suggested by JHR.

- Flattened the src directory hierarchy so that all the prettyprinter
  source files are in the top-level directories src, device, and html.

- Changed:

	- xblock to xBlock, similarly xsequence -> xSequence;
		thus uniformly using camel case for value variables, including function names.

	- vHeaders -> replaced by "vSequenceLabeled", with a more general type
      and delegating label justification to preprocessing the label
      list with one of two new auxiliary functions, justifyRight and justifyLeft

- Added:

	- langle, rangle: angle brackers or "grouping" formats  

	- angleBrackets: enclosing a format in angle brackets 

    - spaces : int -> format, a somewhat redundant format-building
      function that may be useful to add ad hoc spacing in aligned
      blocks, where otherwise one would have to use a basic block with
	  Space breaks.
	  
	- justifyRight, justifyLeft auxiliary functions to be used
      in conjunction with the new vSequenceLabeled function to justify
      lists of labels by padding with spaces on the left, respectively right.

- Not Added:

	- I did not include the suggested "sequenceWithMap" and "closedSequenceWithMap" functions
	  which are redundant, since you can get the same effect by just composing one of the sequence 
	  functions with an ordinary map over the list of values.
	  Similar functions (ppSequence and ppClosedSequence) were provided in the (now redundant)
	  PPUtil: PPUTIL structure in the compiler (compiler/Basics/print/pputil.s??), but
	  in practice it has been found to be less cumbersome to just do the mapping explicitly and
      then operate on the resulting format list.

	- I renamed vHeaders to vSequenceLabeled with the same type and label justification (left).
	  This function could be generalized in various ways, such as by providing a list of labels
	  matching the list of formats in order, possibly with a label justification argument
	  (e.g. LEFT, RIGHT, NOJUST). Before adding such generalizations, I await convincing, real
      examples that require them.

	- smlOption, smlTuple, smlList - for formatting SML option, tuple, and list values
	  We already had such functions, but named simply "option", "tuple", and "list".
	  This is consistent with the naming of "string", "bool", "int", which assume SML
      primitive values. The difference is that here we are dealing with common compound values.

JHR has suggested that his (under development) PPDevice library should
be used as the interface and implementation for prettyprint devices. I
strongly prefer the simpler device model provided in the prettyprint/device
directory (from the smlnj/prettyprint repository). Let's call this the DBM
device model.

1. This device model is simpler and has fewer layers of complexity. In
   particular, it has a functional interface and does not expose
   functions that manipulate the _state_ of a device such as the pushStyle
   and popStyle functions. The withStyle function temporarily (and implicitly)
   changes the state of a device while executing a rendering thunk.

2. This device model defines styles in terms of sets of text highlighting attributes,
   where the highlighting attributes are determined by the nature of the underlying
   physical device, such as an ANSI terminal. Instead, the PPDevice model defines styles
   (for ANSI terminal devices) in terms of commands or operations (from the ANSITerm
   library structure) that alter the current state of the device (terminal). Logically
   this is more complex and more difficult to manage.  In the DBM device model, a terminal
   has an internal state with respect to text highlighting cosisting of a set of text
   attributes such as Bold and Red, and applying a style (defined as a list of such
   attributes) consists of _overlaying_ the style's attributes on the current set of
   terminal attributes (the "termState"). Undoing the application of a style is achieved
   by restoring a saved terminal state, rather than trying to reverse the effect of 
   a sequence of attribute-changing commands.
   
3. As a specific instance, the ANSITerm.REV command does not have a clear meaning as an
   element of the terminal state, which includes foreground and background color attributes
   as part of the state. Also, I do not consider the INVIS command as useful in the
   context of prettyprinting, so I have not included a corresponding invis attribute in
   the terminal state (but that could be done if there is a strong enough justification).
   
4. I don't believe a translation of formats to another layout formalism like html should
   be implemented using the device model. The src/html directory provides a prototype example of
   another approach, defining a sort of _homomorphism_ between the two layout formalisms.
   
    
   
   
   
