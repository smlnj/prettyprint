(* device/ansiterm-style.sml *)

(* structure ANSITermStyle:
 * This structure defines the style type for ANSI terminal devices.
 * Note that the PPDevice version of the ANSI terminal device has a quite different notion
 * of "style" based on attribute-setting _commands_ rather than on the attributes themselves.
 * So any styles needed for the PPDevice version would be defined in terms of ANSITerm.style
 * values, which represent attribute-setting commands. *)

(* Note that the structure ANSITermStyle exports both _attribute_ and _style_ types.
 * This is because we need to have access to the attribute type in order to define ANSIterm
 * styles when defining stylemap functions to be passed to a render function. *)

structure ANSITermStyle = 
struct

local (* imported structures *)

  structure AT = ANSITerm
    (* Basis Library structure providing commands for altering the state of an ANSI
     * terminal. See smlnj-lib/Util/ansi-term.sml *)

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
 * - AT.INVIS is deemed not to be a useful attribute with respect to
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

(* A _device_ style is a list of ANSITerm attributes (previously known as ANSITerm_Mode.mode)
 * This is interpreted as a "state delta" to be applied to termStates as defined below.
 *)
type style = attribute list

(* An ANSI terminal device token is a string, perhaps including UTF-8 code sequences that
 * can be interpreted by the terminal. *)

type token = string

end (* top local *)
end (* structure ANSITermStyle *)

