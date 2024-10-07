(* example.sml
 *
 * COPYRIGHT (c) 2023 The Fellowship of SML/NJ (http://www.smlnj.org)
 * All rights reserved.
 *
 * Formatting simple expressions and declarations with ANSI terminal styles.
 * (Version 10.1 of PrettyPrint *)
 *)

(* AST: a small abstract syntax *)
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
    val formatExp : AST.exp -> Formatting.format

end =

struct (* FormatAST *)

local

  structure S = Style
  structure F = Formatting
  structure AT = ANSITermDevice
in 

  (* mapping some "local" styles into ANSI terminal style strings *)
  val kwDevStyle : AT.style = 
  val varStyle : AT.style = 
  val numStyle : AT.style = [AT.Green]
  val opStyle : AT.style = [AT.BoldFace]

  (* stylemap : Style.style -> AT.style *)
  fun stylemap "keyword" = [AT.BoldFace, AT.Blue] (* keyword device Style *)
    | stylemap "variable" = [AT.UnderLine] (* variable device Style *)
    | stylemap "number" = [AT.Green] (* number device Style *)
    | stylemap "operator" = [AT.BoldFace] (* operator device Style *)

  (* kw : string -> F.format *)
  fun kw s = F.style ("keyword", F.text s)
  (* var : string -> F.format *)
  fun var x = F.style ("variable", F.text x)
  (* var : int -> F.format *)
  fun num n = F.style ("number", F.integer n)
  (* oper : string -> F.format *)
  fun oper s = F.style ("operator", F.text s)

  val valKW = kw "val"
  val letKW = kw "let"
  val inKW = kw "in"
  val endKW = kw "end"
  val plusOP = oper "+"

  fun formatExp (AST.Var s) = var s
    | formatExp (AST.Num n) = num n
    | formatExp (AST.Plus(exp1, exp2)) =
	F.pBlock
	  [F.hBlock [formatExp exp1, plusOP],
	   F.indent 2 (formatExp exp2)]
    | formatExp (AST.Let (dcls, exps)) =
	let val body = formatExps exps
	 in F.tryFlat
	      (F.vBlock
		 [F.hBlock[letKW, fmtDcls dcls],
		  F.alt (F.hBlock [inKW, body, endKW],
			  F.vBlock [inKW, F.indent 2 body, endKW])])
	end

  and formatExps (exps: AST.exp list) =
	F.tryFlat (F.vSequence F.semicolon (map formatExp exps))

  and fmtDcl (AST.Val (name, exp)) =
      F.Block
	[F.hBlock [valKW, var name, F.equal],
	 F.indent 4 (formatExp exp)]

  and fmtDcls dcls = F.vBlock (List.map fmtDcl dcls)

  fun render (lw: int) (e: exp) = PrintFormat.renderStd lw (formatExp e)

  fun renderANSI (lw: int) (e: exp) = PrintFormat.renderANSI lw (formatExp e)

end (* top local *)
end (* structure *)

(* some example expressions for testing *)
structure Example =
struct

local 

  structure A = AST

in

    val exp1 = A.Num 42
    val exp2 = A.Var "foo"
    val exp3 = A.Plus (A.Plus (A.Num 1, A.Num 2), A.Num 3)
    val exp4 = A.Let ([A.Val ("x", A.Num 1), A.Val ("y", A.Num 2)], 
	              [A.Plus (A.Var "x", A.Num 3), A.Var "y"]);

end (* top local*)
end (* structure Example *)
