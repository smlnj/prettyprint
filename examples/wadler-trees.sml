(* prettyprint/examples/wadler-trees.sml *)

local

structure F = Formatting

in

  datatype tree = Node of string * tree list

  (* Wadler's first version of tree example *)
  fun formatTree1 (Node (s, trees)) = 
      F.cBlock [F.text s, formatTrees trees]

  and formatTrees nil = empty
    | formatTrees trees =
        F.brackets (F.vSequence F.comma (map formatTree1 trees))

   (* Wadler's second version of tree example *)
   fun formatTree2 (Node (s, trees)) = 
       case trees
	 of nil => F.text s
	  | _ =>
	     F.vBlock
	       [cBlock [F.text s, lbracket],
		F.indent 2 (F.vSequence F.comma (map formatTree2 trees)),
		rbracket]

  (* an example tree *)
  val tree1 =
      Node ("aaa",
	    [Node ("bbbbb",
		   [Node ("ccc", nil),
		    Node ("dd", nil)]),
	     Node ("eee", nil),
	     Node ("ffff",
		   [Node ("gg", nil),
		    Node ("hhh", nil),
		    Node ("ii", nil)])]);

end (* local *)
