(* prettyprint/src/html/render.sig *)

(* Version 7.4
 *   -- no change
 * Version 7
 *   -- no change
 * Version 6
 *   -- factored into separate Format, Render : RENDER, and NewPP : NEW_PP structures
 * Version 9.1
 *   -- RENDER is now the output signature of a RenderFn functor that takes a 
 *      DEVICE structure as argument
 * Version 10.2
 *   -- no change
 *
 * Defines: signature HTML_RENDER, the specialized signature for HTML rendering *)

signature HTML_RENDER =
sig

  val render : Formatting.format * int -> HTML.text
  (* render (fmt, lw): render fmt directly to an HTML 3 representation of type HTML.text,
   * with line width lw *)

end (* signature RENDER *)
