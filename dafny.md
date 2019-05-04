```k
module DAFNY
  imports BOOL
  imports INT
  imports MAP

  syntax ArgDecls ::= List{ArgDecl, ","}    [klabel(ArgDecls)]
  syntax ArgDecl ::= Id ":" Type
  syntax Type ::= "int"

  syntax Id ::= r"[a-z][a-z]*" [token]
              | "i" | "x" | "r" | "n"
  syntax Exp ::= ResultExp
               | Id
               | "(" Exp ")" [bracket]
  syntax KResult ::= ResultExp

  configuration <k> $PGM:Main </k>
                <store> .Map </store>
                <env> .Map </env>
                <nextLoc> 0 </nextLoc>
```

Main method:

```k
  syntax Main ::= "method" "Main" "(" ArgDecls ")"
                  "returns" "(" ArgDecls ")"
                  "requires" Exp
                  "ensures" Exp
                  "{" Statements "}"
  rule method Main (ARGS) returns (RETS)
         requires REQS
         ensures ENSURES
       { STMTS }
    => #declareArgs(ARGS)
    ~> #declareArgs(RETS)
    ~> assume(REQS);
    ~> STMTS
    ~> assert(ENSURES);

  syntax K ::= "#declareArgs" "(" ArgDecls ")" [function]
  rule #declareArgs(.ArgDecls) => .K
  rule #declareArgs(X:Id : T)  => var X : T ;
  rule #declareArgs(D, DS) => #declareArgs(D) ~> #declareArgs(DS)
```

Arithmetic expression:

```k
  syntax ResultExp ::= Bool | Int
  syntax Exp ::= "(" Exp ")" [bracket]
               | Exp "*" Exp [seqstrict, left]
               > Exp "/" Exp [seqstrict, left]
               | Exp "%" Exp [seqstrict, left]
               > Exp "+" Exp [seqstrict, left]
               | Exp "-" Exp [seqstrict]
               > Exp ">"  Exp [seqstrict]
               | Exp ">=" Exp [seqstrict]
               | Exp "<" Exp  [seqstrict]
               | Exp "<=" Exp [seqstrict]
               | Exp "==" Exp [seqstrict]
               | Exp "!=" Exp [seqstrict]
               > Exp "&&" Exp [seqstrict, left]
  rule <k> I1:Int + I2:Int => I1 +Int I2 ... </k>
  rule <k> I1:Int - I2:Int => I1 -Int I2 ... </k>
  rule <k> I1:Int * I2:Int => I1 *Int I2 ... </k>
  rule <k> I1:Int / I2:Int => I1 /Int I2 ... </k>
    requires I2 =/=Int 0                           [transition]
  rule <k> I1:Int / 0 => #error ~> I1 / 0 ... </k> [transition]
  rule <k> I1:Int % I2:Int => I1 modInt I2 ... </k>
    requires I2 =/=Int 0                           [transition]
  rule <k> I1:Int % 0 => #error ~> I1 % 0 ... </k> [transition]

  rule <k> I1:Int > I2:Int => I1 >Int I2 ... </k>
  rule <k> I1:Int >= I2:Int => I1 >=Int I2 ... </k>
  rule <k> I1:Int < I2:Int => I1 <Int I2 ... </k>
  rule <k> I1:Int <= I2:Int => I1 <=Int I2 ... </k>
  rule <k> I1:Int == I2:Int => I1 ==Int I2 ... </k>
  rule <k> I1:Int != I2:Int => I1 =/=Int I2 ... </k>

  rule <k> false && E:Exp => false ... </k>
  rule <k> true && E:Exp => E ... </k>
```

Variable lookup:

```k
  rule <k> X:Id => V ... </k>
       <env> ... X |-> LOC ... </env>
       <store> ... LOC |-> V ... </store>
```

Statements:

```k
  syntax Statements ::= List{Statement, ""} [klabel(Statements)]
  rule S Ss:Statements => S ~> Ss
  rule .Statements => .K
```

Assert statement:

```k
  syntax Statement ::= "assert" Exp ";" [strict]
  syntax KItem ::= "#error"
  rule assert(true); => .K          [transition]
  rule assert(false); => #error     [transition]
```

Assume statement:

```k
  syntax Statement ::= "assume" Exp ";" [strict]
  rule assume(true); => .K                  [transition]
  rule <k> assume(false); ~> S => .K </k>   [transition]
```

Variable declaration:

```k
  syntax Statement ::= "var" Id ":" Type ";"
  rule <k> var X : int ; => .K ... </k>
       <env> .Map => X |-> LOC ... </env>
       <store> .Map => LOC |-> ?_:Int ... </store>
       <nextLoc> LOC => LOC +Int 1 </nextLoc>
```

Update

```k
  syntax Statement ::= Id ":=" Exp ";" [strict(2)]
  rule <k> X := V:Int ; => .K ... </k>
       <env> ... X |-> LOC ... </env>
       <store> ... LOC |-> (_ => V) ... </store>
```

if statements

```k
  syntax Statement ::= "if" "(" Exp ")" "{" Statements "}" [strict(1)]
  rule <k> if ( true ) { S } => S ... </k>                 [transition]
  rule <k> if ( false ) { S } => .K ... </k>               [transition]
```

while statements

```k
  syntax Statement ::= "while" "(" Exp ")" "invariant" Exp "{" Statements "}"
  rule <k> while (B) invariant INV { S:Statements }
        => assert(INV) ;
           #abstract(INV) ;
           if (B) { S ++Statements (assert (INV) ; assume(false) ; .Statements) }
           ...
       </k>
```

`#abstract(EXP)` statements: resets all variables in the store to symbolic values
such that `EXP` holds.

```k
  syntax Statement ::= "#abstract" "(" Exp ")" ";"
  rule <k> #abstract(EXP) ; => assume(EXP) ; ... </k>
       <store> STORE => #resetVariables(STORE) </store>
  syntax Map ::= "#resetVariables" "(" Map ")" [function, klabel(resetVariablesHelper)]
  rule #resetVariables(.Map) => .Map
  rule #resetVariables((L |-> V) REST) => (L |-> ?_:Int) #resetVariables(REST)
```

```k
  syntax Statements ::= Statements "++Statements" Statements [function]
  rule .Statements ++Statements S => S
  rule (S1 S1s) ++Statements S2s => S1 (S1s ++Statements S2s)
```

```k
endmodule
```
