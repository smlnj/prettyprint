(* prettyprint/src/html/html-style.sml *)

(* (physical?) formatting styles for HTML(3); this style type, htmlStyle, is analogous to
 * the physical or device style for a device, e.g., an ANSI terminal device. *)

structure HTMLStyle =
struct

datatype htmlStyle
  = NOEMPH
  | TT | I | B | U | STRIKE | EM
  | STRONG | DFN | CODE | SAMP | KBD
  | VAR | CITE
  | COLOR of string (* the names of colors as spacified for HTML 3.2 *)
  | A of string  (* the href URL string (what about the link name?) *)

(* htmlStylemap : Style.style -> htmlStyle
 * This is an example of a stylemap that maps logical styles (represented
 * by strings) to the htmlStyle "physical" style for html, represented as 
 * constructors for the htmlStyle type.
 *
 * A logical color style is of the form "COLOR#<color name>", where <colorname> is
 * the string name of some HTML color.
 *
 * The A link "styles" are anomalous, and somewhat problematic. We can think
 * of the A "style" as producing an html link whose content (link URL) takes 
 * the form of a text format containing the URL string.
 * It is not clear how the A style should interact with other styles such as "I"
 * or COLOR#RED. [How does this work in HTML itself?]
 *
 * For instance, what should happen with
 *  
 *    STYLE ("COLOR#RED", (STYLE "A", TEXT "www.smlnj.org")), or
 *    STYLE ("A", STYLE ("COLOR#RED", TEXT "www.smlnj.org"))?
 *
 * The basic problem is that the FORMAT type does not include a construct that
 * directly corresponds to the A link construct in HTML.
 * 
 * Otherwise, a logical style string should match one of the explicit lhs string
 * patterns in the styleToHtmlStyle function below.
 *)

fun isSharpChar (c : char) = (c = #"#")

(* htmlStylemap : Style.style -> htmlStyle *)
fun htmlStylemap (s: Style.style) =
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

end (* structure HTMLStyle *)    
