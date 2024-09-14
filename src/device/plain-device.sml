(* prettyprint/src/device/device-plain.sml *)

(* Version 10.2 (see device-notes.txt) *)

(* The PlainDevice structure implements a class of devices.
 * For the plain text device class , which is the default device.
 * mkDevice takes an outstream and a line length. *)

structure Plain_Device : DEVICE =
struct

type device =
  {outstream : TextIO.outstream,  (* outstream for an ANSI terminal (emulation) *)
   width : int}  (* INVARIANT width > 0 *)

type style = unit  (* no device styles *)
type token = unit  (* no device tokens *)

(* mkDevice : TextIO.outstream -> int -> DT.device *)
fun mkDevice (outstream : TextIO.outstream) (lineWidth: int) : device =
    {outstream = outstream, width = lineWidth}
     
(* resetDevice : device -> unit *)
fun resetDevice ({outstream, ...}: device) =
    TextIO.flushOut outstream

(* width : device -> int -- always nonnegative *)
fun width ({width, ...}: device) = width

exception DeviceError (* redundant in this case because it is never raised *)

(* space : device -> int -> unit *)
(* output some number of spaces to the device *)
fun space ({outstream, ...}: device) (n: int) =
    TextIO.output (outstream, StringCvt.padLeft #" " n "")

(* indent : device -> int -> unit *)
(* output an indentation of the given number of spaces *)
val indent = space

(* newline : device -> unit *)
(* output a new-line to the device *)
fun newline ({outstream,...}: device) = TextIO.output1 (outstream, #"\n")

(* string : device -> string -> unit *)
(* output a string/character in the current style to the device *)
fun string ({outstream,...}: device) (s: string) = TextIO.output (outstream, s)

(* token : device -> token -> unit *)
(* output a string/character in the current style to the device *)
fun token ({outstream,...}: device) (t: Token.token) = ()

(* flush : device -> unit *)
(* if the device is buffered, then flush any buffered output *)
fun flush ({outstream,...}: device) = TextIO.flushOut outstream

(* withStyle : device -> M.mode * (unit -> 'r) -> 'r *)
(* 'r |-> DT.renderState *)
fun 'r withStyle (device: device) (mode: Mode.mode, thunk : unit -> 'r) : 'r =
     thunk ()

end (* structure Plain_Device *)
