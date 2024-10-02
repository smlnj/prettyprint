(* prettyprint/src/printformat.sig *)

(* Version 10.2
 * Imports : Formatting, Device
 * Exports : signature PRINT_FORMAT
 *)

(* Printing formats *)

signature PRINT_FORMAT =
sig
    
  structure Render : RENDER

  val renderStdout : Render.stylemap * Render.tokenmap * int -> Formatting.format -> unit
        (* printing to stdOut, with line width as 2nd argument, supporing
         * ANSITerm styles through the stylemap argument *)

  val printFormat : Render.stylemap * Render.tokenmap * int -> Formatting.format -> unit
        (* print to stdOut with specified stylemap, tokenmap and line width *)

  val printFormatNL : Render.stylemap * Render.tokenmap * int -> Formatting.format -> unit
	(* like printFormat, but with a newline appended to the format *)

end (* signature PRINT_FORMAT *)
