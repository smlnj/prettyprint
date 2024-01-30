(* prettyprint/src/render/printformat.sml *)

(*** printing (i.e., rendering) formats ***)

(* Version 10.1
 * Imports: Formatting, Render, DeviceType
 * Exports: structure PrintFormat
 *
 * Version 10.2.
 * Functorized PrintFormat taking a DEVICE structure, yielding PrintFormatFn.
 * Use PrintFormatFn to define two "Print" structures: PrintPlain and PrintANSI.
 *)

functor PrintFormatFn (D: DEVICE): PRINT_FORMAT =
struct

structure Device = D

structure Render = RenderFn (Device)

val defaultLineWidth = 80

(* renderStdout : Device.Mode.stylemap * int -> Formatting.format -> unit
 *   render the format with specified stylemap and width to stdout
 *)
fun renderStdout (stylemap: Device.Mode.stylemap)  (width: int) (fmt: Formatting.format) =
    Render.render (stylemap, Device.mkDevice TextIO.stdOut width) (Formatting.formatRep fmt)

(* printFormat : D.Mode.stylemap -> Formatting.format -> unit *)
fun printFormat stylemap format = renderStdout stylemap defaultLineWidth format

(* printFormatNL : D.Mode.stylemap -> Formatting.format -> unit *)
fun printFormatNL stylemap format = printFormat stylemap (Formatting.appendNewLine format)

end (* functor PrintFormatFn *)


(* Print structures for Plain device and ANSI terminal device *)

structure PrintPlain = PrintFormatFn (Plain_Device)


structure PrintANSI = PrintFormatFn (ANSITerm_Device)
				    
