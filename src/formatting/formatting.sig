(* smlnj-lib/PrettyPrint/src/formatting.sig *)

(* Design principle for this interface:  Keep things simple, but not "minimal".
 * Have justifications for each included element based on actual usage. *)

(* Version 7.
 *  -- The main interface of the new Prettyprinter.
 *  -- New: memoized measure for blocks (does not alter NEW_PP signature)
 *
 * Version 7.4
 *  -- signature NEW_PP --> NEW_PRETTYPRINT
 *  -- sblock --> block; siblock --> iblock; separator --> break; SEP --> BRK
 *  -- added: vHeaders, vHeaderFormats (from NEW_PPUTIL)
 *  -- removed: tuple
 *
 * Version 8.0
 *  -- added: new format (modifier) constructors HINDENT and SINDENT
 *  -- removed: bindent type and bindent fields in blocks, xiblock functions
 *
 * Version 8.1
 *  -- Removed: hardIndent (conditionally breaks line before indented format)
 *  -- Added: breakIndent  (unconditionally breaks line before indented format)
 *
 * Version 8.2
 *  -- this file renamed prettyprint.sig
 *  -- NEW_PRETTYPRINT --> PRETTYPRINT
 *
 * Verion 8.3 [2023.1.6]
 *   -- Removed
 *      breakIndent  (didn't work, resets blm)
 *
 * Version 8.4 [2023.2.22]
 *   Some renaming and simplification, e.g. eliminating the xcat binary operations and replacing their
 *   uses with calls of the corresponding xblock function with lists of two formats.
 *   Dropping the tuple(Map) function and renaming tupleFormat to "tuple".
 *   Shortening the names of the HardLine and SoftLine break constructors to "Hard" and "Soft".
 *   Renamed (with same type):
 *      HardLine -> Hard
 *      SoftLine -> Soft
 *      NullBreak -> Null
 *      listFormats -> list
 *      tupleFormats -> tuple
 *      list -> listMap  (-> removed)
 *      formatSeq -> sequenceMap (-> removed)
 *      formatClosedSeq -> closedSequenceMap (-> removed)
 *      vHeaders -> vHeadersMap (-> removed)
 *      vHeaderFormats -> vHeaders
 *   Removed:
 *      tuple [i.e. the function that should have been called tupleMap; recycled as new name for tupleFormats]
 *      hcat [-> hblock w. 2-element list of formats]
 *      pcat [-> pblock]
 *      vcat [-> vblock]
 *      ccat [-> cblock]
 *  
 *      The map versions of various functions:
 *         (These are not used anywhere in SML/NJ and can be replaced by composing with List.map.)
 *      sequenceMap
 *      closedSequenceMap
 *      listMap
 *      alignedListMap
 *      optionMap
 *
 * Version 8.5 [2023.03.07]
 *   Renamed:
 *     PRETTYPRINT -> FORMATTING
 *     PrettyPrint -> Formatting
 *     render and printing functions, and getLineWidth moved from Formatting (PrettyPrint) to printformat.sml
 *
 * Version 10.2 [2024.02.13]
 *   Removed:
 *     setLineWidth   -- lineWidth is now a fixed attribute of a device
 *     resetLine
 *     getLineWidth
 *     render
 *     printFormat    -- moved to PRINT_FORMAT
 *     printFormatLW
 *     printFormatNL
 * 
 * Version 11 [2024.09]
 * Made some of JHR suggested changes.
 *   Changed:
 *     - xblock to xBlock, similarly xsequence -> xSequence;
 *         thus uniformly using camel case for value variables, including function names.
 *     - vHeaders -> renamed "vSequenceLabeled", with same type and label justification.
 *   Added:
 *     - langle, rangle - angle brackers or "grouping" formats  
 *     - angleBrackets - enclosing a format in angle brackets 
 *   Not Added:
 *     - Did not include the suggested "closedSequenceWithMap" or "closedSequenceWithMap" functions
 *       which are redundant, since you can get this effect by just composing one of the sequence 
 *       functions with an ordinary map over the list of values.
 *       Similar functions (ppSequence and ppClosedSequence) were provided in the (now redundant)
 *       PPUtil: PPUTIL structure in the compiler (compiler/Basics/print/pputil.s??), but
 *       in practice it was found less cumbersome to just do the mapping explicitly and then operate
 *       on the resulting format list.
 *     - vHeaders has been renamed vSequenceLabeled with the same type and label justification (left).
 *       This function could be generalized in various ways, such as by providing a list of labels
 *       matching the list of formats in order, possibly with a label justification argument
 *       (e.g. LEFT, RIGHT, NOJUST).
 *       Before adding such generalizations, we await convincing, real examples that require them.
 *     - smlOption, smlTuple, smlList - for formatting SML option, tuple, and list values
 *         We already had such functions, but named simply "option", "tuple", and "list".
 *         This is consistent with the naming of "string", "bool", "int", which assume SML
 *         primitive values. The difference is that here we are dealing with common compound values.
 *)

(* Defines: signature FORMATTING, references base structures Format, Style, and Token *)

signature FORMATTING =
sig

  (* types *)

    type format = Format.format
    (* "abstract" in Formatting in that the format data constructors are not re-exported *)

  (* break: used to separate format elements of a block
   *   space and conditional/unconditional line breaks, and a Null break for completeness *)
    datatype break
      = Hard          (* _hard_ or unconditional line break *)
      | Soft of int   (* _soft_ or conditional line break; rendered to n spaces when not triggered; n >= 0 *)
      | Space of int  (* n spaces; n >= 0; Space 0 and Null have same effect *)
      | Null          (* A default break that does nothing, i.e. neither breaks a line nor inserts spaces.
		       * This is essentially equivalent to Space 0, but included for logical "completeness",
		       * and to eliminate the need for break option in some places (alignmentToBreak). *)

    datatype alignment  (* the alignment property of "aligned" blocks *)
      = H  (* Horizontal alignment, implicit Space 1 breaks between format components, unbreakable *)
      | V  (* Vertical alignment, implicit Hard break between format components *)
      | P  (* Packed alignment, implicit Soft 1 breaks between format components *)
      | C  (* Compact, no breaks (implicit Null) between block format components, unbreakable *)

    datatype element
      = BRK of break   (* breaks are atomic and do not contain content *)
      | FMT of format

    (* coercion of abstract format back to concrete version of format so we can pass
     *  formats to the Render functions. *)
    val formatRep : format -> Format.format

  (* Basic formats and format building operations: *)

    val empty   : format           (* == EMPTY, renders as empty string, composition identity *)
    val text    : string -> format (* == TEXT format constructor *)
    val integer : int -> format    (* integer n renders as Int.toString n *)
    val string  : string -> format (* adds double quotes; previously used PrintUtil.formatString *)
    val char    : char -> format   (* c --> #"c" *)
    val bool    : bool -> format   (* true --> TEXT "true", false --> TEXT "false" *)

  (* some common SML data structures *)

    val tuple : format list -> format  (* default packed alignment, formerly tupleFormats *)
        (* formats as a tuple *)

    val list : format list -> format  (* default packed alignment, formerly listFormats *)
        (* formats as a list *)

    val option : format option -> format
        (* NONE --> "NONE", SOME fmt --> cBlock [text "SOME", parens fmt] *)

  (* block-building functions, corresponding to SBLOCK and BLOCK format data constructors *)

    val block  : element list -> format
    (* block -- the elements may include explicit breaks *)

    val aBlock : alignment -> format list -> format
    (* aBlock: building aligned blocks
     *   The alignement parameter determines the implicit break that occurs between formats in the list:
     *      H -> Space 1, P -> Soft 1, V -> Hard, C -> Null 
     *   empty argument list produces empty format,
     *   and empty format elements are "dropped", so, for example ablock [emtpy, empty] ==> empty. *)


    (* xBlock: functions (for x = p, h, v, c) for building aligned blocks with a given alignment,
     * the empty format acts like an identity element for all these format concatenation operators, in that
     * it does not contribute anything to the result, and the associated implicit breaks separating
     * empty formats from other elements are also dropped. Also, xblock [fmt] ==> fmt. *)

    val hBlock : format list -> format  (* = aBlock H *)
        (* combinds a list of formats in an H-aligned block, with an implicit single space
         * (Space 1 break) between them *)
    val pBlock : format list -> format  (* = aBlock P *)
        (* combinds a list of formats into a P-aligned (packed) block, with an implicit soft line break
         * (Soft 1) between them *)
    val vBlock : format list -> format  (* = aBlock V *)
        (* combinds a list of formats in an V-aligned block, with an implicit hard line break
         * (Hard) between them *)
    val cBlock : format list -> format   (* = aBlock C *)
        (* combinds a list of formats in a C-aligned block, with no break (or, implicitly, Null)
         * between them *)

  (* a few "punctuation" and "grouping" or "bracketing" characters *)

    val comma : format     (* text "," *)
    val colon : format     (* text ":" *)
    val semicolon : format (* text ";" *)
    val period : format    (* text "." *)

    val lparen : format    (* text "(" *)
    val rparen : format    (* text ")" *)
    val lbracket : format  (* text "[" *)
    val rbracket : format  (* text "]" *)
    val lbrace : format    (* text "{" *)
    val rbrace : format    (* text "}" *)
    val langle : format    (* text "<" *)
    val rangle : format    (* text ">" *)
    val equal : format     (* text "=", an honorary punctuation mark *)

  (* wrapping or enclosing formats, plus appending newlines and prepending labels *)

    val enclose : {front: format, back: format} -> format -> format
        (* concatenates (cblock) front and back to the front, respecively back, of the format *)

    val parens : format -> format
        (* = enclose {front=lparen, back=rparen} format *)

    val brackets : format -> format
        (* like parens, but with lbracket and rbracket *)

    val braces : format -> format
        (* like parens, but with lbrace and rbrace *)
			       
    val angleBrackets : format -> format			       
        (* like parens, but with lanble and rangle *)

    val appendNewLine : format -> format
        (* append a newline to the format -- normally used for "top-level" printing *)

    val label : string -> format -> format


  (* composing lists of formats with separator format *)

    val sequence : alignment -> format -> format list -> format
        (* sequence a break fmts: inserts break between constituent fmts and aligns by a *)

    (* aligned sequence formatters, first argument is seperator format, e.g. (typically) comma *)
    val hSequence : format -> format list -> format  (* = sequence H *)
    val pSequence : format -> format list -> format  (* = sequence P *)
    val vSequence : format -> format list -> format  (* = sequence V *)
    val cSequence : format -> format list -> format  (* = sequence C *)

  (* vertical alignment with header strings *)

    val vSequenceLabeled : {header1: string, header2: string} -> format list -> format
    (* add (left-justified) header1 as label for the first line, with header2 as a left-justified
     * label for successive lines.  Name changed from "vHeaders". *)

  (* indenting formats *)

    val indent : int -> format -> format
        (* indent n EMPTY ==> EMPTY; indent n fmt ==> INDENT (n, frmt) *)


  (* Conditional formats: *)

    val tryFlat : format -> format
	(* if the format fits flat, then render it flat, otherwise render it normally *)

    val alt : format * format -> format
	(* if the first format fits flat, use it, otherwise render the second format,
	   NOTE: the two argument formats may not have the same content! But usually they should! *)

    val hvblock : format list -> format
	(* acts as hblock if it fits, otherwise as vblock *)

    val styled : Style.style -> format -> format

end (* end FORMATTING *)
