(* ansiterm-device.sml *)

(* This structure may be redundant. It may be possible to replace it with the equivalent(?)
 * ANSITerm structure from the PPDevice library assuming that structure matches our local
 * DEVICE signature. *)

structure ANSITerm_Device : DEVICE =
struct

local (* imported structures *)

  structure AT = ANSITerm
    (* Basis Library structure proving commands for setting state of ANSI terminals,
     * smlnj-lib/Util/ansi-term.sml *)

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

(* A _device_ style is a list of ANSITerm attributes. (same as former ANSITerm_Mode.mode)
 * This is interpreted as a "state delta" to be applied to termStates as defined below.
 *)
type style = attribute list

(* A device token is a string, perhaps including UTF-8 code sequences that can be interpreted
 * by the terminal. *)
type token = string

(********* internal types *********)

(* type termState
 * This type models the ANSI terminal state with respect to the text display attributes.
 * The terminal state is a specification of which terminal attributes are turned on,
 * or in the case of the foreground and background colors, what those colors are.
 * A terminal state is either the initial default state (defaultState), or is the
 * cumulative result of applying some number of nested styles.
 * The bg field could be left out, since we have no way to control (modify) the
 * background color through styles.
 *)
type termState =
     {fg : AT.color,     (* default AT.Default - for foreground *)
      bg : AT.color,     (* default AT.Default - for background, never changed *)
      bold : bool,       (* default false *)
      dim : bool,        (* default false *)
      underlined : bool, (* default false *)
      blinking : bool}   (* default false *)

(* NOTES: 
 * (1) The color denoted by AT.Default is dependent on whether we are
 * referring to foreground or background color. I.e. the interpretaion of AT.default
 * is context dependent. The default foreground and background colors _will be_ different
 * as interpreted by the terminal, even though they are both represented by the same
 * value, AT.Default!
 *)

val defaultState : termState =
    {fg = AT.Default,  (* default foreground color *)
     bg = AT.Default,  (* default background color, different from fg color *)
     bold = false,
     dim = false,
     underlined = false,
     blinking = false}

(* NOTE: Styles can be nested or layered, so a tate may be the product of "composing"
   multiple styles. For instance, nesting or cascading the styles [BoldFace], [Dim],
   and [Underlined], starting from the defaultState, produce the state

       {fg = AT.Default, bg = AT.default,
        bold = true, dim = true, underlined = true,
        blinking = false}

   On the other hand, when cascading modes specify, say, FG color, then only the last
   (i.e. _innermost_) FG attribute has effect. Layering [FG Red], [FG Green] produces
   the the same effect as [FG Green]. Similarly for BG styles.
   See ./device-notes.txt for further discussion.
 *)

type commands = AT.style list
  (* an AT.style is actually an attribute transition command *)

type stateStack = termState list ref
  (* INVARIANT: this should always contain a non-empty list *)

(******** the device type and related functions and exceptions ********)

type device =
  {outstream : TextIO.outstream,  (* outstream for an ANSI terminal (emulation) *)
   stateStack : stateStack,   (* initial value = nil (or [defaultState]?) *)
   lineWidth : int}  (* INVARIANT lineWidth > 0 *)
	       
