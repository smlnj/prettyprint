(* prettyprint/src/ansiterm-style.sml *)

(* formatting styles for an ANSITerm device; interpreting style strings as ANSITerm
 * styles *)

structure ANSITermStyle =
struct

structure S = Style
structure AT = ANSITerm

datatype ansiTermStyle
  = FG of ANSITerm.color   (* foreground color *)
  | BG of ANSITerm.color   (* background color *)
  | BF (* boldface on *)
  | UL (* underline on *)
  | BL (* blinking on *)
  | DM (* dim on *)
  | RV (* reverse fg/bg on *)
  | IV (* invisible on *)
  | NOSTYLE (* terminal in default mode *)

(* ANSITermColor : string -> AT.color *)
fun ANSItermColor (s: string) =
    case s
      of "Black" => AT.Black
       | "Red" => AT.Red
       | "Green" => AT.Green
       | "Yellow" => AT.Yellow
       | "Blue" => AT.Blue
       | "Magenta" => AT.Magenta
       | "Cyan" => AT.Cyan
       | "White" => AT.White
       | "Default" => AT.Default
       | _ => raise S.UnrecognizedStyle

(* colorStyle : S.style -> ansiTermStyle *)
fun colorStyle (s: S.style) =
    case (String.fields Char.isPunct s)
      of ["FG", color] => FG (ANSITermColor color)
       | ["BG", color] => BG (ANSITermColor color)
       | _ => raise S.UnrecognizedStyle

(* stringToStyle : S.style -> ansiTermStyle *)
fun stringToStyle (s: S.style) =
    case s
      of "BF" => BF
       | "UL" => UL
       | "BL" => BL
       | "DM" => DM
       | "RV" => RV
       | "IV" => IV
       | "NOSTYLE" => NOSTYLE
       | _ => colorStyle s

end (* structure ANSITermStyle *)
