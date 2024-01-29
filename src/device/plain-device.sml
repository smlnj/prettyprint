(* prettyprint/src/device/device-plain.sml *)

(* Version 10.2 (see device-notes.txt) *)

(* The PlainDevice structure implements a class of devices.
 * For the plain text device class , which is the default device.
 * mkDevice takes an outstream and a line length. *)

structure Plain_Mode =
struct
  type mode = unit end
  type stylemap = string -> mode
  val nullStylemap = (fn (s: Format.style) => ())
end

structure Plain_Device : DEVICE =
struct

structure Mode = Plain_Mode

type device =
  {outstream : TextIO.outstream,  (* outstream for an ANSI terminal (emulation) *)
   lineWidth : int}  (* INVARIANT lineWidth > 0 *)

(* mkDevice : TextIO.outstream -> int -> DT.device *)
fun mkDevice (outstream : TextIO.outstream) (lineWidth: int) : device =
    {outstream = outstream, width = lineWidth}
     
fun resetDevice ({outstream, ...}: device) =
    TextIO.flushOut outstream

(* space : device -> int -> unit *)
(* output some number of spaces to the device *)
fun space ({outstream, ...}: device) (n: int) =
    TextIO.output (outstream, StringCvt.padLeft #" " n "")

(* indent : device -> int -> unit *)
(* output an indentation of the given width to the device *)
val indent = space

(* newline : device -> unit *)
(* output a new-line to the device *)
fun newline ({outstream,...}: device) = TextIO.output1 (outstream, #"\n")

(* string : device -> string -> unit *)
(* output a string/character in the current style to the device *)
fun string ({outstream,...}: device) (s: string) = TextIO.output (outstream, s)

(* token : device -> T.token -> unit *)
(* output a string/character in the current style to the device *)
fun token ({outstream,...}: device) (t: T.token) = string (T.raw t)

(* flush : device -> unit *)
(* if the device is buffered, then flush any buffered output *)
fun flush ({outstream,...}: device) = TextIO.flushOut outstream

(* renderStyled : device -> M.mode * (unit -> 'r) -> 'r *)
(* 'r |-> DT.renderState *)
fun 'r renderStyled (device: device) (mode: Mode.mode, renderThunk : unit -> 'r) : 'r =
     renderThunk ()

end (* top local *)
end (* structure Plain_Device *)
