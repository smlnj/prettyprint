(* prettyprint/src/device.sig *)

(* signature of a device as a structure
 * Devices need to be structures to provide a polymorphic renderStyled function. *)

signature DEVICE =
sig

    val space  : int -> unit
    val indent : int -> unit
    val newline : unit -> unit
    val string : string -> unit
    val token : Token.token -> unit
    val flush : unit -> unit

    val renderStyled : Style.style * (unit -> 'a) -> 'a
      (* used to render styled formats in render-fct.sml *)

end (* signature DEVICE *)
