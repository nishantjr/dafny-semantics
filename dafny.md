```k
module DAFNY
  imports BOOL
  imports INT
  imports MAP

  syntax ArgDecls ::= List{ArgDecl, ","}    [klabel(ArgDecls)]
  syntax ArgDecl ::= Id ":" Type
  syntax Type ::= "int"

  syntax Id ::= r"[a-z][a-z]*" [token]
              | "i" | "x" | "r"
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
  rule (method Main (ARGS) returns (RETS) requires REQS ensures ENSURES { STMTS }):Main
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
  syntax Exp ::= Exp "*" Exp [seqstrict, left]
               > Exp "+" Exp [seqstrict, left]
               | Exp "-" Exp [seqstrict]
               > Exp ">"  Exp [seqstrict]
               > Exp ">=" Exp [seqstrict]
               | Exp "<" Exp [seqstrict]
  rule <k> I1:Int + I2:Int => I1 +Int I2 ... </k>
  rule <k> I1:Int - I2:Int => I1 -Int I2 ... </k>
  rule <k> I1:Int * I2:Int => I1 *Int I2 ... </k>
  rule <k> I1:Int > I2:Int => I1 >Int I2 ... </k>
  rule <k> I1:Int >= I2:Int => I1 >=Int I2 ... </k>
  rule <k> I1:Int < I2:Int => I1 <Int I2 ... </k>
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
  syntax KItem ::= "#error"
  rule assume(true); => .K          [transition]
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

```k
endmodule
```
