(* prettyprint/src/render/printformat.sml *)

(* printing (i.e., rendering) formats to the TextIO.stdOut outstream (stdOut device), 
 * with default line lenght of 80 characters.
 *)

(* imports: Device (functor parameter); Plain_Device, ANSITerm_Device. Formatting, RenderFn *)
(* exports: functor PrintFormatFn, PrintPlain, PrintANSITerm *)

(* Version 10.1
 * Imports: Formatting, Render, DeviceType
 * Exports: structure PrintFormat
 *
 * Version 10.2.
 * Functorized PrintFormat taking a DEVICE structure, yielding PrintFormatFn.
 * Use PrintFormatFn to define two "Print" structures: PrintPlain and PrintANSI.
 * 
 * Version 11.0
 * 
 *)

functor PrintFormatFn (Device: DEVICE): PRINT_FORMAT =
struct

structure Render = RenderFn (Device)

val defaultLineWidth = 80

(* renderStdout : Render.stylemap * Render.tokenmap * int -> Formatting.format -> unit
 *   render the format with specified stylemap and width to stdout
 *)
fun renderStdout (stylemap: Render.stylemap, tokenmap: Render.tokenmap, width: int)
                 (fmt: Formatting.format) =
    Render.render (stylemap, tokenmap, Device.mkDevice TextIO.stdOut width) (fmt: Formatting.format)

(* printFormat : Render.stylemap * Render.tokenmap * int -> Formatting.format -> unit *)
fun printFormat (stylemap, tokenmap, width) format =
    renderStdout (stylemap, tokenmap, width) format

(* printFormatNL : Render.stylemap * Render.tokenmap * int -> Formatting.format -> unit *)
fun printFormatNL (stylemap, tokenmap, width) format =
    printFormat (stylemap, tokenmap,  width) (Formatting.appendNewLine format)

end (* functor PrintFormatFn *)


(* Print structures for Plain device and ANSI terminal device *)

structure PrintPlain = PrintFormatFn (Plain_Device)

structure PrintANSITerm = PrintFormatFn (ANSITerm_Device)

