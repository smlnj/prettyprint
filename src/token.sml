(* prettyprint/src/token.sml *)

(* Version 10.0 *)

(* strings with explicit widths, where the width of the string,
 * as printed, may be different from the number of characters in the string
 * (i.e. the size of the string), e.g. because of UTF8 encodings.
 *)

structure Token =
struct

type token = string * int

(* size : token -> int *)
fun size ((_,n): token) = n

(* raw : token -> string *)
fun size ((s,_): token) = s

end (* structure Token *)
