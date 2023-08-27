(* prettyprint/src/plain-device.sml *)

structure PlainDevice =
  PlainDeviceFn (struct val outstream = TextIO.stdOut end)
