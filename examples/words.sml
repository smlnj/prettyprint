(* prettyprint/examples/words.sml *)

(* format a string (consisting of space-separated words) into a paragraph *)

local

  structure F = Formatting

in

  fun formatPara (s: string) : F.format =
      let val tokens = String.tokens Char.isSpace s
       in F.pBlock (map F.text tokens)
      end;

  val test1 : string =
      "Now is the time for all good men to come to the aid of their party.";

end; (* local *)
