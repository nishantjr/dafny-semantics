Loosely based on https://github.com/Microsoft/dafny/raw/master/Docs/DafnyRef/out/DafnyRef.pdf

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
  syntax WildIdent ::= NoUSIdent
  syntax NoUSIdent ::= Id // TODO: Fixme
  syntax Ident ::= Id // TODO: Fixme
  syntax NameSegment ::= Ident
  syntax Suffix ::= ArgumentListSuffix
  syntax ArgumentListSuffix ::= "(" ExpressionList ")" [klabel(argListSuffix), strict(1)]

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
                | CallStmt
                | VarDeclStmt
                | IfStmt
                | AssertStmt
  syntax VarDeclStmt ::= "var" IdentType ";"
  syntax UpdateStmt ::= Lhs ":=" Rhs ";" [strict(2)]
  syntax CallStmt ::= Rhs ";" [strict]
  syntax IfStmt ::= "if" Guard BlockStmt
                    "else" BlockStmt [strict(1)]
  syntax Guard ::= Expression
  syntax AssertStmt ::= "assert" Expression ";" [strict(1)]

  syntax Lhs ::= NameSegment
  syntax Rhs ::= Expression

  syntax Type ::= "bool" | "int" | "nat"
  syntax UnaryExpression ::= PrimaryExpression
                           | "-" UnaryExpression
                           | "!" UnaryExpression
  syntax ConstAtomSuffix ::= ConstAtomExpression
                           | ConstAtomSuffix Suffix [klabel(caeSuffix), seqstrict]
  syntax NameSegmentSuffix ::= NameSegment
                             | NameSegmentSuffix Suffix [klabel(nsSuffix)]
  syntax PrimaryExpression ::= ConstAtomSuffix
                             | NameSegment
  syntax ParensExpression ::= "(" ExpressionList ")" [klabel(parensExpression)]

  syntax ConstAtomExpression ::= LiteralExpression
                               | ParensExpression
                               | NameSegment

  syntax LiteralExpression ::= Int | Bool | "null"
  syntax MulOp ::= "*" | "/" | "%"
  syntax Factor ::= Factor MulOp UnaryExpression [klabel(mulOp), strict(1, 3)]
                  | UnaryExpression
  syntax AddOp ::= "+" | "-"
  syntax Term ::= Factor
                | Term AddOp Factor [klabel(addOp), strict(1, 3)]

  syntax ExpressionList ::= List{Expression, ","} [klabel(expressionList), seqstrict]
  syntax Expression ::= Expression ";" Expression
                      > RelationalExpression
  syntax RelationalExpression ::= Term
                                | Term RelOp Term [klabel(relOp), strict(1, 3)]
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
                  <k> $PGM:Pgm ~> execute ~> clear </k>
                  <globalEnv> .Map </globalEnv>
                  <env> .Map </env>
                  <store> .Map </store>
                  <nextLoc> 0 </nextLoc>
                </T>
  syntax KItem ::= "#error" "(" String ")"

  syntax ValueExpression
  syntax Expression ::= ValueExpression
  syntax KResult ::= ValueExpression
```

Execution
---------

```k
  rule <k> T Ts:TopDeclList => T ~> Ts ... </k>
  rule <k> .TopDeclList => .K ... </k>
```

Execution begins with a call to `Main()`:

```k
  syntax KItem ::= "execute"
  syntax Id ::= "Main" [token]
  rule <k> execute => Main (.ExpressionList) ; ... </k>
       <env> .Map => GENV </env>
       <globalEnv> GENV:Map </globalEnv>
```

After execution we clear the program state. This allows us to have a single
expected output for all tests.

```k
  syntax KItem ::= "clear"
  rule <k> clear => .K ...  </k>
       <env> _ => .K </env>
       <globalEnv> _ => .K </globalEnv>
       <store> _ => .K </store>
       <nextLoc> _ => -1 </nextLoc>
```

Methods: Declaration and calls
------------------------------

TODO: We assume all methods are top-level.
Declaring a method adds it as a lambda to the store. This drops the `requires`
and `ensures` clauses.

```k
  syntax LambdaExpression ::= #lambda(Formals, Formals, BlockStmt)
  syntax ConstAtomExpression ::= LambdaExpression
  syntax ValueExpression ::= LambdaExpression
  rule <k> method MNAME PARAMS returns RETURNS SPEC STMTS => .K ... </k>
       <globalEnv> Env => Env[MNAME <- L ] </globalEnv>
       <store> ... .Map => L |-> #lambda(PARAMS, RETURNS, STMTS) ... </store>
       <nextLoc> L => L +Int 1 </nextLoc>
```

`#setEnv`

```k
  syntax K ::= #setEnv(Map)
  rule <k> #setEnv(M) => . ... </k>
       <env> _ => M </env>
```

`#return` restores the old environment and places the return value at the top
of the `<k>` cell.

```k
  syntax K ::= "#return" "(" Expression "!" Map ")" [strict(1)]
  rule <k> #return(E:ValueExpression ! ENV)
        => #setEnv(ENV) ~> E
           ...
       </k>
```

