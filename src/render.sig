(* prettyprint/src/render/render.sig *)

(* Version 7.4
 *   -- no change
 * Version 7
 *   -- no change
 * Version 6
 *   -- factored into separate Format, Render : RENDER, and NewPP : NEW_PP structures
 * Version 9.1
 *   -- RENDER is now the output signature of a RenderFn functor that takes a 
 *      DEVICE structure as argument
 * Version 10.0
 *   -- no change
 * Version 10.1
 *   -- render takes a device and a format, with lineWidth provided by the device 
 * Version 11 [2024.09]
 *   -- types stylemap and tokenmap added
 *   -- render function takes stylemap and tokenmap parameters
 * Defines: signature RENDER
 *)

signature RENDER =
sig

  structure Device : DEVICE

  (* logical (style,token) to device (style,token) maps *)
  type stylemap
  type tokenmap

  exception RenderError  (* probably should NOT be exported *)

  val render : stylemap * tokenmap * Device.device -> Format.format -> unit
  (* render (styleMap, device) fmt: render fmt, using the line width and outstream
   * provided by the device, and using the styleMap argument to translate logical styles (strings)
   * to device modes (physical styles for the device). *)

end (* signature RENDER *)
