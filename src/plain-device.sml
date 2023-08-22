(* prettyprint/src/plain-device.sml *)

(* The plain text device, which is the default device. *)

structure PlainDevice : DEVICE =
struct

local

  structure S = Style

in

  (* a single, fixed outstream defined for this device *)
  (* should the output stream be settable, or should it be a parameter (of a mkDevice fn)? 
   * should the output functions all take an outstream as an extra argument? *)
  val outstream = TextIO.stdOut

  val lineWidth : int = 90
      (* A default line width. Is this used? Not currently. *)

  (* ====== the output functions ====== *)

  (* space : int -> unit *)
  (* output some number of spaces to the device *)
  fun space (n: int) = TextIO.output (outstream, StringCvt.padLeft #" " n "")

  (* indent : int -> unit *)
  (* output an indentation of the given width to the device *)
  val indent = space

  (* newline : unit -> unit *)
  (* output a new-line to the device *)
  fun newline () = TextIO.output1 (outstream, #"\n")

  (* string : string -> unit *)
  (* output a string/character in the current style to the device *)
  fun string (s: string) = TextIO.output (outstream, s)

  (* token : token -> unit *)
  (* output a token (sized string) in the current style to the device *)
  fun token (tok: T.token) = string (T.toString tok)

  (* flush : unit -> unit *)
  (* if the device is buffered, then flush any buffered output *)
  fun flush () = TextIO.flushOut outstream

  (* renderStyled: style * (unit -> 'a) -> 'a *)
  (* The plain text device does not implement styles, so styles are ignored. *)
  fun 'a renderStyled (style: S.style, renderThunk: unit -> 'a) : 'a =
      renderThunk ()

end (* top local *)
end (* structure DefaultDevice : DEVICE *)
