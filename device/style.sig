(* device/style.sig *)
(* signature for a style structure used with device structure *)

signature STYLE =
sig
    
  type style (* "physical", or "device", style *)
  (* The device "physical styles", e.g. bold, red, or combinations thereof.
   * [This takes the place of the former Mode substructure and its Mode.mode type.]
   * It looks like a device style is meant to be a list of physical modes or text
   * attributes (e.g. ANSITerm Bold) associated with a device class, like ANSI terminal.
   * For rendering, a stylemap may be needed, where a stylemap is a function mapping
   * from a "logical style" type (normally string or atom) to a device style (e.g.
   * mapping "keyword" to "[Bold]"). To make it possible to define such stylemaps,
   * a particular device structure may export some device style constants that would
   * correspond with the logical styles used in formats that are to be rendered to
   * that device.
   *)

  type token (* "physical", or "device", token *)
   (* (1) The members of this type are meant to contain (possibly) device-dependent
    *     encodings of "logical" tokens.
    *     For instance, a logical token might be ("lambda",1), which would map, via a
    *     tokenmap function, to a device token (defined in, say, ANSITerm_Device) that
    *     is a unicode encoding of the greek lambda character (e.g., as an UTF-8 encoded
    *     ascii string).
    * (2) if the token type is defined in a device, how can tokens appear in formats?
    *     The Format.format type uses a Token.token type that is independent of devices,
    *     and is defined in the Token structure. This is known as a "logical" token.
    *     These "logical" tokens are mapped to device-specific "physical" token values
    *     via a tokenmap function that is user defined based on a concrete "device"
    *     structure that provides additional interface elements (say lambda: token).
    * (3) The "physical" size of a device token, i.e. the number of spaces it takes up
    *     when output, should agree with the size attribute of the logical token that
    *     it is derived from via a tokenmap parameter supplied to the render function.
    * (4) Typically, the device token type will be string, as in
    *     PPDevice/src/ansi-term-dev.sml.
    *)

end (* signature STYLE *)
