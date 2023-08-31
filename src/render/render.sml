(* prettyprint/src/render.sml *)

(* Version 7.1
 *  the Render structure
 *  -- revised measure function with measures memoized in blocks
 *
 * Version 7.4
 *  -- SEP --> BRK (separator --> break)
 *
 * Version 8.1 [2023.1.1]
 *  -- HINDENT dropped, SINDENT --> INDENT
 *
 * Version 8.4 [2023.3.1]
 *  -- simplify Break constructor names: HardLine -> Hard, SoftLine -> Soft, NullBreak -> Null
 *
 * Version 9.1 [2023.3.15]
 *  -- The render structure becomes a functor over a DEVICE parameter. The DEVICE parameter carries
 *  the lineWidth, and also the output functions, where a single output has been replaced by several:
 *  space, newline, string, token, flush. So the render function itself now takes just one argument,
 *  the format. [file name is changed from "render.sml" to "render-fct.sml"]
 *  -- The STYLE format constructor is added and is handled through a "styledFormat" function provided
 *  by the device. The device is a character-oriented output device with a mode state that corresponds to
 *  a set of device styles (BF, FG color, etc. -- see ANSITermStyle for instance). Styles are implemented
 *  by modifying the device (terminal) mode during the rendering of a styled format.
 *
 * Version 10.0 [2023.8]
 *  -- added rendering of tokens (TOKEN formats)
 *
 * Version 10.1 [2023.8]
 *  -- device as a record value (with monomorphic renderStyled component)
 *  -- single Render structure for plain and asci terminal styling
 *)

(* --------------------------------------------------------------------------------
 *  Render: the Rendering structure (for devices, like plain and ansiterm)
 *    For rendering to the HTML 3 markup language, we define an ad hoc HTMLRender structure.
 * -------------------------------------------------------------------------------- *)

structure Render : RENDER =
struct

local

  structure T = Token
  structure F = Format
  structure M = Measure
  structure DT = DeviceType

  fun error (msg: string) = (print ("PrettyPrint Error: " ^ msg); raise Fail "Render")

in

(* There is just one exported rendering function: render.
 * The flatRender function is defined and used within the render function, and is not exported. *)

val renderState0 : DT.renderState = (0, true)

(* render : format * [lineWidth]int -> unit
 *   format: format  -- the format to be rendered and printed
 *   lineWidth: int  -- the line width, assumed fixed during the rendering of the given format
 * The top-level render function decides where to conditionally break lines, and how much indentation should follow
 * each line break, based on the line space available (the difference between the currend column and the device line width).
 * In this version (Version 10.1), the render function also prints the content and formatting, using the output
 * functions provided by the device parameter. Thus rendering and printing are unified and there
 * is no intermediate "layout" structure.
 * Internal rendering functions (render1, renderBLOCK, renderABLOCK) are (roughly) renderState -> renderState.
 *)
