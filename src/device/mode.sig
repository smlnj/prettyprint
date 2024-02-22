(* prettyprint/src/device/mode.sig *)

(* the mode of a device is a physical "style" for the device.
 * modes can be layered (can cascade).
 * See ANSITerm_mode: MODE (src/device/ansiterm-mode.sml) for an example.
 *)

signature MODE =
sig
  type mode
  type stylemap = string -> mode
  val nullStylemap : stylemap
end
