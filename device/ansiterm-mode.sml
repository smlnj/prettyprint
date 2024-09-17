(* prettyprint/src/device/ansiterm-attr.sml *)

(* Exports a single type, "attribute" representing text display _attributes_
 * for an ANSI terminal.
 *)

structure ANSITerm_Attribute =
struct

local
  structure AT = ANSITerm
in

(* NOTE: The values of AT.style denote attribute _transition commands_ rather than
   attributes themselves. *)

(* type attribute
 * Attributes are the terminal text attributes per se, not attribute transition commands.
 * Hence analogues of the ANSITerm.style values RESET, NORMAL, UL_OFF, REV_OFF, or REV
 * are not included in the attribute type. We are thus restricting ourselves to the
 * attributes ForeGround (color), BackGround (color), BoldFace, Dim, Underlined, and
 * Blinkiing. We think of the last four of these as text highlighting attributes, and
 * they are treated as additive (or cumulative) with respect to nesting of modes.
 * - AT.REV is an attribute-setting command affecting FG and BG, not an attribute.
 * - AT.INVIS is deemed not to be a useful attribute and hence is not relevant to
 *   prettyprinting. If a formatter wants to suppress printing of some part of the data
 *   being prettyprinted, this can be done by normal means (including it conditionally in
 *   the format), rather than by imposing an "invisible" text attribute.
 * - Use of the BLINK attribute is discouraged, since this is normally annoying, but
 *   there may be extreme circumstances (e.g. severe error warnings) where it might be
 *   appropriate.
 * QUESTION: Do we also need to deal with the _background_ color of text? Note that we
 *   are trying to avoid dealing with "modifications" of a display mode, like the effect
 *   of reversing forground and background colors, which is a modification with respect
 *   to the current display case. Controling the background color of text independently
 *   of the foreground color does not seem to be directly supported by the ANSI terminal
 *   model. We assert that our model of ANSI terminal "styles" does not need to reflect
 *   all the possible capabilities of the ANSI terminal with respect to displaying text.
 * NOTE: When we need to restore previous states, we need to know the text _attributes_.
 *   Knowing a that a state transform like REV was applied is not enough when we are 
 *   modeling the terminal text display based on _states_ rather than state transforms.
 *   Trying to model the state via sequences of transforms that have been applied is more
 *   difficult (how to we reverse RED as a transform?).
 *)

datatype attribute
  = ForeGround of AT.color  (* forground - color of text characters *)
  | BackGround of AT.color  (* background - color of text background *)
  | BoldFace                (* bold font (if terminal typeface provides one) *)
  | Dim                     (* reduced density *)
  | Underlined
  | Blinking

(* type mode (replaced by ANSITerm_Device.style)

   type mode = attribute list

 * ANSI terminal text "modes" (formerly referred to as "styles") represent elements 
 * of the "physical style" associated with an ANSI terminal.
 * Not all lists of attributes are valid modes. E.g. [FG Red, FG Green] would not be
 * allowed since these attributes are inconsistent. Thus a modes list should contain at
 * most one FG or BG attribute. The other "text highlight" attributes are "orthogonal"
 * and do not interferw with one another or with the color attributes.
 * Modes should really be _sets_ of attributes containing at most one FG attribute
 * and at most one BG (or "font") attribute.
 * Modes are not the same as the text attributes that are actually set in the 
 * state of the terminal at a given moment (this "terminal state" is represented
 * by the termState type in the ANSITerm_Device structure).
 * Modes can be "layered" or "nested", i.e. they can "cascade". Their effect
 * on the terminal text attributes is cumulative. Except for the color attributes,
 * their effects are "monotonic", in that a mode set the text highlighting
 * attributes bold, underlined, and blinking, but it cannot turn them off.
 * [We could replace "bold" with a "font" attribute that could be switched, say,
 * between bold and regular. Such a font attribute would be treated similarly to the
 * color attribute, so a mode might cause a switch from bold to regular font. But 
 * is no transition command in ANSITerm.style to make such a switch ("NORMAL" turns off
 * all highlighting attributes, and this fact deters us from replacing "bold" with a
 * switchable "font" attribute.]
 *
 * The "mode" type is not needed because it is the same as the ANSITerm device _style_
 * (see ansiterm-device.sml). A mode specifies setting some (zero or more) attributes,
 * and hence represents the "state" of the terminal with respect ot text display.
 *
 * The actual "mode" of an ANSI terminal with respect to text display is a list of
 * "compatible" display attributes. This mode is identical with the physical or
 * device "style" of a terminal (a _state_ of the terminal). 
 *)

end (* top local *)
end (* structure ANSITermMode *)
