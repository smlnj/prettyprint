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

  val render : DeviceType.device -> Format.format -> unit
  (* render device fmt: render fmt, using the device lineWidth and
   * printing to the (implicit) output stream used by the device *)

end (* signature RENDER *)
