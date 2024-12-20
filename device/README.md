prettyprint/device/README.md

#PrettyPrint

This is a device library for use with the new prettyprinter library (lets call it the
DBM_PP library for now). The device abstraction models an output or display facility for
use by the rendering phase of a pretty printer. A device defines a line length for the
output device. It can also support device specific "styles" for highlighting text and
device specific "tokens" or special symbols (typically Unicode symbols).

Initially there are just two specific devices definded. PlainDevice for printing to
plain (i.e., ASCII) text, and ANSITermDevice for printing to an ANSII terminal (emulator)
that support certain text highlighting modes and that can render at least some Unicode
glyphs. The (DBM_PP) prettyprint library

This device library is simpler and more basic than the PPDevice library proposed by JHR,
providing just the a essential functionality used by out format renderer.

## Files

Formats
- 

- device/device.sig  (-> DEVICE)
- device/plain-device.sml  (-> PlainDevice)
- device/ansiterm-device.sml (-> ANSITermDevice : DEVICE)


## The general model

A device is a character output device, where the character set is assumed to be fixed
width. A device may support various modes of text highlighting, like colors, bold, etc.,
which is supported by a device "style" feature.

It might also be capable of rendering things like Unicode codes to corresponding glyphs
(graphical characters), which allows it to support device "tokens".

A renderer is based on a given device (passed as a functor parameter). The renderer uses
an output stream, a line width that it gets from the device. The device can also provide a
device style type and device token type that can used to define stylemap and tokenmap
functions used to interpret logical styles and tokens that can be included in a format.


## The ANSI terminal device

The main idea is that a logical style will map to a device or "physical" style for an ANSI
terminal (ANSITermDevice.style). "Applying" a style to a terminal outstream causes
corresponding attributes of the terminal device to be set, producing a new device state.
This new state is recorded internally on a device state stack.

There is an internal stack of device states (stateStack) that allows us to keep track
of the nesting of styles, corresponding to the fact that STYLE formats can be nested.

## Cancelling text highlighting modes using a Normal text attribute.

We don't include a NORMAL font attribute in our model. What would it mean, and how
might it be used?
 
Currently there is no way to specify "normal" or "regular" font through an ANSI terminal
mode (physical style). We could add a "Normal" attribute that would specify normal font,
which could in effect "cancel" BoldFace, Dim, Underlined, and Blink attributes. The Normal
attribute would conflict with any of the other _font_ attributes (Bold, Dim, Underlined,
Blinking) and would be set by default. A device style value (terminal attribute list)
should not contain both Normal and any of Bold, Dim, Underlined, Blinking. Adding the
BoldFace attribute would then involve removing/replacing the Normal attribute, and vice
versa, adding Normal would require removing BoldFace, Dim, Underlined, and Blinking, if
any of those are present in a style (attibute list).

Alternatively one could treat Normal as also orthogonal to Dim, Underlined, and Blinking
so that Normal + {Dim | Underlined | Blinking} was possible.

## Is an outstream an ANSI terminal?

Asking if outstream is a TTY does not do much good, since even knowing that we can't query
whether an outstream is an ANSI terminal.  We must just assume that any ANSI terminal
device has an outstream associated with an ANSI terminal (or emulation).


- The terminal model

  The relevant part of the terminal state, relating to "text highlighting" of various
  kinds, is captured in a type called termState, which is a record containing a
  description of various features, like foreground color, bold face, dim, etc.

- The device (physical) style model

  A device style is a list of attributes to be set when converting to a style.
  Styles are applied in a specified "scope", which is the "body" format of a
  format of the form STYLE (style, format).
  Styles can be nested and hence can "cascade" when successively applied.
  The (device) style type is defined in the device structure for a particular
  device class (like ANSI terminals).

- The device (physical) token model.

  The motivation for the device token type is to provide a target for translating
  logical tokens into displayable form.  For instance, a logical token might be the
  lower-case Greek lambda character, while the corresponding 
