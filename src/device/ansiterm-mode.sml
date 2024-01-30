(* prettyprint/src/device/ansiterm-mode.sml *)

(* terminal modes for ANSI terminals *)

structure ANSITerm_Mode =
struct

local
  structure AT = ANSITerm
in

(* NOTE: The values of AT.style denote attribute _transition commands_ rather than
   attributes themselves. *)

(* type attribute
 * Attributes are the terminal text attributes per se, not attribute transition commands.
 * Hence analogues of the ANSITerm.style values RESET, NORMAL, UL_OFF, REV_OFF, or REV are not
 * included in the attribute type. We are thus restricting ourselves to the attributes
 * ForeGround (color), BackGround (color), BoldFace, Dim, Underlined, and Blinkiing. We think
 * of the last four of these as text highlighting attributes, and they are treated as additive
 * (or cumulative) with respect to nesting of modes.
 * - AT.REV is an attribute-setting command affecting FG and BG, not an attribute.
 * - AT.INVIS is deemed not to be a useful attribute and hence is not relevant to prettyprinting.
 *   If a formatter wants to suppress printing of some part of the data being prettyprinted,
 *   this can be done by normal means (including it conditionally in the format), rather than
 *   by imposing an "invisible" text attribute.
 * - Use of the BLINK attribute is discouraged, since this is normally annoying, but there 
 *   may be extreme circumstances (e.g. severe error warnings) where it might be appropriate.
 *)

datatype attribute
  = ForeGround of AT.color  (* forground - color of text characters *)
  | BackGround of AT.color  (* background - color of text background *)
  | BoldFace                (* bold font (if terminal typeface provides one) *)
  | Dim                     (* reduced density *)
  | Underlined
  | Blinking

(* type mode
 * ANSI terminal text "modes" (formerly referred to as "styles". These represent the
 * "physical styles" associated with an ANSI terminal.
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
 *)

type mode = attribute list

type stylemap = Style.style -> mode  (* = string -> mode *)

fun nullStylemap (s: Style.style) : mode = nil

end (* top local *)
end (* structure ANSITermMode *)
