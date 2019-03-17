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
  syntax NameSegment ::= Ident SuffixList
  syntax SuffixList ::= List{Suffix, ""} [klabel(suffixList)]
  syntax Suffix ::= ArgumentListSuffix
  syntax ArgumentListSuffix ::= "(" ExpressionList ")"

  syntax Pgm ::= TopDeclList
  syntax TopDeclList ::= List{TopDecl, ""} [klabel(topDeclList)]
  syntax TopDecl ::= MethodDecl
  syntax MethodDecl ::= "method" MethodName Formals "returns" Formals
                            MethodSpec
                            BlockStmt
  syntax MethodName ::= NoUSIdent
  syntax Formals ::= "(" GIdentTypeList ")"
  syntax IdentType ::= WildIdent ":" Type
  syntax GIdentType ::= "ghost" IdentType
                      | IdentType
  syntax GIdentTypeList ::= List{GIdentType, ","} [klabel(gIdentTypeList)]
  syntax BlockStmt ::= "{" StmtList "}"
  syntax StmtList ::= List{Stmt, ""} [klabel(stmtList)]
  syntax Stmt ::= BlockStmt
                | UpdateStmt
                | VarDeclStmt
                | IfStmt
  syntax VarDeclStmt ::= "var" IdentType ";"
  syntax UpdateStmt ::= Lhs ":=" Rhs ";" [strict(2)]
  syntax IfStmt ::= "if" Guard BlockStmt
                    "else" BlockStmt [strict(1)]
  syntax Guard ::= Expression

  syntax Lhs ::= NameSegment
  syntax Rhs ::= Expression

  syntax Type ::= "bool" | "int" | "nat"
  syntax UnaryExpression ::= PrimaryExpression
                           | "-" UnaryExpression
                           | "!" UnaryExpression
  syntax PrimaryExpression ::= ConstAtomExpression
                             | NameSegment
                             | ParensExpression
  syntax ParensExpression ::= "(" ExpressionList ")" [klabel(parensExpression)]

  syntax ConstAtomExpression ::= Bool | "null" | Int
  syntax MulOp ::= "*" | "/" | "%"
  syntax Factor ::= Factor MulOp UnaryExpression [strict(1, 3)]
                  | UnaryExpression
  syntax AddOp ::= "+" | "-"
  syntax Term ::= Factor
                | Term AddOp Factor [strict(1, 3)]

  syntax ExpressionList ::= List{Expression, ","} [klabel(ExpressionList)]
  syntax Expression ::= Expression ";" Expression
                      > RelationalExpression
  syntax RelationalExpression ::= Term
                                | Term RelOp Term [strict(1, 3)]
  syntax RelOp ::= "==" | "<" | ">" | "<=" | ">=" | "!="

  syntax RequiresClause ::= "requires" Expression
  syntax EnsuresClause ::= "ensures" Expression

  syntax MethodSpec ::= MethodSpec MethodSpec
  syntax MethodSpec ::= RequiresClause
                      | EnsuresClause

endmodule

module DAFNY
  imports DAFNY-COMMON
  imports MAP
  imports INT

  configuration <T>
                  <k> $PGM:Pgm </k>
                  <env> .Map </env>
                  <store> .Map </store>
                  <nextLoc> 0 </nextLoc>
                </T>
  syntax KItem ::= "#error"
```

Expressions
-----------

```k
  syntax KResult ::= ConstAtomExpression
  rule <k> I1:Int + I2:Int => I1 +Int I2 ... </k>
  rule <k> I1:Int * I2:Int => I1 *Int I2 ... </k>
  rule <k> I1:Int / I2:Int => I1 /Int I2 ... </k>
    requires I2 =/=Int 0
  rule <k> I1:Int / 0 => #error ~> I1:Int / 0 ... </k>
  rule <k> I1:Int < I2:Int => I1 <Int I2 ... </k>

  // ParensExpression with a single inner expression reduce to the expression
  // (otherwise they should reduce to a tuple)
  rule <k> (E, .ExpressionList):ParensExpression => E ... </k>

  // Variable lookup
  rule <k> X:Ident .SuffixList => V ... </k>
       <env> ... X |-> L ... </env>
       <store> ... L |-> V ... </store>
  rule <k> X:Ident .SuffixList => #error ... </k>
       <env> ENV:Map </env>
    requires notBool X in_keys(ENV)

```

Statements
----------

```k
  rule <k> S1 S2:StmtList => S1 ~> S2 ... </k>
  rule <k> .StmtList => .K ... </k>

  // BlockStmt
  // TODO: This needs to introduce a new variable scope
  rule <k> { Ss } => Ss ... </k>

  // VarDeclStmt
  rule <k> var X : TYPE ; => .K ... </k>
       <env> ... .Map => X |-> L ... </env>
       <store> ... .Map => L |-> 0 ... </store>
       <nextLoc> L => L +Int 1 </nextLoc>

  // UpdateStmt
  rule <k> X:Ident .SuffixList := V:ConstAtomExpression ; => .K ... </k>
       <env> ... X |-> L ... </env>
       <store> ... L |-> (Z => V) ... </store>
  rule <k> X:Ident .SuffixList := V:ConstAtomExpression ; => .K ... </k>
       <env> ... X |-> L ... </env>
       <store> ... L |-> (Z => V) ... </store>

  // IfStmt
  rule <k> if true  S1 else S2 => S1 ... </k>
  rule <k> if false S1 else S2 => S2 ... </k>
```

```k
endmodule
```
