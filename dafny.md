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
  syntax ArgumentListSuffix ::= "(" ExpressionList ")" [klabel(argListSuffix)]

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
  syntax VarDeclStmt ::= "var" IdentType ";"
  syntax UpdateStmt ::= Lhs ":=" Rhs ";" [strict(2)]
  syntax CallStmt ::= Rhs ";" [strict]
  syntax IfStmt ::= "if" Guard BlockStmt
                    "else" BlockStmt [strict(1)]
  syntax Guard ::= Expression

  syntax Lhs ::= NameSegment
  syntax Rhs ::= Expression

  syntax Type ::= "bool" | "int" | "nat"
  syntax UnaryExpression ::= PrimaryExpression
                           | "-" UnaryExpression
                           | "!" UnaryExpression
  syntax ConstAtomSuffix ::= ConstAtomExpression
                           | ConstAtomSuffix Suffix [klabel(caeSuffix), strict(1)]
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

  syntax ExpressionList ::= List{Expression, ","} [klabel(expressionList)]
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
                  <k> $PGM:Pgm ~> execute </k>
                  <globalEnv> .Map </globalEnv>
                  <env> .Map </env>
                  <store> .Map </store>
                  <nextLoc> 0 </nextLoc>
                </T>
  syntax KItem ::= "#error" "(" String ")"

  syntax ValueExpression
  syntax KResult ::= ValueExpression
```

Execution
---------

```k
  rule <k> T Ts:TopDeclList => T ~> Ts ... </k>
  rule <k> .TopDeclList => .K ... </k>
```

Execution begins with a call to `main()`:

```k
  syntax KItem ::= "execute"
  syntax Id ::= "main" [token]
  rule <k> execute => main (.ExpressionList) ; ... </k>
       <env> .Map => GENV </env>
       <globalEnv> GENV:Map </globalEnv>
```

Methods: Declaration and calls
------------------------------

TODO: We assume all methods are top-level.
Declaring a method adds it as a lambda to the store. This drops the `requires`
and `ensures` clauses.

```k
  syntax KItem ::= "#Test"
  syntax LambdaExpression ::= #lambda(Formals, Formals, BlockStmt)
  syntax ConstAtomExpression ::= LambdaExpression
  syntax ValueExpression ::= LambdaExpression
  rule <k> method MNAME PARAMS returns RETURNS SPEC STMTS => .K ... </k>
       <globalEnv> Env => Env[MNAME <- L ] </globalEnv>
       <store> ... .Map => L |-> #lambda(PARAMS, RETURNS, STMTS) ... </store>
       <nextLoc> L => L +Int 1 </nextLoc>
```

Method invocation is lambda application:

```k
  syntax K ::= SetEnv(Map)

  rule <k> SetEnv(M) => . ... </k>
       <env> _ => M </env>

  syntax K ::= "Return" "(" GIdentTypeList "!" Map ")" // Return and store old environment atomically

  rule <k> Return((X:Id : TYPE):IdentType, .GIdentTypeList ! M) => S[ENV[X]] ... </k>
       <env> ENV => M </env>
       <store> S </store>      

  rule <k> #lambda((PARAMS:GIdentTypeList), (RETURNS:GIdentTypeList), STMTS) ( VALUES:ExpressionList ) 
        => SetEnv(GENV)
        ~> #declareVarsForArgs(PARAMS ! VALUES)
        ~> #declareVarsForReturns(RETURNS)
        ~> STMTS
        ~> Return(RETURNS ! ENV)
           ...
       </k>
       <env> ENV </env>
       <globalEnv> GENV </globalEnv>

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
  rule <k> { Ss } => Ss ~> SetEnv(ENV) ... </k>
       <env> ENV </env>

  // VarDeclStmt
  rule <k> var X : TYPE ; => .K ... </k>
       <env> ... .Map => X |-> L ... </env>
       <store> ... .Map => L |-> 0 ... </store>
       <nextLoc> L => L +Int 1 </nextLoc>

  // UpdateStmt
  rule <k> X:Ident := V:ConstAtomExpression ; => .K ... </k>
       <env> ... X |-> L ... </env>
       <store> ... L |-> (Z => V) ... </store>
  rule <k> X:Ident := V:ConstAtomExpression ; => .K ... </k>
       <env> ... X |-> L ... </env>
       <store> ... L |-> (Z => V) ... </store>

  // IfStmt
  rule <k> if true  S1 else S2 => S1 ... </k>
  rule <k> if false S1 else S2 => S2 ... </k>
```

```k
endmodule
```
