(* prettyprint/src/device/device.sig *)

(* revised signature for device class structures (ANSITerm, Plain)
 *   A structure matching the PPDevice device signature will also match this signature.
 *   That is, this DEVICE signature is supposed to be a "supertype" of the PPDevice
 *   DEVICE signature.
 *)

signature DEVICE =
sig

  type device
  (* This is the type of the device itself.
   * Typically this will be a record containing 
   *   - an output stream (TextIO.outstream) for actual output
   *   - "physical" line width, either as a fixed value or a mutable value (int ref)
   *   - other relevant attributes (e.g., line/text ratio? -- which is not now used in the renderer)
   *
   * Devices are assumed to have mutable state
   *    (e.g., the current device style, possibly line width and possibly other mutable attributes).
   *    We assume that the linewidth is a constant for a given device, and cannot be updated,
   *    so we do not include a setLineWidth function for this purpose.
   *
   * A device is assumed to output fixed-width characters, so measures (widths, indentations,
   *    and token sizes) are expressed in terms of character counts.
   *)
	     
  type style (* "physical", or "device", style *)
  (* The device "physical styles", e.g. bold, red, or combinations thereof.
   * [This takes the place of the former Mode substructure and its Mode.mode type.]
   * It looks like a device style is meant to be a list of physical modes or text
   * attributes (e.g. ANSITerm Bold) associated with a device class, like ANSI terminal.
   * For rendering, a stylemap may be needed, where a stylemap is a function mapping
   * from a "logical style" type (normally string or atom) to a device style (e.g.
   * mapping "keyword" to "[Bold]"). To make it possible to define such stylemaps,
   * a particular device structure may export some device style constants that would
   * correspond with the logical styles used in formats that are to be rendered to
   * that device.
   *)

  type token (* "physical", or "device", token *)
   (* (1) The members of this type are meant to contain (possibly) device-dependent
    *     encodings of "logical" tokens.
    *     For instance, a logical token might be ("lambda",1), which would map, via a
    *     tokenmap function, to a device token (defined in, say, ANSITerm_Device) that
    *     is a unicode encoding of the greek lambda character (e.g., as an UTF-8 encoded
    *     ascii string).
    * (2) if the token type is defined in a device, how can tokens appear in formats?
    *     The Format.format type uses a Token.token type that is independent of devices,
    *     and is defined in the Token structure. This is known as a "logical" token.
    *     These "logical" tokens are mapped to device-specific "physical" token values
    *     via a tokenmap function that is user defined based on a concrete "device"
    *     structure that provides additional interface elements (say lambda: token).
    * (3) The "physical" size of a device token, i.e. the number of spaces it takes up
    *     when output, should agree with the size attribute of the logical token that
    *     it is derived from via a tokenmap parameter supplied to the render function.
    * (4) Typically, the device token type will be string, as in
    *     PPDevice/src/ansi-term-dev.sml.
    *)

  exception DeviceError

  val mkDevice : TextIO.outstream -> int -> device
  (* The int is the linewidth of the device, assumed fixed and positive.
   * Why is this curried? It is for the convenience of creating multiple devices with different
   * line widths but sharing a given outstream.  *)

  val resetDevice : device -> unit
  (* reset the internal state of the device to appropriate defaults
   * resets internal device style to a default style;
   * possibly flushes the device outstream *)

  val width : device -> int
  (* returns the (current) line width of the device *)

  val space : device -> int -> unit
  (* output the given number of spaces to the device *)

  val indent : device -> int -> unit
  (* output an indentation of the given width - number of spaces - to the device *)

  val newline : device -> unit
  (* output a new-line character to the device output stream *)

  val string : device -> string -> unit
  (* output a string in the device's current style to the device *)

  val token : device -> token -> unit
  (* output a device token (i.e. a "physical" token), which is normally obtained by
   * applying a tokenmap to a logical token (Token.token), and is assumed to have the
   * "physical" size (in characters) associated with that logical token. *)
  
  val flush : device -> unit
  (* if the device's output stream is buffered, then flush any buffered output *)

  val withStyle : device * style * (unit -> 'r)  -> 'r
  (* execute a function, assumed to be a rendering function thunk, with the
   * device style set as specified. 
   * potentially raises DeviceError
   * NOTE: The type variable 'r will typically instantiate to a "renderState" type.
   *)

end (* signature DEVICE *)