fun render ({lineWidth, space, indent, newline, string, token, flush, renderStyled}: DT.device)
	   (format: F.format) : unit =
    let (* lineBreak : int -> unit  -- output a newline followed by an indentation of n spaces *)
	fun lineBreak n = (newline (); indent n)

	(* flatRender : format -> unit
	 *   render as though on an unbounded line (lineWidth = "infinity"), thus "flat"
	 *     (i.e. no line space pressure).
	 *   _No_ newlines are triggered, not even Hard breaks and INDENT formats, which are
	 *   rendered as a single space, like Soft line breaks.
	 *   flatRender is called once when rendering a FLAT format. *)
	fun flatRender format =
	    let (* render0: format -> DT.renderState  (* always returns RS0 *)
		 *   -- recurses over the format structure *)
		fun render0  (format: F.format): unit =
		      (case format
			 of F.EMPTY => ()
			  | F.TEXT s => string s
			  | F.TOKEN t => string (Token.raw t)
			  | F.BLOCK {elements, ...} => renderBLOCK elements
			  | F.ABLOCK {formats, ...} => renderABLOCK formats
			  | F.INDENT (_, fmt) => render0 fmt
			  | F.FLAT fmt => render0 fmt
			  | F.ALT (fmt, _) => render0 fmt   (* all formats "fit", so choose first arg *)
			  | F.STYLE (s, fmt) =>
			      ignore (renderStyled (s, fn () => (render0 fmt; renderState0))))

		(* renderBLOCK : element list -> unit *)
		and renderBLOCK nil = () (* should not happen *)
		  | renderBLOCK elements =
		      let fun renderElements nil = ()
			    | renderElements (element::rest) =
				(case element
				   of F.FMT format => (render0 format; renderElements rest)
				    | F.BRK break =>
				       (case break
					 of F.Hard    => (space 1; renderElements rest)
					  | F.Soft n  => (space n; renderElements rest)
					  | F.Space n => (space n; renderElements rest)
					  | F.Null    => renderElements rest))
		       in renderElements elements
		      end

		(* renderABLOCK : format list -> unit *)
		and renderABLOCK nil = ()  (* should not happen *)
		  | renderABLOCK formats =  (* ASSERT: not (nill formats) *)
		      let fun renderFormats nil = ()
			    | renderFormats [format] = ignore (render0 format) (* no break after last format *)
			    | renderFormats (format::rest) = (render0 format; space 1; renderFormats rest)
		       in renderFormats formats
		      end

	    in render0 format
	   end (* fun flatRender *)

        (* render1: F.format -> DT.renderState -> DT.renderState
	 * the full rendering of a single format
	 * Input renderState (cc, newlinep):
         *   cc: current column, incremented or reset after any output actions (string, space, lineBreak)
         *     If the format is the initial format of a block, or follows a newline+indent, then cc = the parent's blm
         *     (where blm ("block left margin") = the cumulative inherited indentation from containing formats,n
         *     incremented by surrounding nested INDENT constrs).n
	 *   newlinep: bool indicating whether the immediately previously rendered format or break resulted in a
	 *     newline+indent; the top-level call of render1 is treated as though it followed a newline
	 *     with 0 indent.
         * Output renderState:
	 *   cc' : int -- the current column when the render is completed
         *      (= position where next character will be printed)
	 *   newlinep' : bool -- reports whether this render1 call _ended_ with a newline+indent
	 *   -- INVARIANT: outerBlm <= cc
	 *   -- INVARIANT: we will never print to the left of the outer block's blm (outerBlm)
	 *   -- ASSERT: if newlinep is true, then cc = outerBlm *)
	fun render1  (format: F.format) (inputState as (cc: int, newlinep: bool)) : DT.renderState =
	      (case format
	         of F.EMPTY =>  (* nothing printed, cc, newlinep passed through unchanged *)
		      inputState

		  | F.TEXT s =>  (* print the string unconditionally; move cc accordingly *)
		      (string s; (cc + size s, false))

		  | F.TOKEN t =>  (* print the string unconditionally; move cc accordingly *)
		      (string (T.raw t); (cc + T.size t, false))

 		  | F.BLOCK {elements, ...} => (* establishes a new local blm = cc for the BLOCK *)
		      renderBLOCK elements inputState

		  | F.ABLOCK {formats, alignment, ...} => (* establishes a new local blm = cc for the ABLOCK *)
		      renderABLOCK alignment formats inputState

		  | F.INDENT (n, fmt) => (* soft indented block; depends on outerBlm *)
		      if newlinep  (* ASSERT: at outerBlm after newline+indent (i.e. cc = outerBlm) *)
		      then (space n;  (* cc is parent block's blm, after a newline+indent *)
			    render1 fmt (cc + n, true))
		      else render1 fmt (cc, false) (* not on new line, proceed at cc without line break *)

		  | F.FLAT format =>  (* unconditionally render the format as flat; outerBlm not relevant *)
		      (flatRender format; (cc + M.measure format, false))

		  | F.ALT (format1, format2) =>
		      if M.measure format1 <= lineWidth - cc  (* format1 fits flat *)
		      then render1 format1 inputState
		      else render1 format2 inputState

		  | F.STYLE (style, fmt) =>
		      renderStyled (style, (fn () => render1 fmt inputState)))

        (* renderBLOCK : element list -> DT.renderState -> DT.renderState
         *   rendering the elements of a BLOCK
	 *   blm will be the caller's cc *)
        and renderBLOCK elements (inputState as (blm, newlinep)) =
            let (* renderElements : element list -> DT.renderState -> DT.renderState *)
		fun renderElements nil rstate = rstate
		  | renderElements (element::rest) (rstate as (cc, newlinep)) =
		      (case element
			 of F.FMT format => renderElements rest (render1 format rstate)
			  | F.BRK break =>  (* ASSERT: rest should start with a FMT! *)
			      (case break
				 of F.Null    => renderElements rest (cc, false)
				  | F.Hard    => (lineBreak blm; renderElements rest (blm, true))
				  | F.Space n => (space n; renderElements rest (cc + n, newlinep))
				  | F.Soft n  =>
				      (case rest
					 of F.FMT format' :: rest' =>
					      if M.measure format' <= (lineWidth - cc) - n
						                      (* lineWidth - (cc + n) *)
					      then (* rendering Soft n as n spaces without a line break *)
						   (space n;
						    renderElements rest' (render1 format' (cc + n, false)))
					      else (* rendering Soft n as newline + blm indent *)
						   (lineBreak blm; renderElements rest (blm, true))
					  | _ => error "renderBLOCK 1: adjacent breaks")))
	     in renderElements elements inputState
	    end (* end renderBLOCK *)

        (* renderABLOCK : [formats]format list * alignment * [blm]int * [newlinep]bool -> int * bool
	 * Render the contents of an aligned block with the effects of the virtual break and bindent.
         * The first argument is the component formats of the block being rendered;
	 * The second argument is the alignment, which determines the virtual breaks separating the formats
         * The input renderState (blm, newlinep) is:
	 *   blm: int -- the current column at block entry, which defines this new block's blm
         *   newlinep: bool -- flag indicating whether this block follows a newline+indent
	 * Rendering the new block does not need to use the partent's blm, so no blm argument is passed.
	 * The special case of an "empty" ABLOCK, containing no formats, renders as the empty format,
	 * producing no output; But this case should not occur, because (alignedBlock _ nil)
	 * should yield EMPTY, not an ABLOCK with null formats list. *)
        and renderABLOCK alignment formats (inputState as (blm, newlinep)) =
	      let (* renderFormats : format list -> DT.renderState -> DT.renderState
		   * Arguments:
		   *   formats : format list -- the formats constituting the body (components) of the block
		   *   (blm, newlinep) : renderstate, where
		   *     blm : int -- the current column when renderBLOCK was called, which becomes the block's blm
		   *     newlinep : bool -- flag indicating whether following immediately after a newline+indent
		   * ASSERT: not (null formats) *)
		  fun renderFormats (format::rest) ((cc, newlinep): DT.renderState) : DT.renderState =
			let (* renderBreak : [cc]int * [m]int -> DT.renderState  -- m is the measure of following format *)
			    val renderBreak : (int * int) -> DT.renderState =
				  (case alignment
				     of F.C => (fn (cc, m) => (cc, false))
				      | F.H => (fn (cc, m) => (space 1; (cc+1, false)))
				      | F.V => (fn (cc, m) => (lineBreak blm; (blm, true)))
				      | F.P =>  (* virtual break is Soft 1 *)
					  (fn (cc, m) =>
					      if m <= (lineWidth - cc) - 1  (* conditional on m *)
					      then (space 1; (cc+1, false)) (* no line break, print 1 space *)
					      else (lineBreak blm; (blm, true))))  (* triggered line break *)

                            (* renderTail : format list -> DT.renderState *)
			    fun renderTail nil rstate = rstate (* when we've rendered all the formats *)
			      | renderTail (format :: rest) (cc, _) =  (* newlinep argument not used in this case! *)
				  let val rstate1 = renderBreak (cc, M.measure format)
				   in renderTail rest (render1 format rstate1)  (* render format, then render the rest *)
				  end

			 in renderTail rest (render1 format (cc, newlinep)) (* render format, then render the rest *)
			end
		    | renderFormats nil renderState = renderState

	       in renderFormats formats inputState
	      end (* fun renderABLOCK *)

    in (* the initial "context" of a render is at the beginning of an outermost virtual block: newlinep is true, cc = 0 *)
	(render1 format renderState0; flush ())  (* final renderState is discarded and output is flushed (redundant?) *)
   end (* fun render *)

end (* top local *)
end (* structure Render *)

(* NOTES:

1. All newlines are followed by the cumulative block indentation, which may be 0, produced by the lineBreak output function.

2. blm (block left margin) values represent the cummulative effect of the indentations of containing blocks.
   -- the blm of an "in-line" (or non-indented) block is set to the current column (cc) at the entry to the block
   -- the blm of an indented block is set to the parent block's blm incremented by the block's indentation (if triggered)

3. [Q: Edge case] Should INDENT (n, EMPTY) produce nothing (since the format has no content) or should it produce
   a line break (newline+indent) and nothing else?

4. [Q1] Does rendering a format ever end with a final newline+indent?
   [Q2] Is BLOCK {elements = [BRK Hard], ...} a valid block? If so, it "ends with a newline".
   [Q3] Is vblock [empty, BRK Hard, empty] (or similar BLOCK formats) treated as equavalent to a newline?

A1: Yes?
We only emit a newline+indent at a Hard or triggered Soft break,
but a normal block will not end with a (virtual) break so "normal" blocks do not end with a newline+indent.

Another possibility is at an indented, but empty, block (e.g. INDENT (3, emtpy)), which could
appear on its own or as the last format in a block.  But we can introduce the reduction

   INDENT (n,EMPTY) --> EMPTY

in which case an indented empty format turns into the empty format and the indentation is discarded
(i.e., does not occur).

Also, a basic block whose last element is a BRK (Hard) is possible. Such a block would end with
a newline+indent (to its blm?).

Should this be disallowed?  Probably not, until we find that it is causing problems or confusion for users.
It could be useful, for instance for producing top-level formats that end with a newline (e.g., printFormatNL).

--------------
5. Block Left Margin (blm: int)
 The blm is the "left margin" of a block assigned to it by the renderer.  No character
 in the block should be printed to the left of this margin.

 The blm of a nonindenting block is defined as the cc at the point where that block is rendered.
 The blm of an indenting block is the parent block's blm + the specified incremental indentation (except
 for the (unnecessary) case where an intented format is indented: (INDENT (n, (INDENT (m, format)).
 The blm only changes when entering an indented block (blm = cc + n = blm_parent + n).
 Columns are counted from zero, so if the blm is (column) 3, then the indentation is 3.

--------------
6. RenderFn functor version:

This takes a device, which provides (a lineWidth and) output operations (space, newline, string, flush.).
The device also contains a hidden output stream (TextIO.outstream), which will typically be TextIO.output.

Q: should the output stream be visible, settable? Perhaps a parameter somewhere?
The problem is that for the ANSITERM device, the output stream, assumed to be an ANSI terminal stream,
also carries the "device state" in the form of various ANSI terminal modes: FG color, BF, etc.)  This means
that the output stream must be known to the device, which it may use for its internal purposes (e.g. in
the definition of "styledRender").

*)
