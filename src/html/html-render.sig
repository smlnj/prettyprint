(* prettyprint/src/html/html-render.sig *)

(* Version 7.4
 *   -- no change
 * Version 7
 *   -- no change
 * Version 6
 *   -- factored into separate Format, Render : RENDER, and NewPP : NEW_PP structures
 * Version 9.1
 *   -- RENDER is now the output signature of a RenderFn functor that takes a 
 *      DEVICE structure as argument
 *
 * Defines: signature HTML_RENDER, the specialized signature for HTML rendering *)

signature HTML_RENDER =
sig

  val render : Format.format * int -> HTML.text
  (* render fmt: render fmt directly to an HTML 3 representation. *)

end (* signature RENDER *)
