Loosly based on https://ece.uwaterloo.ca/~agurfink/ece653/2018/03/05/dafny-ref

```k
module DAFNY-SYNTAX
  imports DAFNY-COMMON
  imports ID-PROGRAM-PARSING
endmodule

module DAFNY-COMMON
  imports ID-SYNTAX
  imports INT-SYNTAX
  imports BOOL

  // tokens
  syntax WildIdent ::= "_" | NoUSIdent
  syntax NoUSIdent ::= Id // TODO: Fixme
  syntax Ident ::= Id // TODO: Fixme
  syntax NameSegment ::= Ident

  syntax Pgm ::= TopDeclList
  syntax TopDeclList ::= List{TopDecl, ""}
  syntax TopDecl ::= MethodDecl
  syntax MethodDecl ::= "method" MethodName Formals "returns" Formals
                            MethodSpec
                            BlockStmt
  syntax MethodName ::= NoUSIdent
  syntax Formals ::= "(" GIdentTypeList ")"
  syntax IdentType ::= WildIdent ":" Type
  syntax GIdentType ::= "ghost" IdentType
                      | IdentType
  syntax GIdentTypeList ::= List{GIdentType, ","}
  syntax BlockStmt ::= "{" StmtList "}"
  syntax StmtList ::= List{Stmt, ""}
  syntax Stmt ::= BlockStmt
                | Lhs ":=" Rhs ";"
  syntax Lhs ::= NameSegment
  syntax Rhs ::= Expression

  syntax Type ::= "bool" | "int" | "nat"
  syntax UnaryExpression ::= PrimaryExpression
                           | "-" UnaryExpression
                           | "!" UnaryExpression
  syntax PrimaryExpression ::= ConstAtomExpression
                             | NameSegment

  syntax Nat [hook(INT.Int)]
  syntax Nat ::= r"[0-9]+" [prefer, token, prec(2)]

  syntax ConstAtomExpression ::= Bool | "null" | Nat | Int
  syntax MulOp ::= "*" | "/" | "%"
  syntax Factor ::= UnaryExpression MulOp UnaryExpression
                  | UnaryExpression
  syntax AddOp ::= "+" | "-"
  syntax Term ::= Factor
                | Factor AddOp Factor

  syntax Expression ::= Expression ";" Expression
                      > RelationalExpression
  syntax RelationalExpression ::= Term
                                | Term RelOp Term
  syntax RelOp ::= "==" | "<" | ">" | "<=" | ">=" | "!="

  syntax RequiresClause ::= "requires" Expression
  syntax EnsuresClause ::= "ensures" Expression

  syntax MethodSpec ::= MethodSpec MethodSpec
  syntax MethodSpec ::= RequiresClause
                      | EnsuresClause
  
endmodule

module DAFNY
endmodule
```
