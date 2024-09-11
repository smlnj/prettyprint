(* device-jhr.sig *)

(* compromize? signature for device class structures (ANSITerm, Plain)
 *   depends on: Token (src/base/token.sml)
 *)

signature DEVICE =
sig

  type style 
  (* The device "modes" or "physical styles", e.g. bold, red, or combinations thereof.
   * This takes the place of the former Mode substructure and its Mode.mode type.
   * Does a physical device style correspond to the former mode, or is
   * the device style a *list* of modes?  It looks like this is meant to be a list
   * of physical modes or attributes (e.g. ANSITerm Bold), whose nature is hidden.
   * For rendering, a stylemap will be needed, where a stylemap is a function mapping
   * from some "logical style" type (normally string or atom) to a device style (e.g.
   * mapping "keyword" to "[bold]"). Where is the information available (e.g. terminal modes)
   * for writing such stylemaps?
   *)

  type device
  (* This is the type of the device itself.
   * Typically this will be a record containing 
   *   - an output stream (TextIO.outstream) for actual output
   *   - "physical" line width, either as a fixed value or a mutable value (int ref)
   *   - other relevant attributes (e.g., line/text ratio? -- which is not now used in the renderer)
   *
   * Devices are assumed to have mutable state (current style, possibly line width and
   * possibly other mutable attributes).
   *
   * A device is assumed to output fixed-width characters, so measures (widths, indentation) 
   * are given by character counts.
   *)
	     
  type token 
(*    -- this is meant to be (possibly) device-dependent encodings of "logical" tokens
 *         For instance, the logical token might be ("lambda",1), which would map, via a
 *         "tokenmap" function to a device token (in, say ANSITermDevice) that is a unicode
 *         encoding of the greek lambda character (as a unicode string).
 *    -- if token is defined in a device, how can tokens appear in formats?
 *       The Format.format type uses a Token.token type that is independent of devices,
 *       and is defined in the Token structure.
 *       These "logical" tokens are mapped to device-specific "physical" token values
 *       via a tokenmap function that is user defined using a concrete "device" structure
 *       that provides additional interface elements (say lambda: token).
 *    -- Typically, the device token type is string, as in PPDevice/src/ansi-term-dev.sml?
 *    -- where is token size defined for rendering a format like Token t?
 *    -- It appears that if the token type is defined in the Device structure,
 *       then the Format and Measure structures must be functorized relative to a Device?
 *       In which case, the device needs to export a size function for tokens. 
 *       Seems to be a bad choice to have a Device define tokens.
 *)

  exception DeviceError

  val mkDevice : TextIO.outstream -> int -> device
  (* the int is the linewidth of the device, assumed fixed *)
(*
  val resetDevice : device -> unit
  (* reset the internal state of the device to appropriate defaults
   * resets internal device style to default *)
*)
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

  val token : device -> Token.token -> unit
  (* output a token, whose width may be needed for the measure function. *)

  val flush : device -> unit
  (* if the device's output stream is buffered, then flush any buffered output *)

  val withStyle : device * style * (unit -> 'r)  -> 'r
  (* execute a function, assumed to be a rendering function thunk, with the
   * device style set as specified. 
   * The type variable 'r will typically instantiate to a "renderState" type.
   * potentially raises DeviceError
   *)

end (* signature DEVICE *)
