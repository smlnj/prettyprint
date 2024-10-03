(* PrettyPrint/src/formatting/formatting.sml *)

(* New Prettyprinter, main interface
 * Version 7:
 *   -- prettyprinter factored into Format, Measure: MEASURE, Render : RENDER,
        and NewPrettyPrint: NEW_PRETTYPRINT (NewPP : NEW_PP) structures
 *   -- memoized block flat measures
 *
 * Version 7.4:
 *   -- structure NewPP --> NewPrettyPrint
 *   -- signature NEW_PP --> NEW_PRETTYPRINT
 *   -- separator --> break, SEP --> BRK, SBLOCK --> BLOCK, sblock --> block, siblock --> iblock
 *   -- added: vHeaders and vHeaderFormats (moved from NewPPUtil)
 *   -- removed: tuple
 *
 * Version 8:
 *   -- bindent, xiblock, etc. eliminated; replaced by HINDENT, SINDENT format constructors
 *
 * Version 8.1 [2023.1.2]
 *   -- Merge HINDENT and SINDENT into a single INDENT constructor acting like SINDENT
 *   -- the breakIndent function replaces hardIndent (but breakIndent _unconditionally_ performs
 *      a line break before the indented format, so its behavior is different from hardIndent).
 *
 * Version 8.2 [2023.1.5]
 *   -- files newprettyprint.{sig,sml} renamed prettyprint.{sig,sml}
 *   -- Renamed
 *      NEW_PRETTYPRINT --> PRETTYPRINT
 *      NewPrettyPrint --> PrettyPrint
 *
 * Verion 8.3 [2023.1.6]
 *   -- Removed
 *      breakIndent
 *
 * Version 8.4 [2023.2.22]
 *   -- renamed:
 *      Hard -> Hard
 *      Soft -> Soft
 *      NullBreak -> Null
 *      tupleFormats -> tuple
 *      list -> listMap (and removed)
 *      formatSeq -> sequenceMap  (and removed)
 *      formatClosedSeq -> closedSequenceMap (and removed)
 *      vHeaders -> vHeadersMap (and removed)
 *      vHeaderFormats -> vHeaders
 *   -- removed:
 *      tuple [i.e. the function that should have been called tupleMap; tupleFormat renamed as "tuple"]
 *      binary xcat functions, replaced by calls of corresponding xblock but with lists of 2 formats:
 *      hcat [hcat (f1, f2) -> hblock [f1,f2] -> hBlock [f1,f2] in 11.0]
 *      pcat [-> pblock (-> pBlock in 11.0)]
 *      vcat [-> vblock (-> vBlock in 11.0)]
 *      ccat [-> cblock (-> cBlock in 11.0)]
 *  
 *      The map versions of various functions: (these are not used anywhere in SML/NJ?)
 *      sequenceMap
 *      closedSequenceMap
 *      listMap
 *      alignedListMap
 *      optionMap
 * 
 * Version 8.5
 *   render and printFormat functions moved to new PrintFormat structure
 *   signature PRETTYPRINT --> signature FORMATTING
 *   structure PrettyPrint --> structure Formatting
 * 
 * Version 9.1
 *   -- Added
 *      styled
 *
 * Version 10.2 [2024.1.26]
 *   Added
 *     type style = string  -- the unique type for all "logical" styles (e.g. "keyword")
 *   Uses
 *     Token (base/token.sml via base/base.cm)
 *
 *   Thus eliminating the need for the trivial Style structure.
 *
 * Version 11.0 [2024.09]
 *   See comment for Version 11 in formatting.sig or ../../CHANGELOG.md entry for Version 11.
 *)

(* Defines:
 *   structure Formatting :> FORMATTING
 *)

structure Formatting :> FORMATTING =
struct

local

  structure F = Format
  structure M = Measure
  structure T = Token

in

(* type format (= Format.format) re-exported as an "abstract" type == Format.format.
 *   Its data constructors are not exported by FORMATTING. *)
datatype format = datatype F.format

datatype alignment = datatype F.alignment
datatype element = datatype F.element
datatype break = datatype F.break

(* But we need? a coercion back to Format.format so that we can pass abstract formats to
 * functions like Render.render that need the concrete type. formatRep is the identity.
 * [DBM] I assume? that this formatRep function is now redundant given that the local
 * format type is == Format.format.  However, Formatting.format is not a concrete type
 * (i.e. it is not a datatype) because its data constructors are not exported by the
 * FORMATTING signature.
 *)
fun formatRep (fmt : F.format) : F.format = fmt

(*** the basic block building functions ***)

(* reduceFormats : format list -> format list *)
(*   filter out F.EMPTY formats from a format list *)
fun reduceFormats (formats: format list) =
    let fun notEmpty F.EMPTY = false
	  | notEmpty _ = true
     in List.filter notEmpty formats
    end

(* reduceElements : element list -> element list *)
(*   filter out FMT EMPTY elements from an element list *)
fun reduceElements (elements: F.element list) =
    let fun notEmpty (F.FMT F.EMPTY) = false
	  | notEmpty _ = true
     in List.filter notEmpty elements
    end

