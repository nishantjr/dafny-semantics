```k
module DAFNY
  imports BOOL
  imports INT
  imports MAP
  imports ID
  imports COLLECTIONS
  
  rule 0 +Int N => N [simplification]
  rule N +Int 0 => N [simplification]
  rule N -Int 0 => N [simplification]
  
  syntax ArgDecls ::= List{ArgDecl, ","}    [klabel(ArgDecls)]
  syntax ArgDecl ::= Id ":" Type
  syntax Type ::= "int"
  
  // Needed for parsing unit-tests
  syntax Id ::= "i" [token]
              | "x" [token]
              | "r" [token]
              | "n" [token]
  syntax Exp ::= ResultExp
               | Id
               | "(" Exp ")" [bracket]
  syntax KResult ::= ResultExp

  configuration <k> $PGM:Main </k>
                <store> .Map </store>
                <env> .Map </env>
                <nextLoc> 0 </nextLoc>

   syntax KItem ::= "#success"
```

## Statement sequencing:

```k
  syntax Statements ::= List{Statement, ""} [klabel(Statements)]
  rule <k> S Ss:Statements => S ~> Ss  ... </k>
  rule <k> .Statements => .K           ... </k>
```

## Blocks

```k
  syntax Statement ::= "{" Statements "}"
  rule <k> { Ss } => Ss ~> ENV ... </k>
       <env> ENV </env>
  rule <k> ENV_ORGINAL:Map => .K ... </k>
       <env> ENV => ENV_ORGINAL </env>
```

## Arithmetic expressions:

```k
  syntax ResultExp ::= Bool | Int
  syntax Exp ::= "(" Exp ")"  [bracket]
               | Exp "*" Exp  [seqstrict, left]
               > Exp "/" Exp  [seqstrict, left]
               | Exp "%" Exp  [seqstrict, left]
               > Exp "+" Exp  [seqstrict, left]
               | Exp "-" Exp  [seqstrict]
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
    requires I2 =/=Int 0
  rule <k> I1:Int / 0 => #error ~> I1 / 0 ... </k>
  rule <k> I1:Int % I2:Int => I1 modInt I2 ... </k>
    requires I2 =/=Int 0
  rule <k> I1:Int % 0 => #error ~> I1 % 0 ... </k>

  rule <k> I1:Int > I2:Int => I1 >Int I2 ... </k>
  rule <k> I1:Int >= I2:Int => I1 >=Int I2 ... </k>
  rule <k> I1:Int < I2:Int => I1 <Int I2 ... </k>
  rule <k> I1:Int <= I2:Int => I1 <=Int I2 ... </k>
  rule <k> I1:Int == I2:Int => I1 ==Int I2 ... </k>
  rule <k> I1:Int != I2:Int => I1 =/=Int I2 ... </k>

  rule <k> false && E:Exp => false ... </k>
  rule <k> true && E:Exp => E ... </k>
```

## Variable lookup:

```k
  rule <k> X:Id => V ... </k>
       <env> X |-> LOC ... </env>
       <store> LOC |-> V ... </store>
```

## Assert statements:

```k
  syntax Statement ::= "assert" Exp ";" [strict]
  syntax KItem ::= "#error"
  rule assert(true); => .K
  rule assert(false); => #error
```

## Assume statements:

```k
  syntax Statement ::= "assume" Exp ";" [strict]
  rule <k> assume(true); => .K  ...        </k>
  rule <k> assume(false); ~> S => #success </k>
```

## Variable declaration:

```k
  syntax Statement ::= "var" Id ":" Type ";"
  rule <k> var X : int ; => .K ... </k>
       <env> ENV => ENV[X <- LOC] </env>
       <store> .Map => LOC |-> ?_:Int ... </store>
       <nextLoc> LOC => LOC +Int 1 </nextLoc>
```

## Assignment statements:

```k
  syntax Statement ::= Id ":=" Exp ";" [strict(2)]
  rule <k> X := V:Int ; => .K ... </k>
       <env> ... X |-> LOC ... </env>
       <store> ... LOC |-> (_ => V) ... </store>
```

## if statements

```k
  syntax Statement ::= "if" "(" Exp ")" "{" Statements "}" [strict(1)]
  rule <k> if ( true ) { S } => S ... </k>
  rule <k> if ( false ) { S } => .K ... </k>
```

## while statements

```k
  syntax Statement ::= "while" "(" Exp ")" "invariant" Exp "{" Statements "}"
```

```verification
  rule <k> while (B) invariant INV { S:Statements }
        => assert(INV) ;
           #abstract(INV) ;
           if (B) { S ++Statements (assert (INV) ; assume(false) ; .Statements) }
           ...
       </k>
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
    ~> #success

  syntax KItem ::= "#declareArgs" "(" ArgDecls ")"
  rule #declareArgs(.ArgDecls) => .K
  rule #declareArgs(X:Id : T)  => var X : T ;
  rule #declareArgs(D, DS) => #declareArgs(D) ~> #declareArgs(DS)
    requires DS =/=K .ArgDecls
```

`#abstract(EXP)` statements: resets all variables in the store to symbolic values
such that `EXP` holds.

```k
  syntax Statement ::= "#abstract" "(" Exp ")" ";"
  rule <k> #abstract(EXP) ;  => #resetStore(Set2List(keys(STORE))) ~> assume(EXP) ; ... </k>
       <store> STORE </store>
  syntax KItem ::= "#resetStore" "(" List ")"
  rule <k> #resetStore(.List) => .K ... </k>
  rule <k> #resetStore(ListItem(LOC) REST)
        => #resetStore(              REST)
           ...
       </k>
       <store>
          LOC |-> (_ => ?_:Int)
          ...
       </store>
```

```k
  syntax Statements ::= Statements "++Statements" Statements [function, functional]
  rule .Statements ++Statements S => S
  rule (S1 S1s) ++Statements S2s => S1 (S1s ++Statements S2s)
```

```k
endmodule
```
