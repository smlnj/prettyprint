(* device.sig *)

(* signature for device classes (ANSITerm, Plain)
 *   depends on: Token (src/base/token.sml)
 *)

signature DEVICE =
sig

(* dropping device modes in favor of device styles
  structure Mode :
    sig
      type mode
      type stylemap = string -> mode
      val nullStylemap : stylemap
    end
*)

  type device
	     
  type style
  (* "physical" styles supported by a device, such as ANSI terminal. Physical styles
   * replace the former device "modes" of Version 10.1 *)

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

  (* 'r will instantiate to a "renderState" type when called in the RenderFn functor *)
  (* potentially raises DeviceError *)
  val withStyle : device -> style * (unit -> 'r)  -> 'r

end (* signature DEVICE *)
