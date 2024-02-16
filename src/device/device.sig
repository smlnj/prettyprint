(* device.sig *)

(* signature for device classes (ANSITerm, Plain)
 *   depends on: Token (src/base/token.sml)
 *)

signature DEVICE =
sig

  structure Mode :
    sig
      type mode
      type stylemap = string -> mode
      val nullStylemap : stylemap
    end

  type device
	     
  exception DeviceError

  val mkDevice : TextIO.outstream -> int -> device

  val resetDevice : device -> unit

  val width : device -> int

  val space : device -> int -> unit

  val indent : device -> int -> unit

  val newline : device -> unit

  val string : device -> string -> unit

  val token : device -> Token.token -> unit

  val flush : device -> unit

  (* 'r will instantiate to a "renderState" type *)
  (* potentially raises DeviceError *)
  val renderStyled : device -> Mode.mode * (unit -> 'r)  -> 'r

end (* signature DEVICE *)
