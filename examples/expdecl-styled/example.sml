(* example.sml
 *
 * COPYRIGHT (c) 2023 The Fellowship of SML/NJ (http://www.smlnj.org)
 * All rights reserved.
 *
 * Formatting simple expressions and declarations with ANSI terminal styles.
 *)

structure AST =
struct

  datatype exp
    = Let of dcl list * exp list
    | Var of string
    | Num of int
    | Plus of exp * exp

  and dcl
    = Val of string * exp

end

(* generic pretty-printer for the AST *)
structure FormatAST :
sig

    (* format an expression *)
    val formatExp : AST.exp -> Format.format

end =

struct (* FormatAST *)

local

  structure S = Style
  structure F = Format
  structure FG = Formatting

in 

  (* mapping some "local" styles into ANSI terminal style strings *)
  val kwStyle : S.style list = ["BF", "FG.Blue"]
  val varStyle : S.style list = ["UL"]
  val numStyle : S.style list = ["FG.Green"]
  val opStyle : S.style list = ["BF"]

  (* wrapStyles : S.style list * F.format -> F.format *)
  fun wrapStyles (nil, fmt) = fmt
    | wrapStyles (style::styles, fmt) = F.STYLE (style, wrapStyles (styles, fmt))

  (* kw : string -> F.format *)
  fun kw s = wrapStyles (kwStyle, FG.text s)

  val letKW = kw "let"
  val valKW = kw "val"
  val inKW = kw "in"
  val endKW = kw "end"

  fun var x = wrapStyles (varStyle, FG.text x)
  fun num n = wrapStyles (numStyle, FG.integer n)
  val plusOP = wrapStyles (opStyle, FG.text "+")

  fun formatExp (AST.Var s) = var s
    | formatExp (AST.Num n) = num n
    | formatExp (AST.Plus(exp1, exp2)) =
	PP.pblock
	  [PP.hblock [formatExp exp1, plusOP],
	   PP.indent 2 (formatExp exp2)]
    | formatExp (AST.Let (dcls, exps)) =
	let val body = formatExps exps
	 in FG.tryFlat
	      (FG.vblock
		 [FG.hblock[letKW, fmtDcls dcls],
		  FG.alt (FG.hblock [inKW, body, endKW],
			  FG.vblock [inKW, FG.indent 2 body, endKW])])
	end

  and formatExps (exps: AST.exp list) =
	FG.tryFlat (FG.vsequence FG.semicolon (map formatExp exps))

  and fmtDcl (AST.Val (name, exp)) =
      FG.block
	[FG.hblock [valKW, FG.text name, FG.equal],
	 FG.indent 4 (formatExp exp)]

  and fmtDcls dcls = FG.vblock (List.map fmtDcl dcls)

  fun render (e: exp) = Render.render (formatExp e)

end (* top local *)
end (* structure *)

(* some example expressions for testing *)
structure Example =
struct

  local open AST in

    val exp1 = Num 42
    val exp2 = Var "foo"
    val exp3 = Plus (Plus(Num 1, Num 2), Num 3)
    val exp4 = Let ([Val ("x", Num 1), Val ("y", Num 2)], [Plus (Var "x", Num 3), Var "y"]);

  end (* local open *)

end (* structure Example *)
