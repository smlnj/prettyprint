(* prettyprint/src/plain-device.sml *)

(* Version 10.0 *)

(* The plain text device, which is the default device.
 * Devices are parameterized over an outstream. *)

functor PlainDeviceFn (Out: sig val outstream: TextIO.outstream end): DEVICE =
struct

local

  structure S = Style

in

  (* ====== the output functions ====== *)

  (* space : int -> unit *)
  (* output some number of spaces to the device *)
  fun space (n: int) = TextIO.output (Out.outstream, StringCvt.padLeft #" " n "")

  (* indent : int -> unit *)
  (* output an indentation of the given width to the device *)
  val indent = space

  (* newline : unit -> unit *)
  (* output a new-line to the device *)
  fun newline () = TextIO.output1 (Out.outstream, #"\n")

  (* string : string -> unit *)
  (* output a string/character in the current style to the device *)
  fun string (s: string) = TextIO.output (Out.outstream, s)

  (* token : token -> unit *)
  (* output a token (sized string) in the current style to the device *)
  fun token (tok: T.token) = string (T.toString tok)

  (* flush : unit -> unit *)
  (* if the device is buffered, then flush any buffered output *)
  fun flush () = TextIO.flushOut Out.outstream

  (* renderStyled: style * (unit -> 'a) -> 'a *)
  (* The plain text device does not implement styles, so styles are ignored. *)
  fun 'a renderStyled (style: S.style, renderThunk: unit -> 'a) : 'a =
      renderThunk ()

end (* top local *)
end (* functor DefaultDeviceFn *)
