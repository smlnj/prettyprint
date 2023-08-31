(* prettyprint/src/ansiterm/device.sml *)

(* The structure ANSITermDevice providec a mkDevice function for an ANSI terminal used
 * for output. *)

structure ANSITermDevice :
  sig
    val mkDevice : TextIO.outstream -> int -> DeviceType.device
  end =

struct

local

  structure AT = ANSITerm      (* SMLNJ-LIB/Util: provides type ANSITermStyle *)
  structure AS = ANSITermStyle (* ansiterm/ansiterm-style.sml *)
  structure T = Token
  structure DT = DeviceType

in

(* mkDevice : TextIO.outstream -> int -> DT.device *)
fun mkDevice (outstream : TextIO.outstream) (lineWidth: int) : DT.device =
    let (* space : int -> unit *)
	(* output some number of spaces to the device *)
	fun space (n: int) = TextIO.output (outstream, StringCvt.padLeft #" " n "")

	(* indent : int -> unit *)
	(* output an indentation of the given width to the device *)
	val indent = space

	(* newline : unit -> unit *)
	(* output a new-line to the device *)
	fun newline () = TextIO.output1 (outstream, #"\n")

	(* string : string -> unit *)
	(* output a string/character in the current style to the device *)
	fun string (s: string) = TextIO.output (outstream, s)

	(* token : T.token -> unit *)
	(* output a string/character in the current style to the device *)
	fun token (t: T.token) = string (T.raw t)

	(* flush : unit -> unit *)
	(* if the device is buffered, then flush any buffered output *)
	fun flush () = TextIO.flushOut outstream


	(* ====== terminal modes and styles ====== *)

	(* setTermMode : AT.style -> unit *)
	fun setTermMode cmd =
	    TextIO.output (outstream, AT.toString [cmd])

	(* terminal mode state: models state of the output device *)
	val fg : AT.color ref = ref AT.Black  (* foreground color, default black *)
	val bg : AT.color ref = ref AT.White  (* background color, default white *)
	val bf : bool ref = ref false   (* boldface? default false *)
	val ul : bool ref = ref false   (* underlining? default false *)
	val bl : bool ref = ref false   (* blinkiing? default false *)
	val dm : bool ref = ref false   (* dim? default false *)
	val iv : bool ref = ref false   (* invisible? default false *)
	val rv : bool ref = ref false   (* fg/bg reversal *)

	(* backup terminal mode state: used to revert the terminal after a resetTerm *)
	val bu_fg : AT.color ref = ref AT.Black  (* foreground color, default black *)
	val bu_bg : AT.color ref = ref AT.White  (* background color, default white *)
	val bu_bf : bool ref = ref false   (* boldface? default false *)
	val bu_ul : bool ref = ref false   (* underlining? default false *)
	val bu_bl : bool ref = ref false   (* blinkiing? default false *)
	val bu_dm : bool ref = ref false   (* dim? default false *)
	val bu_iv : bool ref = ref false   (* invisible? default false *)
	val bu_rv : bool ref = ref false   (* fg/bg reversed? default false *)

	(* defaultTerm : unit -> bool *)
	(* output device is in the default terminal mode *)
	fun defaultTerm () =
	    (!fg = AT.Black andalso !bg = AT.White andalso
	     not (!bf) andalso not (!ul) andalso not (!bl) andalso
	     not (!dm) andalso not (!iv) andalso not (!rv))

	(* resetTerm : unit -> unit *)
	(* resets terminal modes to defaults while backing up the existing mode settings *)			   
	fun resetTerm () = 
	    (bu_fg := !fg; fg := AT.Black;
	     bu_bg := !bg; bg := AT.White;
	     bu_bf := !bf; bf := false;
	     bu_ul := !ul; ul := false;
	     bu_bl := !bl; bl := false;
	     bu_dm := !dm; dm := false;
	     bu_iv := !iv; iv := false;
	     bu_rv := !rv; rv := false;
	     setTermMode AT.RESET)

	(* revertTerm : unit -> unit *)
	(* reverts the terminal mode settings to the ones stored in the backup mode state *)
	fun revertTerm () =
	    (if !fg <> !bu_fg then (fg := !bu_fg; setTermMode (AT.FG (!fg))) else ();
	     if !bg <> !bu_bg then (bg := !bu_bg; setTermMode (AT.BG (!bg))) else ();
	     (case (!bf, !bu_bf)
	       of (true, false) => setTermMode AT.NORMAL
		| (false, true) => setTermMode AT.BF
		| _ => ());
	     (case (!dm, !bu_dm)
	       of (true, false) => setTermMode AT.NORMAL
		| (false, true) => setTermMode AT.DIM
		| _ => ());
	     (case (!ul, !bu_ul)
	       of (true, false) => setTermMode AT.UL_OFF
		| (false, true) => setTermMode AT.UL
		| _ => ());
	     (case (!bl, !bu_bl)
	       of (true, false) => setTermMode AT.BLINK_OFF
		| (false, true) => setTermMode AT.BLINK
		| _ => ());
	     (case (!rv, !bu_rv)
	       of (true, false) => setTermMode AT.REV_OFF
		| (false, true) => setTermMode AT.REV
		| _ => ());
	     (case (!bf, !bu_bf)
	       of (true, false) => setTermMode AT.INVIS_OFF
		| (false, true) => setTermMode AT.INVIS
		| _ => ()))

	(* applyStyle : style -> (unit -> unit) option *)
	(* sets style mode of the ANSI term output device,
	 * returns corresponding reversion function when mode was changed. *)
	fun applyStyle (style: AS.ansiTermStyle)  : (unit -> unit) option =
	    case style
	      of AS.FG new_fg =>
		   if not (!fg = new_fg)
		   then (* changing foreground color *)
			let val old_fg = !fg
			 in fg := new_fg; setTermMode (AT.FG new_fg);
			    SOME (fn () => (fg := old_fg; setTermMode (AT.FG old_fg)))
			end
		   else NONE
	       | AS.BG new_bg =>
		   if not (!bg = new_bg)
		   then (* changing background color *)
			let val old_bg = !bg
			 in bg := new_bg; setTermMode (AT.BG new_bg);
			    SOME (fn () => (fg := old_bg; setTermMode (AT.BG old_bg)))
			end
		   else NONE
	       | AS.BF => (* not orthogonal, cancels DIM as well as BF *)
		   if not (!bf)
		   then (bf := true; setTermMode AT.BF;
			 SOME (fn () => (bf := false; dm := false; setTermMode AT.NORMAL)))
		   else NONE
	       | AS.DM => (* not orthogonal, cancels BF as well as DM *)
		   if not (!dm)
		   then (dm := true; setTermMode AT.DIM;
			 SOME (fn () => (dm := false; bf := false; setTermMode AT.NORMAL)))
		   else NONE
	       | AS.UL =>
		   if not (!ul)
		   then (ul := true; setTermMode AT.UL;
			 SOME (fn () => (bf := false; setTermMode AT.UL_OFF)))
		   else NONE
	       | AS.BL =>
		   if not (!bl)
		   then (bl := true; setTermMode AT.BLINK;
			 SOME (fn () => (bf := false; setTermMode AT.BLINK_OFF)))
		   else NONE
	       | AS.RV =>
		   if not (!rv)
		   then (iv := true; setTermMode AT.REV;
			 SOME (fn () => (bf := false; setTermMode AT.REV_OFF)))
		   else NONE
	       | AS.IV =>
		   if not (!iv)
		   then (iv := true; setTermMode AT.INVIS;
			 SOME (fn () => (bf := false; setTermMode AT.INVIS_OFF)))
		   else NONE
	       | AS.NOSTYLE =>
		   if defaultTerm ()
		   then (resetTerm ();
			 SOME (fn () => revertTerm ()))
		   else NONE

	(* renderStyled : Style.style * (unit -> DT.renderState) -> DT.renderState *)
	fun renderStyled (style: Style.style, renderFormat : unit -> DT.renderState) : DT.renderState =
	    let val post = applyStyle (AS.styleToAnsiTermStyle style)
	     in renderFormat () before
		(case post
		   of NONE => ()
		    | SOME reset => reset ())
	    end

     in {lineWidth = lineWidth,
	 space = space,
	 indent = indent,
	 newline = newline,
	 string = string,
	 token = token,
	 flush = flush,
	 renderStyled = renderStyled}

    end (* fun mkDevice *)

end (* top local *)
end (* structure ANSITermDevice *)
