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
 *
 * Defines: signature RENDER
 *)

signature RENDER =
sig

  type stylemap

  type device

  val render : stylemap * device -> Format.format -> unit
  (* render (styleMap, device) fmt: render fmt, using the line width and outstream
   * provided by the device, and using styleMap to translate logical styles (strings)
   * to device modes (physical styles for the device). *)

end (* signature RENDER *)