fun clearOutstream (outstream : TextIO.outstream) =
    (TextIO.flushOut outstream;           (* clearing any buffered output *)
     AT.setStyle (outstream, [AT.RESET])  (* setting terminal state to defaultState *)
		  
(* mkDevice : TextIO.outstream -> int -> device *)
fun mkDevice (outstream : TextIO.outstream) (lineWidth : int) =
    (clearOutstream outstream;
     {outstream = outstream,
      stateStack = ref [defaultState],  (* Initial stateStack contains just defaultState *)
      lineWidth = lineWidth})

(* resetDevice : device -> unit *)
fun resetDevice ({outstream, stateStack, ...} : device) =	
    (stateStack := [defaultState];
     clearOutstream outstream)

(* width : device -> int *)
fun width ({lineWidth, ...}: device) = lineWidth

(* DeviceError: raised when "popping" an empty state stack in the restoreState function,
 * which is called in the exported withStyle function. *)
exception DeviceError of string


(** functions tracking the device (i.e. the terminal) state and managing the state stack **)

(* delta : style * termState -> commands * termState
 * apply style to change the current terminal state (hd (!stateStack)) to new state, which
 * will be pushed onto the stateStack, plus a list of commands to set the terminal to
 * this new state *)
fun delta (style : style, {fg,bg,bold,dim,underlined,blinking} : termState) : commands * termState =
    let fun foo (nil, commands, fg, bg, bold, dim, underlined, blinking) =
	    (rev commands,
	     {fg = fg, bg = bg, bold = bold, dim = dim, underlined = underlined, blinking = blinking})
          | foo (TA.ForeGround c :: rest, commands, fg, bg, bold, dim, underlined, blinking) = 
	     if c <> fg
	     then foo (rest, AT.FG c :: commands, c, bg, bold, dim, underlined, blinking)
	     else foo (rest, commands, fg, bg, bold, dim, underlined, blinking)
          | foo (TA.BackGround c :: rest, commands, fg, bg, bold, dim, underlined, blinking) = 
	     if c <> bg
	     then foo (rest, AT.BG c :: commands, fg, c, bold, dim, underlined, blinking)
	     else foo (rest, commands, fg, bg, bold, dim, underlined, blinking)
          | foo (TA.BoldFace :: rest, commands, fg, bg, bold, dim, underlined, blinking) = 
	     if not bold
	     then foo (rest, AT.BF :: commands, fg, bg, true, dim, underlined, blinking)
	     else foo (rest, commands, fg, bg, bold, dim, underlined, blinking)
          | foo (TA.Dim :: rest, commands, fg, bg, bold, dim, underlined, blinking) = 
	     if not dim
	     then foo (rest, AT.DIM :: commands, fg, bg, bold, true, underlined, blinking)
	     else foo (rest, commands, fg, bg, bold, dim, underlined, blinking)
          | foo (TA.Underlined :: rest, commands, fg, bg, bold, dim, underlined, blinking) = 
	     if not underlined
	     then foo (rest, AT.UL :: commands, fg, bg, bold, dim, true, blinking)
	     else foo (rest, commands, fg, bg, bold, dim, underlined, blinking)
          | foo (TA.Blinking :: rest, commands, fg, bg, bold, dim, underlined, blinking) = 
	     if not blinking
	     then foo (rest, AT.BLINK :: commands, fg, bg, bold, dim, underlined, true)
	     else foo (rest, commands, fg, bg, bold, dim, underlined, blinking)
     in foo (mode, nil, fg, bg, bold, dim, underlined, blinking)
    end
	
(* pushState : device -> style -> unit *)
fun pushState ({outstream, stateStack, ...} : device) (style : style) : unit =
    let val (commands, newState) =
	    (case !stateStack
	      of nil => raise DeviceError "pushState"
	        | topState :: rest => delta (style, topState))
     in stateStack := newState :: !stateStack; (* push the new state onto the state stack *)
        AT.setStyle (outstream, commands)  (* modify terminal state correspondingly *)
    end

(* restoreState : device -> unit 
 * pop and restore and the device state from the stateStack
 * ASSERT: length stateStack >= 1 *)
fun restoreState ({outstream, stateStack, ...} : device) : unit = 
    (case !stateStack
       of nil => raise DeviceError "restoreState" (* should not happen! *)
        | state :: rest => (* state is the state to restor terminal to *)
	    let val {fg, bg, bold, dim, underlined, blinking} = state
		val commands = 
		    List.concat
		      [[AT.RESET],
		       if fg = AT.Default then nil else [AT.FG fg],
		       if bg = AT.Default then nil else [AT.BG bg],
		       if bold then [AT.BF] else nil,
		       if dim then [AT.DIM] else nil,
		       if underlined then [AT.UL] else nil,
		       if blinking then [AT.BLINK] else nil]
	     in AT.setStyle (outstream, commands);
		stateStack := rest (* pop the state that was restored *)
	    end)


(******** the output functions operating on devices *******)

(* space : device -> int -> unit *)
(* output some number of spaces to the device *)
fun space ({outstream, ...}: device) (n: int) =
    TextIO.output (outstream, StringCvt.padLeft #" " n "")

(* indent : device -> int -> unit *)
(* output an indentation of the given width to the device *)
val indent = space

(* newline : device -> unit *)
(* output a new-line to the device *)
fun newline ({outstream,...}: device) = TextIO.output1 (outstream, #"\n")

(* string : device -> string -> unit *)
(* output a string/character in the current style to the device *)
fun string ({outstream,...}: device) (s: string) = TextIO.output (outstream, s)

(* token : device -> token -> unit *)
(* output a string/character in the current style to the device *)
fun token ({outstream,...}: device) (t: token) = TextIO.output (outstream, t)

(* flush : device -> unit *)
(* if the device is buffered, then flush any buffered output *)
fun flush ({outstream,...}: device) = TextIO.flushOut outstream

(* withStyle : device -> M.mode * (unit -> 'r) -> 'r *)
(* formerly named renderStyled *)
(* When called within the renderer, 'r instantiates to DT.renderState *)
fun 'r withStyle (device: device) (style: style, renderThunk : unit -> 'r) : 'r =
    (pushState device style;
     renderThunk ()
       before restoreState device)

end (* top local *)
end (* structure ANSITerm_Device *)
