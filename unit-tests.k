module UNIT-TESTS
  imports DAFNY
  syntax NoUSIdent ::= "i" [token]
                     | "j" [token]

  rule <k> 2 + 2 * 2 => 6 </k>
  rule <k> 3 - 2 => 1 </k>
  rule <k> 1 / 0 => #error("Division by zero") ~> 1 / 0 </k>
  rule <k> 1 / 2 => 0 </k>
  rule <k> 1 / 2 / 3 => 0 </k>
  rule <k> 1 % 0 => #error("Division by zero") ~> 1 % 0 </k>
  rule <k> 18 % 3 => 0 </k>
  rule <k>  2 % 3 => 2 </k>
  rule <k> -2 % 3 => 1 </k>

  rule <k> 2 + (2 + 2) => 6 </k>
  rule <k> 2 / (2 / 3) => #error("Division by zero") ~> 2 / 0 </k>
  rule <k> 1 < 2 => true </k>
  rule <k> 2 < 1 => false </k>

  rule <k> 1 == 2 => false </k>
  rule <k> 2 == 2 => true </k>
  rule <k> 1 == true </k>  // Should stay stuck
  rule <k> 1 != 2 => true </k>
  rule <k> 2 != 2 => false </k>

  rule <k> var i : int ;
           i := i + 1 ;
           i := i + i ;
        ~> i
        => 2
       </k>
       <store> .Map => ?_ </store>
       <env> .Map => ?_ </env>
       <nextLoc> 0 => 1 </nextLoc>

  rule <k> i => #error("Undefined variable") ~> i ~> ?_ </k>
       <store> .Map => ?_ </store>
       <env> .Map => ?_ </env>
       <nextLoc> 0 </nextLoc>

  rule <k> var i : int ;
           if 2 < 1 { i := 0 ;   }
           else     { i := 100 ; }
        ~> i
        => 100
       </k>
       <store> .Map => ?_ </store>
       <env> .Map => ?_ </env>
       <nextLoc> 0 => 1 </nextLoc>

  rule <k> var i : int ;
           if 0 < 1 { i := 0 ;   }
           else     { i := 100 ; }
        ~> i
        => 0
       </k>
       <store> .Map => ?_ </store>
       <env> .Map => ?_ </env>
       <nextLoc> 0 => 1 </nextLoc>

   rule <k> ( method Main (.GIdentTypeList):Formals
                returns (i: int):Formals
                requires true:Expression
                ensures true:Expression
              {
                 i := 5 ;
              }
            ):MethodDecl
         ~> execute
         => 5 ;
       </k>
       <store> .Map => ?_ </store>
       <globalEnv> .Map => ?_ </globalEnv>
       <env> .Map => ?_ </env>
       <nextLoc> 0 => 2 </nextLoc>

endmodule
