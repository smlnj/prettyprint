(* prettyprint/src/html-style.sml *)

(* formatting styles for an ANSITerm device; interpreting style strings as ANSITerm
 * styles *)

structure HTMLStyle =
struct

local  (* imported structures *)

  structure S = Style

in

datatype htmlStyle
  = NOEMPH
  | TT | I | B | U | STRIKE | EM
  | STRONG | DFN | CODE | SAMP | KBD
  | VAR | CITE
  | COLOR of string (* the names of colors as spacified for HTML 3.2 *)
  | A of string (* the href URL string *)

(* styleToHtmlStyle : S.style -> htmlStyle *)
fun styleToHtmlStyle (s: S.style) =
    case s
      of "NOEMPH" => NOEMPH
       | "TT" => TT
       | "I" => I
       | "B" => B
       | "U" => U
       | "STRIKE" => STRIKE
       | "EM" => EM
       | "STRONG" => STRONG
       | "DFN" => DFN
       | "CODE" => CODE
       | "SAMP" => SAMP
       | "KBD" => KBD
       | "VAR" => VAR
       | "CITE" => CITE
       | _ => (* check for A or COLOR *)
	  (case (String.fields Char.isPunct s)
	     of ["A", href] => A href
	      | ["COLOR", color] => COLOR color
	      | _ => raise S.UnrecognizedStyle)

end (* top local *)
end (* structure HTMLStyle *)    
