(* smlnj-lib/PrettyPrint/examples/expdecl.sml, for PrettyPrint, Version 8.3 *)

(* (JHR, 2022-0606)

Let's imagine the following type

datatype exp
= Let of dcl list * exp list
| ...

and dcl
= Val of string * exp
| ...

How would you format expressions so that you could get the following renders?

	let val x = ...
	    val y = ...
	in x + y end

	let val x = ... in x end
*)

local
  structure F = Formatting
  structure P = PrintPlain
in

datatype exp
  = Let of dcl list * exp list
  | Var of string
  | Num of int
  | Plus of exp * exp

and dcl
  = Val of string * exp

fun formatExp (Var s) = F.text s
  | formatExp (Num n) = F.integer n
  | formatExp (Plus (exp1, exp2)) =
      F.pBlock
	 [F.hBlock [formatExp exp1, text "+"],
	  F.indent 2 (formatExp exp2)]
  | formatExp (Let (dcls, exps)) =
      F.tryFlat
         (F.vSequenceLabeled (justifyRight ["let", "in", "end"])
	     [fmtDcls dcls,
              formatExps exps,
              F.empty])

and formatExps (exps: exp list) =
    F.tryFlat (F.vSequence F.semicolon (map formatExp exps))

and fmtDcl (Val (name, exp)) =
    F.pBlock
       [F.hBlock [F.text "val", F.text name, F.equal],
	F.indent 4 (formatExp exp)]

and fmtDcls dcls = F.vBlock (map fmtDcl dcls)

end; (* local *)

(* examples *)

val exp1 = Let ([Val ("x", Num 1), Val ("y", Num 2)], [Plus (Var "x", Num 3), Var "y"]);

(* nullStylemap : P.Render.stylemap *)
val nullStylemap : P.Render.stylemap = (fn (s: S.style) = ())
(* nullTokenmap : P.Render.tokenmap *)
val nullTokenmap : P.Render.tokenmap = (fn (t: T.token) = ())

fun test fmt w = P.printFormatNL (nullStylemap, nullTokenmap, w) fmt

val test1 = test (formatExp exp1);