(* block : element list -> format
 *   Construct a BLOCK with explicit, possibly heterogeous, breaks.
 *   Returns EMPTY if the element list is null. *)
fun block elements =
    (case reduceElements elements
       of nil => F.EMPTY
	| [F.FMT fmt] => fmt  (* special blocks containing a single FMT fmt element reduce to fmt *)
        | _ => F.BLOCK {elements = elements, measure = M.measureElements elements})

(* aBlock : alignment -> format list -> format *)
(* An aligned block with no component formats reduces to EMPTY, regardless of alignment. *)
fun aBlock alignment formats =
    let val breaksize = case alignment of F.C => 0 |  _ => 1
     in case reduceFormats formats
	  of nil => F.EMPTY
	   | [fmt] => fmt
	   | formats' =>
	     F.ABLOCK {formats = formats', alignment = alignment,
		       measure = M.measureFormats (breaksize, formats')}
    end


(*** block building functions for non-indenting blocks ***)

(* constructing aligned blocks: common abbreviations *)
(* xBlock : format list -> format, for x = h, v, p, c *)
val hBlock = aBlock F.H
val vBlock = aBlock F.V
val pBlock = aBlock F.P
val cBlock = aBlock F.C

(* "conditional" formats *)

(* tryFlat : format -> format *)
fun tryFlat (fmt: format) = F.ALT (F.FLAT fmt, fmt)

(* alt : format * format -> format *)
val alt = F.ALT

(* hvBlock : format list -> format *)
fun hvBlock fmts = tryFlat (vBlock fmts)


(*** format-building utility functions for some primitive types ***)

val empty : format = F.EMPTY

(* text : string -> format *)
val text : string -> F.format = F.TEXT

(* integer : int -> format *)
fun integer (i: int) : format = text (Int.toString i)

(* string : string -> format *)
fun string (s: string) : format =
    text (String.concat ["\"", String.toString s, "\""])  (* was using PrintUtil.formatString *)

(* char : char -> format *)
fun char (c: char) = cBlock [text "#", string (Char.toString c)]

(* bool : bool -> format *)
fun bool (b: bool) = text (Bool.toString b)


(*** "punctuation" and "grouping" characters and related symbols as formats ***)

val comma : format     = text ","
val colon : format     = text ":"
val semicolon : format = text ";"
val period : format    = text "."
val equal  : format    = text "="

val lparen : format    = text "("
val rparen : format    = text ")"
val lbracket : format  = text "["
val rbracket : format  = text "]"
val lbrace : format    = text "{"
val rbrace : format    = text "}"
val langle : format    = text "<"
val rangle : format    = text ">"

(* spaces: int -> format
 * mainly for use in  aligned blocks to avoid having to resort to basic blocks and
 * the Space break *)
fun spaces (n: int) : format =
    text (StringCvt.padLeft #" " n "")

(*** wrapping or closing formats, e.g. parenthesizing a format ***)

(* enclose : {front : format, back : format} -> format -> format *)
(* tight -- no space between front, back, and fmt *)
fun enclose {front: format, back: format} fmt =
    cBlock [front, fmt, back]

(* parens : format -> format *)
val parens = enclose {front = lparen, back = rparen}

(* brackets : format -> format *)
val brackets = enclose {front = lbracket, back = rbracket}

(* braces : format -> format *)
val braces = enclose {front = lbrace, back = rbrace}

(* angleBrackets: format -> format *)
val angleBrackets = enclose {front = langle, back = rangle}

(* appendNewLine : format -> format *)
fun appendNewLine fmt = block [F.FMT fmt, F.BRK F.Hard]

(* label : string -> format -> format *)
(* labeled formats, i.e. formats preceded by a string label, a commonly occurring pattern *)
fun label (str:  string) (fmt: format) = hBlock [text str, fmt]


(*** functions for formatting sequences of formats (format lists) ***)

(* alignmentToBreak : alignment -> break
 * The virtual break associated with each alignment.
 * This is a utility function used in functions sequence and formatSeq *)
fun alignmentToBreak F.H = F.Space 1
  | alignmentToBreak F.V = F.Hard
  | alignmentToBreak F.P = F.Soft 1
  | alignmentToBreak F.C = F.Null

(* sequence : alignement -> format -> format list -> format
 *  Format a sequence of formats, specifying alignment and separator format used between elements.
 *  The second argument (sep: format) is typically a symbol (TEXT) such as comma or semicolon *)
fun sequence (alignment: F.alignment) (sep: format) (formats: format list) =
    let val separate =
	    (case alignment
	       of C => (fn elems => F.FMT sep :: elems)  (* alignment = C *)
	        | _ =>
		  let val break = alignmentToBreak alignment
		   in (fn elems => F.FMT sep :: F.BRK break :: elems)
		  end)
	fun addBreaks nil = nil
	  | addBreaks fmts =  (* fmts non-null *)
	      let fun interpolate [fmt] = [F.FMT fmt]
		    | interpolate (fmt :: rest) =  (* not (null rest) *)
			F.FMT fmt :: (separate (interpolate rest))
		    | interpolate nil = nil (* won't happen *)
	       in interpolate fmts
	      end
      in block (addBreaks formats)
     end

(* xSequence : [sep:]format -> format list -> format, x = h, v, p, c *)
val hSequence = sequence F.H
val pSequence = sequence F.P
val vSequence = sequence F.V
val cSequence = sequence F.C

(* tuple : format list -> format
 *  parenthesized, comma-separated, packed alignment sequence
 *  not really restricted to actual "tuples", just "tuple-style" formatting. Constituent formats can represent
 *  values of heterogeneous types. *)
fun tuple (formats: format list) = parens (pSequence comma formats)

(* list : format list -> format
 *  bracketed, comma-separated, packed alignment
 *  typically used for lists, but the constituent formats can represent values of heterogeneous types. *)
fun list (formats: format list) = brackets (pSequence comma formats)

fun option (formatOp: format option) =
    case formatOp
      of NONE => text "NONE"
       | SOME fmt => cBlock [text "SOME", parens fmt]

(*** vertical formatting with labels ***)

(* vSequenceLabeled : string list -> format list -> format (was vHeaders)
 * Given a labels: string list, and formats: format list,
 * vertically allign the formats with the corresponding labels prepended using hBlock.
 * If there are more labels than formats, the extra labels are ignored.
 * If there are fewer labels than formats, the last label is repeated as many times
 * as necessary to match the formats.
 * A common case is that there are just two labels, with the second being repeated,
 * if necessary.
 * The labels can be pre-justified (left or right) to make them all have the same length
 * using the justifyLeft and justifyRight functions defined below, which also guarantee
 * that the labels all have the same length after justification.
 * ASSERT: if not (null formats) then not (null labels)
 *   if the assertion fails, raises Fail
 *)

fun vSequenceLabeled (labels: string list) (formats: format list) : format =
    let fun prepend (nil, nil, acum) = rev acum
	  | prepend (nil, _, _) = raise Fail "vSequenceLabeled: no labels provided"
	  | prepend (labels as (l::nil), fmt::formats, acum) = 
	      prepend (labels, formats, label l fmt :: acum)
	  | prepend (l::labels, fmt::formats, acum) = 
	      prepend (labels, formats, label l fmt :: acum)
     in vBlock (prepend (labels, formats, nil))
    end

(* justifyRight : string list -> string list
 * pad the shorter strings in labels with spaces on the left to make all labels the same size.
 * ASSERT: All x in justifyRight labels. size x = max (map size labels). *)
fun justifyRight (labels: string list) =
    let val maxSize = foldl Int.max 0 (map size labels)
     in map (fn s => StringCvt.padLeft #" " maxSize s) labels
    end

(* justifyLeft : string list -> string list
 * pad the shorter strings in labels with spaces on the right to make all labels the same size.
 * ASSERT: All x in justifyLeft labels. size x = max (map size labels). *)
fun justifyLeft (labels: string list) =
    let val maxSize = foldl Int.max 0 (map size labels)
     in map (fn s => StringCvt.padRight #" " maxSize s) labels
    end

(*** "indenting" formats ***)

(* indent : ([n:] int) -> format -> format
 * When applied to EMPTY, produces EMPTY
 * The resulting format is soft-indented n _additional_ spaces,
 *   i.e. indents an additional n spaces iff following a line break with its indentation. *)
fun indent (n: int) (fmt: format) =
    (case fmt
       of F.EMPTY => F.EMPTY
        | _ => F.INDENT (n, fmt))

(* styled : Style.style -> format -> format *)
fun styled (style: Style.style) (format: format) = F.STYLE (style, format)

end (* top local *)
end (* structure Formatting *)

(* NOTES:

1. [DBM: 2022.10.17]
   We have sequence formating functions that act on lists of arbitrary values (of a given type),
   with a supplied formatting function for the element type, and other functions that act on lists
   of formats.

   The first sort can easily be simulated by translating the value list into a format list
   by mapping the formatter over the values.  This seems to be preferable, so the former sequencing
   functions (formatSeq, formatClosedSeq, tuple, list, alignedList) can be viewed as redundant.

2. [DBM: 2022.10.24]
   basic block and aligned blocks revised so that a block with a single format member reduces to
   that format.  This prevents trivial nesting of blocks, e.g. block(block(block(...))).

3. [DBM: 2023.3.1; V 8.4]
   basicBlock -> block, alignedBlock -> aBlock, and other renamings: see Version 8.4
   changes note at beginning of this file. Some of these changes were suggested by
   JHR. Thinking about separating the render and printing functions into a separate
   structure and possilby parameterizing wrt a "device" record that would contain printing
   functions for strings, spaces, and newlines, and possibly the lineWidth parameter [See Version 9.1].

4. [DBM: 2024.2.15; V 10.2]
   Rendering is "device-based", except for the HTML renderer. Devices do not affect "formatting",
   which is independent of rendering and requires only structures Format, Formatting.

5. [DBM: 2024.09.16; V 11.0]
   Version 11 incorporates a number of changes suggested by JHR. See the version comment in
   ./formatting.sig.  Exported type format is defined to be the same as Format.format, but is
   not "concrete" (i.e. not exported as a datatype).
*)
