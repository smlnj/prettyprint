(* prettyprint/src/ansiterm-device.sml *)

structure ANSITermDevice =
  ANSITermDeviceFn (struct val outstream = TextIO.stdOut end)
