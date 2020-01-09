module TEST [all-path]
  imports DAFNY

  rule <k> 2 + 2 * 2 => 6 </k>
  rule <k> 3 - 2 => 1 </k>
  rule <k> 1 / 0 => #error ~> 1 / 0 </k>
  rule <k> 1 / 2 => 0 </k>
  rule <k> 1 / 2 / 3 => 0 </k>
  rule <k> 1 % 0 => #error ~> 1 % 0 </k>
  rule <k> 18 % 3 => 0 </k>
  rule <k>  2 % 3 => 2 </k>
  rule <k> -2 % 3 => 1 </k>

  rule <k> 2 + (2 + 2) => 6 </k>
  rule <k> 2 / (2 / 3) => #error ~> 2 / 0 </k>
  rule <k> 1 < 2 => true </k>
  rule <k> 2 < 1 => false </k>
  rule <k> 1 > 2 => false </k>
  rule <k> 2 > 1 => true </k>

  rule <k> 2 + (2 + N:Int) => 4 +Int N</k>
  rule <k> 2 + (2 + N:Int) > 2 => true </k>
    requires N >Int 0

  rule <k> 1 == 2 => false </k>
  rule <k> 2 == 2 => true </k>
//  rule <k> 1 == true </k>  // Should stay stuck
  rule <k> 1 != 2 => true </k>
  rule <k> 2 != 2 => false </k>

  rule <k> var i : int ;
           i := i + 1 ;
           i := i + i ;
        ~> i
        => N:Int
       </k>
       <store> .Map => ?_ </store>
       <env> .Map => ?_ </env>
       <nextLoc> 0 => 1 </nextLoc>

  rule <k> var i : int ;
           i := 100 ;
           if (2 < 1) { i := 0 ;   }
        ~> i
        => 100
       </k>
       <store> .Map => ?_ </store>
       <env> .Map => ?_ </env>
       <nextLoc> 0 => 1 </nextLoc>

  rule <k> var i : int ;
           i := 100 ;
           if (0 < 1) { i := 0   ; }
        ~> i
        => 0
       </k>
       <store> .Map => ?_ </store>
       <env> .Map => ?_ </env>
       <nextLoc> 0 => 1 </nextLoc>

  rule <k>   var i : int ; i := 100 ;
           { var i : int ; i := 200 ; }
        ~> i
        => 100
       </k>
       <store>   .Map => ?_  </store>
       <env>     .Map => ?_  </env>
       <nextLoc> 0    => ?_  </nextLoc>

  rule <k> 1, 2 + 2, 3, .Exps
        => 1, 4, 3, .ResultExps
           ...
       </k>
       <store>   .Map => ?_  </store>
       <env>     .Map => ?_  </env>
       <nextLoc> 0    => ?_  </nextLoc>

  rule <k> (1 + 2), (2 + 3), (3 + 4), .Exps
        => 3, 5, 7, .ResultExps
           ...
       </k>
       <store>   .Map => ?_  </store>
       <env>     .Map => ?_  </env>
       <nextLoc> 0    => ?_  </nextLoc>
endmodule
