```k
module DAFNY
  imports BOOL
  imports INT
  imports MAP
  imports ID
  imports COLLECTIONS
  
  // These are only needed for readability of intermediate steps
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
              | "foo" [token]
  syntax Id ::= "Main" [token]
  syntax Exp ::= ResultExp
               | Id
               | "(" Exp ")" [bracket]
  syntax KResult ::= ResultExp

  configuration <k> $PGM:Declaration ~> #call Main </k>
                <methods> .Set </methods>
                <stack> .List </stack>
                <store> .Map </store>
                <env> .Map </env>
                <nextLoc> 0 </nextLoc>
```

## Statement sequencing:

```k
  syntax Statements ::= List{Statement, ""} [klabel(Statements)]
  rule <k> S Ss:Statements => S ~> Ss  ... </k> requires Ss =/=K .Statements
  rule <k> S .Statements => S:Statement ... </k>
  rule <k> .Statements => .K            ... </k>
```

## Wait

```k
  syntax Statement ::= "wait" "(" Int ")" ";"
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
  syntax Statement ::= "assert" Exp ";" [seqstrict]
  syntax KItem ::= "#error"
  rule assert(true); => .K
  rule assert(false); => #error
```

## Assume statements:

```k
  syntax Statement ::= "assume" Exp ";" [seqstrict]
  rule <k> assume(true); => .K  ... </k>
  rule <k> assume(false); ~> S => .K </k>
       <stack> _ => .List </stack>
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
  syntax Statement ::= Id ":=" Exp ";" [seqstrict(2)]
  rule <k> X := V:Int ; => .K ... </k>
       <env> ... X |-> LOC ... </env>
       <store> ... LOC |-> (_ => V) ... </store>
```

## if statements

```k
  syntax Statement ::= "if" "(" Exp ")" "{" Statements "}" [seqstrict(1)]
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
           if (B) {
             { S }
             assert (INV) ;
             assume(false) ;
             .Statements
           }
           ...
       </k>
```

```execution
  rule <k> while (B) invariant INV { S:Statements }
        => assert(INV) ;
           if (B) {
              { S }
              while (B)
                invariant INV
              { S:Statements }
           }
           ...
       </k>
```

```k
  syntax Exps       ::= List{Exp, ","}        [klabel(Exps)]
  syntax ResultExps ::= List{ResultExp, ","}  [klabel(ResultExps)]
  
  syntax Exp  ::= "#hole"

  rule <k> (E, Es):Exps => E ~> #hole, Es ... </k>
    requires notBool isResultExp(E)
  rule <k> E:ResultExp ~> #hole, Es:Exps => E, Es ... </k>
    
  rule <k> (E, Es):Exps => Es ~> E, #hole ... </k>
    requires isResultExp(E)
//     andBool notBool isResultExps(Es)
  rule <k> Es:ResultExps ~> E, #hole => E, Es:ResultExps ... </k>
  
  rule <k> .Exps => .ResultExps ... </k>
```

methods:

```k
  syntax Declaration ::= "method" Id "(" ArgDecls ")"
                           "returns" "(" ArgDecls ")"
                           "requires" Exp
                           "ensures" Exp
                         "{" Statements "}"
  rule <k> DECL:Declaration => .K
           ...
       </k>
       <methods> MS => SetItem(DECL) MS </methods>
```

```k
   syntax KItem ::= "#call" Id
   syntax KItem ::= "#return" Exp [strict]
   syntax KItem ::= stackFrame(K, Map, Map)
   rule <k> #call MNAME ~> REST
         => #declareArgs(ARG_DECLS)
         ~> #declareArgs(RET_DECLS)
         ~> assume(REQS);
         ~> STMTS
         ~> assert(ENSURES);
         ~> #return R
        </k>
        <store> STORE => .Map </store>
        <env> ENV => .Map </env>
        <stack> .List => ListItem(stackFrame(REST, STORE, ENV))
                ...
        </stack>
        <methods> SetItem(
            method Id ( ARG_DECLS )
              returns ( (R : TYPE, .ArgDecls)  #as RET_DECLS )
              requires REQS
              ensures ENSURES
            { STMTS }
          )
          ...
        </methods>
        
  rule <k> #return R:ResultExp => R ~> REST </k>
       <stack> ListItem(stackFrame(REST, STORE, ENV)) => .List
               ...
       </stack>

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
  rule <k> #abstract(EXP) ;
        => #resetStore(Set2List(keys(STORE)))
        ~> assume(EXP) ;
           ...
       </k>
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
endmodule
```
