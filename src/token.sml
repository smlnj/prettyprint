(* prettyprint/src/base/token.sml *)

(* Version 10.2 *)

(* strings with explicit widths, where the width of the string,
 * as printed, may be different from the number of characters in the string
 * (i.e. the size of the string), e.g. because of UTF8 encodings.
 *
 * We give this its own separate module (rather than defining token in Format,
 * for instance, so that device.cm does not need to depend on formatting.cm.
 *)

structure Token =
struct

(* token -- sized special strings (e.g. utf8), not abstract *)
type token = string * int

(* mkToken : string * int -> token *)
fun mkToken (s: string, n: int): token = (s,n)

(* size : token -> int *)
fun size ((_,n): token) = n

(* string : token -> string *)
fun string ((s,_): token) = s

end (* structure Token *)
