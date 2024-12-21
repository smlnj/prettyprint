(* prettyprint/src/device/plain-device.sml *)

(* Version 11 (see device-notes.txt) *)

(* The PlainDevice structure implements the class of plain text (default) devices.
 * Devices in this class can differ in terms of their outstream and their line width.
 *
 * This structure may be redundant. It may be possible to replace it with the equivalent(?)
 * plain text device structure from the PPDevice library assuming that structure matches our local
 * DEVICE signature. *)

structure PlainDevice : DEVICE =
struct

structure Style =
struct
  type style = unit  (* no device styles, not relevant *)
  type token = unit  (* no device tokens, not relevant *)
end (* structure Style *)
  
type device =
  {outstream : TextIO.outstream,  (* outstream for an ANSI terminal (emulation) *)
   width : int}  (* INVARIANT width > 0 *)

(* mkDevice : TextIO.outstream -> int -> DT.device *)
fun mkDevice (outstream : TextIO.outstream) (lineWidth: int) : device =
    {outstream = outstream, width = lineWidth}
     
(* resetDevice : device -> unit *)
fun resetDevice ({outstream, ...}: device) =
    TextIO.flushOut outstream

(* width : device -> int -- always nonnegative *)
fun width ({width, ...}: device) = width

exception DeviceError of string (* redundant, because it is never raised *)

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
fun token ({outstream,...}: device) (t: token) = ()

(* flush : device -> unit *)
(* if the device is buffered, then flush any buffered output *)
fun flush ({outstream,...}: device) = TextIO.flushOut outstream

(* withStyle : [All 'r] device * style * (unit -> 'r) -> 'r *)
(* When called withing the renderer, 'r instantiates to renderState *)
fun 'r withStyle (device: device, style: style, thunk : unit -> 'r) : 'r =
     thunk ()

end (* structure PlainDevice : DEVICE *)
