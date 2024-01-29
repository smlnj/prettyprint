(* ansiterm-device.sml *)

structure ANSITerm_Device : DEVICE =
struct

local
  structure AT = ANSITerm  (* smlnj-lib/Util/ansi-term.sml *)
in

structure Mode = ANSITerm_Mode  (* might some day be a parameter of DEVICE signature? *)


(********* internal types *********)

(* type termState
 * This type models the ANSI terminal state with respect to the text display attributes.
 * The terminal state is a specification of which terminal attributes are turned on,
 * or in the case of the foreground and background colors, what those colors are.
 * A terminal state is either the initial default state (baseState), or is the cumulative result
 * of imposing some number of nested ANSI terminal modes. *)
type termState =
     {fg : AT.color,     (* default AT.Default - for foreground *)
      bg : AT.color,     (* default AT.Default - for background *)
      bold : bool,       (* default false *)
      dim : bool,        (* default false *)
      underlined : bool, (* default false *)
      blinking : bool}   (* default false *)

(* Note that the color denoted by AT.Default is dependent on whether we are
 * referring to foreground or background color. I.e. the interpretaion of AT.default
 * is context dependent. The default foreground and background colors _will be_ different! *)

val baseState : termState =
    {fg = AT.Default,  (* default foreground color *)
     bg = AT.default,  (* default background color *)
     bold = false,
     dim = false,
     underlined = false,
     blinking = false}

(* Note that styles, and hence the terminal mode that they translate to, can be nested 
   or layered, so the resulting state may be the product of "composing" multiple styles.
   For instance, nesting or cascading the mode. E.g. the cascading modes [BoldFace], [Dim],
   and  [Underlined], starting from the baseState, produce the state

       {fg = AT.Default, bg = AT.default,
        bold = true, dim = true, underlined = true,
        blinking = false}

   On the other hand, when cascading modes specify, say, FG color, then only the last
   (or innermost) FG attribute applies.  Layering [FG Red], [FG Green] produces the effect of
   [FG Green]. Similarly for BG styles.  See ./device-notes.txt for further discussion.
 *)


type commands = AT.style list

type stateStack = termState list ref


(******** the device type and related functions and exceptions ********)

type device =
  {outstream : TextIO.outstream,  (* outstream for an ANSI terminal (emulation) *)
   stateStack : stateStack,   (* initial value = nil *)
   lineWidth : int}  (* INVARIANT lineWidth > 0 *)
	       
fun clearOutstream (outstream : TextIO.outstream) =
    (AT.setStyle (outstream, [AT.RESET];
     TextIO.flushOut outstream)			    
		  
(* mkDevice : TextIO.outstream -> int -> device *)
fun mkDevice (outstream : TextIO.outstream) (lineWidth : int) =
    (clearOutstream outstream;
     {outstream = outstream,
      stateStack = ref nil,
      lineWidth = lineWidth})

(* resetDevice : device -> unit *)
fun resetDevice ({outstream, stateStack, ...} : device) =	
    (stateStack := nil;
     clearOutstream outstream)

(* width : device -> int *)
fun width ({lineWidth, ...}: device) = lineWidth

(* DeviceError: raised when "popping" an empty state stack in the restoreState function,
 * which is called in the renderStyled exported function. *)
exception DeviceError


(******** functions tracking the device (i.e. the terminal) state and managing the state stack *******)

(* delta : Mode.mode * termState -> commands * termState
 * layer an Mode.mode to change the current state (hd (!stateStack)) to new state, which
 * will be pushed onto the stateStack, plus commands to set the terminal to this new state *)
fun delta (mode : Mode.mode, {fg,bf,bold,dim,underlined,blinking} : termState) : commands * termState =
    let fun foo (nil, commands, fg, bg, bold, dim, underlined, blinking) =
	    (rev commands,
	     {fg = fg, bg = bg, bold = bold, dim = dim, underlined = underlined, blinking = blinking})
          | foo (ForeGround c :: rest, commands, fg, bg, bold, dim, underlined, blinking) = 
	     if c <> fg
	     then foo (rest, FG c :: commands, c, bg, bold, dim, underlined, blinking)
	     else foo (rest, commands, fg, bg, bold, dim, underlined, blinking)
          | foo (BackGround c :: rest, commands, fg, bg, bold, dim, underlined, blinking) = 
	     if c <> bg
	     then foo (rest, BG c :: commands, fg, c, bold, dim, underlined, blinking)
	     else foo (rest, commands, fg, bg, bold, dim, underlined, blinking)
          | foo (Bold :: rest, commands, fg, bg, bold, dim, underlined, blinking) = 
	     if not bold
	     then foo (rest, BF :: commands, fg, bg, true, dim, underlined, blinking)
	     else foo (rest, commands, fg, bg, bold, dim, underlined, blinking)
          | foo (Dim :: rest, commands, fg, bg, bold, dim, underlined, blinking) = 
	     if not dim
	     then foo (rest, DIM :: commands, fg, bg, bold, true, underlined, blinking)
	     else foo (rest, commands, fg, bg, bold, dim, underlined, blinking)
          | foo (Underlined :: rest, commands, fg, bg, bold, dim, underlined, blinking) = 
	     if not underlined
	     then foo (rest, UN :: commands, fg, bg, dim, true, blinking)
	     else foo (rest, commands, fg, bg, bold, dim, underlined, blinking)
          | foo (Blinking :: rest, commands, fg, bg, bold, dim, underlined, blinking) = 
	     if not blinking
	     then foo (rest, BLINK :: commands, fg, bg, bold, dim, underlined, true)
	     else foo (rest, commands, fg, bg, bold, dim, underlined, blinking)
    in foo (mode, nil, fg, bf, bold, dim, underlined, blinking)
    end
	
(* pushState : device -> Mode.mode -> unit *)
fun pushState ({outstream, stateStack} : device) (mode : Mode.mode) =
    let val (commands, newState) =
	    (case !stateStack
	      of nil => (nil, baseState))
	        | topState :: rest => delta (mode, topState))
     in stateStack := newState :: !stateStack;
        AT.setStyle (outstream, commands)  (* change terminal state correspondingly *)
    end

(* restoreState : device -> unit 
 * pop and restore and the device state from the stateStack
 * ASSERT: length stateStack >= 1 *)
fun restoreState ({outstream, stateStack} : device) : unit = 
    (case stateStack
       of nil => raise DeviceError
        | state :: rest => 
	    let val {fg, bg, bf, dim, underlined, blinking} = state
		val commands = 
		    List.concat
		      [if fg = AT.Default then nil else [AT.FG fg],
		       if gb = AT.Default then nil else [AT.BG bg],
		       if bf then [AT.BF] else nil,
		       if dim then [AT.DIM] else nil,
		       if underlined then [AT.UL] else nil,
		       if blinking then [AT.BLINK] else nil]
	     in AT.setStyle (outstream, AT.RESET :: commands);
		stateStack := rest
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

(* token : device -> T.token -> unit *)
(* output a string/character in the current style to the device *)
fun token ({outstream,...}: device) (t: T.token) = string (T.raw t)

(* flush : device -> unit *)
(* if the device is buffered, then flush any buffered output *)
fun flush ({outstream,...}: device) = TextIO.flushOut outstream

(* renderStyled : device -> M.mode * (unit -> 'r) -> 'r *)
(* 'r |-> DT.renderState *)
fun 'r renderStyled (device: device) (mode: Mode.mode, renderThunk : unit -> 'r) : 'r =
    (pushState device mode;
     renderThunk ()
       before restoreState device)

end (* top local *)
end (* structure ANSITerm_Device *)

