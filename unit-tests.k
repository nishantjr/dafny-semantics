module UNIT-TESTS
  imports DAFNY

//  rule <k> 2 + 2 * 2 => 6 </k>
//  rule <k> 3 - 2 => 1 </k>
//  rule <k> 1 / 0 => #error ~> 1 / 0 </k>
//  rule <k> 1 / 2 => 0 </k>
//  rule <k> 1 / 2 / 3 => 0 </k>
//  rule <k> 1 % 0 => #error ~> 1 % 0 </k>
//  rule <k> 18 % 3 => 0 </k>
//  rule <k>  2 % 3 => 2 </k>
//  rule <k> -2 % 3 => 1 </k>
//
//  rule <k> 2 + (2 + 2) => 6 </k>
//  rule <k> 2 / (2 / 3) => #error ~> 2 / 0 </k>
//  rule <k> 1 < 2 => true </k>
//  rule <k> 2 < 1 => false </k>
//  rule <k> 1 > 2 => false </k>
//  rule <k> 2 > 1 => true </k>
//
//  rule <k> 2 + (2 + N:Int) => 4 +Int N</k>
//  rule <k> 2 + (2 + N:Int) > 2 => true </k>
//    requires N >Int 0
//
//  rule <k> 1 == 2 => false </k>
//  rule <k> 2 == 2 => true </k>
////  rule <k> 1 == true </k>  // Should stay stuck
//  rule <k> 1 != 2 => true </k>
//  rule <k> 2 != 2 => false </k>
//
//  rule <k> var i : int ;
//           i := i + 1 ;
//           i := i + i ;
//        ~> i
//        => N:Int
//       </k>
//       <store> .Map => ?_ </store>
//       <env> .Map => ?_ </env>
//       <nextLoc> 0 => 1 </nextLoc>
//
//  rule <k> var i : int ;
//           i := 100 ;
//           if (2 < 1) { i := 0 ;   }
//        ~> i
//        => 100
//       </k>
//       <store> .Map => ?_ </store>
//       <env> .Map => ?_ </env>
//       <nextLoc> 0 => 1 </nextLoc>
//
//  rule <k> var i : int ;
//           i := 100 ;
//           if (0 < 1) { i := 0   ; }
//        ~> i
//        => 0
//       </k>
//       <store> .Map => ?_ </store>
//       <env> .Map => ?_ </env>
//       <nextLoc> 0 => 1 </nextLoc>

  rule <k> method Main(n : int, .ArgDecls) returns (r : int, .ArgDecls)
             requires n >= 0
             ensures  r == n*(n + 1) / 2
           {
             var i : int ;
             r := 0;
             i := n;
             while (i > 0)
               invariant r + i * ( i + 1) / 2 == n * (n + 1 ) / 2
                      && i >= 0 && n >= 0 && r >= 0
             {
               r := r + i;
               i := i - 1;
             }
           }
        => .K
       </k>
       <store> .Map => ?_ </store>
       <env> .Map => ?_ </env>
       <nextLoc> 0 => ?_ </nextLoc>

endmodule
