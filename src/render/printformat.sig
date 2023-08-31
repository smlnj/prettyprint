(* prettyprint/src/render/printformat.sig *)

(* Version 10.1
 * Imports : Formatting, DeviceType
 * Exports : signature PRINT_FORMAT
 *)

signature PRINT_FORMAT =
sig
    
  (* Printing formats *)

    val render : DeviceType.device -> Formatting.format -> unit

    val renderStd : int -> Formatting.format -> unit
        (* printing to stdOut, with line width as first argument *)

    val renderANSI : int -> Formatting.format -> unit
        (* printing to stdOut, with line width as first argument, supporing ANSITerm styles *)

    val printFormat : Formatting.format -> unit
        (* print to stdOut with default lineWidth (80) *)

    val printFormatNL : Formatting.format -> unit
	(* like printFormat, but with a newline appended to the format *)

end (* signature PRINT_FORMAT *)
