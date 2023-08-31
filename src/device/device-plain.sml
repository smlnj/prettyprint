(* prettyprint/src/device/device-plain.sml *)

(* Version 10.0 *)

(* The plain text device, which is the default device.
 * mkDevice takes an outstream and a line length. *)

structure PlainDevice :
  sig
    val mkDevice : TextIO.outstream -> int -> DeviceType.device
  end =

struct

local

  structure S = Style
  structure T = Token
  structure DT = DeviceType

in

(* mkDevice : TextIO.outstream -> int -> DT.device *)
fun mkDevice (outstream : TextIO.outstream) (lineWidth: int) : DT.device =
    let (* space : int -> unit *)
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
	fun token (tok: T.token) = string (T.raw tok)

	(* flush : unit -> unit *)
	(* if the device is buffered, then flush any buffered output *)
	fun flush () = TextIO.flushOut outstream

	(* renderStyled: style * (unit -> DT.renderState) -> DT.renderState *)
	(* The plain text device does not implement styles, so styles are ignored. *)
	fun 'a renderStyled (style: S.style, renderThunk: unit -> DT.renderState) : DT.renderState =
	    renderThunk ()

     in {lineWidth = lineWidth,
	 space = space,
	 indent = indent,
	 newline = newline,
	 string = string,
	 token = token,
	 flush = flush,
	 renderStyled = renderStyled}
    end

end (* top local *)
end (* structure PlainDevice *)
