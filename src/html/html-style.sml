(* prettyprint/src/html/html-style.sml *)

(* formatting styles for an ANSITerm device; interpreting style strings as ANSITerm
 * styles *)

structure HTMLStyle =
struct

datatype htmlStyle
  = NOEMPH
  | TT | I | B | U | STRIKE | EM
  | STRONG | DFN | CODE | SAMP | KBD
  | VAR | CITE
  | COLOR of string (* the names of colors as spacified for HTML 3.2 *)
  | A of string  (* the href URL string (what about the link name?) *)

fun isSharpChar (c : char) = (c = #"#")

(* htmlStylemap : string -> htmlStyle *)
fun htmlStylemap (s: string) =
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
	  (case (String.fields isSharpChar s)
	     of ["A", href] => A href
	      | ["COLOR", color] => COLOR color
	      | _ => raise Fail "Unrecognized HTML style string")

(* A color style string is of the form "COLOR#Black", where "Black" could be the string
 * name of any HTML color.
 * An "A" link is of the form "A#<url string>".
 * Otherwise, a style string should match one of the explicit lhs string patterns in the 
 * styleToHtmlStyle function above.
 *)

end (* structure HTMLStyle *)    
