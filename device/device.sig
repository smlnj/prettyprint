(* prettyprint/src/device/device.sig *)

(* revised signature for device class structures (ANSITerm, Plain)
 *   A structure matching the PPDevice device signature will also match this signature.
 *   That is, this DEVICE signature is supposed to be a "supertype" of the PPDevice
 *   DEVICE signature.
 *)

signature STYLE =
sig
  type style
  type token	     
end (* signature STYLE *)

signature DEVICE =
sig

  structure Style : STYLE (* provides device style and token types *)

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
	     
  exception DeviceError of string

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

  val token : device -> Style.token -> unit
  (* output a device token (i.e. a "physical" token), which is normally obtained by
   * applying a tokenmap to a logical token (Token.token), and is assumed to have the
   * "physical" size (in characters) associated with that logical token. *)
  
  val flush : device -> unit
  (* if the device's output stream is buffered, then flush any buffered output *)

  val withStyle : device * Style.style * (unit -> 'r)  -> 'r
  (* execute a function, assumed to be a rendering function thunk, with the
   * device style set as specified. 
   * potentially raises DeviceError
   * NOTE: The type variable 'r will typically instantiate to a "renderState" type.
   *)

end (* signature DEVICE *)
