module UNIT-TESTS
  imports DAFNY
  syntax Id ::= "i" [token]

  rule <k> 2 + 2 * 2 => 6 </k>
  rule <k> 1 / 0 => #error ~> 1 / 0 </k>
  rule <k> 1 / 2 => 0 </k>
  rule <k> 1 / 2 / 3 => 0 </k>
  rule <k> 2 / (2 / 3) => #error ~> 2 / 0 </k>
  rule <k> 1 < 2 => true </k>
  rule <k> 2 < 1 => false </k>

  rule <k> var i : int ;
           i .SuffixList := i .SuffixList + 1 ;
           i .SuffixList := i .SuffixList + i .SuffixList ;
        ~> i .SuffixList
        => 2
       </k>
       <store> .Map => ?_ </store>
       <env> .Map => ?_ </env>
       <nextLoc> 0 => 1 </nextLoc>

  rule <k> i .SuffixList => #error </k>
       <store> .Map => ?_ </store>
       <env> .Map => ?_ </env>
       <nextLoc> 0 </nextLoc>

  rule <k> var i : int ;
           if 2 < 1 { i .SuffixList := 0 ;   }
           else     { i .SuffixList := 100 ; }
        ~> i .SuffixList
        => 100
       </k>
       <store> .Map => ?_ </store>
       <env> .Map => ?_ </env>
       <nextLoc> 0 => 1 </nextLoc>
  rule <k> var i : int ;
           if 0 < 1 { i .SuffixList := 0 ;   }
           else     { i .SuffixList := 100 ; }
        ~> i .SuffixList
        => 0
       </k>
       <store> .Map => ?_ </store>
       <env> .Map => ?_ </env>
       <nextLoc> 0 => 1 </nextLoc>

endmodule
