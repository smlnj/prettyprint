(* prettyprint/src/render/device-type.sml *)

(* signature of a device as a structure
 * Devices need to be structures to provide a polymorphic renderStyled function. *)

structure DeviceType =
struct

(* renderState = (cc, newlinep)) where
 *   cc represents the "print cursor", and
 *   newlinep indicates whether we are rendering the current format immediately after a
 *     line break (a newline + indentation).
 * renderState is defined here because it is relevant to the renderStyled device function,
 *   which takes a "render thunk" returning a renderState and "forces" it.
 *)
type renderState = int * bool
			     
type device
  = {lineWidth : int,
     space  : int -> unit,
     indent : int -> unit,
     newline : unit -> unit,
     string : string -> unit,
     token : Token.token -> unit,
     flush : unit -> unit,
     renderStyled : Style.style * (unit -> renderState) -> renderState}
	(* used to render styled formats in Render.render (render/render.sml) *)

end (* structure Device *)