Lambda application:

```k
  syntax ResultArgumentListSuffix
  syntax ArgumentListSuffix ::= ResultArgumentListSuffix
  syntax KResult ::= ResultArgumentListSuffix
  rule isResultArgumentListSuffix(argListSuffix(VL:ValueList)) => true

  syntax ValueList
  syntax ExpressionList ::= ValueList
  syntax KResult ::= ValueList
  rule isValueList(expressionList(V:ValueExpression, Vs:ValueList))
    => true
  rule isValueList(.ExpressionList) => true
```

```k
  rule <k> #lambda((PARAMS:GIdentTypeList), (RETURNS:GIdentTypeList), STMTS) ( VALUES:ExpressionList )
        => #setEnv(GENV)
        ~> #declareVarsForArgs(PARAMS ! VALUES)
        ~> #declareVarsForReturns(RETURNS)
        ~> STMTS
        ~> #return(#returnsToExpression(RETURNS) ! ENV)
           ...
       </k>
       <env> ENV </env>
       <globalEnv> GENV </globalEnv>
    requires isKResult(VALUES)

  syntax StmtList ::= "#declareVarsForArgs" "(" GIdentTypeList "!" ExpressionList ")" [function]
  rule #declareVarsForArgs( (X:Id : TYPE):IdentType, ITs
                          ! VAL , VALs:ExpressionList
                          )
    => var X : TYPE ;
       X := VAL ;
       #declareVarsForArgs( ITs
                          ! VALs
                          )
  rule #declareVarsForArgs(.GIdentTypeList ! .ExpressionList)
    => .StmtList

  syntax StmtList ::= "#declareVarsForReturns" "(" GIdentTypeList ")" [function]
  rule #declareVarsForReturns ( (X:Id : TYPE):IdentType, ITs )
    => var X : TYPE ;
       #declareVarsForReturns(ITs)
  rule #declareVarsForReturns(.GIdentTypeList) => .StmtList
```

```k
  syntax Expression ::= "#returnsToExpression" "(" GIdentTypeList ")" [function]
  syntax ValueExpression ::= "#emptyReturn"
  rule #returnsToExpression( .GIdentTypeList )
    => #emptyReturn
  rule #returnsToExpression( (X:Id : TYPE) , .GIdentTypeList )
    => X
  // TODO: otherwise return parensExpression
```

Expressions
-----------

```k
  syntax ValueExpression ::= LiteralExpression
  rule <k> I1:Int + I2:Int => I1 +Int I2 ... </k>
  rule <k> I1:Int - I2:Int => I1 -Int I2 ... </k>
  rule <k> I1:Int * I2:Int => I1 *Int I2 ... </k>
  rule <k> I1:Int / I2:Int => I1 /Int I2 ... </k>
    requires I2 =/=Int 0
  rule <k> I1:Int / 0 => #error("Division by zero") ~> I1:Int / 0 ... </k>

  rule <k> I1:Int < I2:Int => I1 <Int I2 ... </k>
  rule <k> I1:Int == I2:Int => I1 ==Int I2 ... </k>
  rule <k> I1:Int != I2:Int => notBool(I1 ==Int I2) ... </k>

  // ParensExpression with a single inner expression reduce to the expression
  // (otherwise they should reduce to a tuple)
  rule <k> (E, .ExpressionList):ParensExpression => E ... </k>

  // Variable lookup
  rule <k> X:Ident => V ... </k>
       <env> ... X |-> L ... </env>
       <store> ... L |-> V ... </store>
  rule <k> X:Ident => #error("Undefined variable") ~> X ... </k>
       <env> ENV:Map </env>
    requires notBool X in_keys(ENV)
```

Statements
----------

```k
  rule <k> S1 S2:StmtList => S1 ~> S2 ... </k>
  rule <k> .StmtList => .K ... </k>

  // BlockStmt
  rule <k> { Ss } => Ss ~> #setEnv(ENV) ... </k>
       <env> ENV </env>

  // VarDeclStmt
  rule <k> var X : TYPE ; => .K ... </k>
       <env> ... .Map => X |-> L ... </env>
       <store> ... .Map => L |-> 0 ... </store>
       <nextLoc> L => L +Int 1 </nextLoc>

  // UpdateStmt
  rule <k> X:Ident := V:ValueExpression ; => .K ... </k>
       <env> ... X |-> L ... </env>
       <store> ... L |-> (Z => V) ... </store>
  rule <k> X:Ident := V:ValueExpression ; => .K ... </k>
       <env> ... X |-> L ... </env>
       <store> ... L |-> (Z => V) ... </store>

  // CallStmt
  rule <k> E:ValueExpression ; => .K ... </k>

  // IfStmt
  rule <k> if true  S1 else S2 => S1 ... </k>
  rule <k> if false S1 else S2 => S2 ... </k>
  
  // AssertStmt
  rule <k> assert true ; => .K ... </k>
```

```k
endmodule
```
