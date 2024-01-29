(* device.sig *)

(* signature for device classes (ANSITerm, Plain) *)

signature DEVICE =
sig

  structure Mode :
    sig
      type mode
      type stylemap
      val nullStylemap : stylemap
    end

  type stylemap

  val nullStylemap

  type device
	     
  exception DeviceError

  val mkDevice : TextIO.outstream -> int -> device

  val resetDevice : device -> unit

  val width : device -> int

  val space : device -> int -> unit

  val indent : device -> int -> unit

  val newline : device -> unit

  val string : device -> string -> unit

  val token : device -> Format.token -> unit  (* Format.token? *)

  val flush : device -> unit

  (* 'r will instantiate to a "renderState" type *)
  (* potentially raises DeviceError *)
  val renderStyled : device -> Mode.mode * (unit -> 'r)  -> 'r

end (* signature DEVICE *)
