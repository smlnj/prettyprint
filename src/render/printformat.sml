(* prettyprint/src/render/printformat.sml *)

(*** printing (i.e., rendering) formats ***)

(* Version 10.1
 * Imports: Formatting, Render, DeviceType
 * Exports: structure PrintFormat
 *)

structure PrintFormat : PRINT_FORMAT =
struct

local

  structure FG = Formatting
  structure R = Render
  structure DT = DeviceType
in 		      

(* defaultLineWidth : int *)
val defaultLineWidth = 80

(* render : DT.device -> FG.format -> unit *)
fun render (device: DT.device) (fmt: FG.format) =
    R.render device (FG.formatRep fmt)

(* renderStd : int -> FG.format -> unit *)
fun renderStd lineWidth fmt =
    render (PlainDevice.mkDevice TextIO.stdOut lineWidth) fmt

(* renderANSI : int -> FG.format -> unit *)
fun renderANSI lineWidth fmt =
    render (ANSITermDevice.mkDevice TextIO.stdOut lineWidth) fmt

(* printFormat : FG.format -> unit *)
fun printFormat format = renderStd defaultLineWidth format

(* printFormatNL : FG.format -> unit *)
fun printFormatNL format = printFormat (FG.appendNewLine format)

end (* top local *)
end (* structure PrintFormat *)
