(* prettyprint/src/printformat.sig *)

(* Version 10.2
 * Imports : Formatting, Device
 * Exports : signature PRINT_FORMAT
 *)

(* Printing formats *)

signature PRINT_FORMAT =
sig
    
  structure Device: DEVICE

  structure Render : Render

  val renderStdout : Render.stylemap * Render.tokenmap * int -> Formatting.format -> unit
        (* printing to stdOut, with line width as 2nd argument, supporing
         * ANSITerm styles through the stylemap argument *)

  val printFormat : Render.stylemap -> Formatting.format -> unit
        (* print to stdOut with default lineWidth (80) *)

  val printFormatNL : Render.stylemap -> Formatting.format -> unit
	(* like printFormat, but with a newline appended to the format *)

end (* signature PRINT_FORMAT *)
