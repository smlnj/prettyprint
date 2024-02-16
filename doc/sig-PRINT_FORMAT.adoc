(* prettyprint/src/render/printformat.sig *)

(* Version 10.1
 * Imports : Formatting, DeviceType
 * Exports : signature PRINT_FORMAT
 *)

signature PRINT_FORMAT =
sig
    
  structure Device: DEVICE

  (* Printing formats *)

  val renderStdout : Device.Mode.stylemap -> int -> Formatting.format -> unit
        (* printing to stdOut, with line width as 2nd argument, supporing
         * ANSITerm styles through the stylemap argument *)

  val printFormat : Device.Mode.stylemap -> Formatting.format -> unit
        (* print to stdOut with default lineWidth (80) *)

  val printFormatNL : Device.Mode.stylemap -> Formatting.format -> unit
	(* like printFormat, but with a newline appended to the format *)

end (* signature PRINT_FORMAT *)
