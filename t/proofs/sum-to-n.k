module TEST [all-path]
  imports DAFNY

  rule <k> method Main(n : int) returns (r : int)
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
       <store>   .Map => _ </store>
       <env>     .Map => _ </env>
       <stack>   .List => _ </stack>
       <methods> .Map => _ </methods>
       <nextLoc> 0    => _ </nextLoc>

  rule <k> while ( i > 0 )  
             invariant r + i * ( i + 1 ) / 2 == n * ( n + 1 ) / 2
                    && i >= 0 && n >= 0 && r >= 0
           { r := r + i ;  i := i - 1 ;  .Statements }
           .Statements
        ~> assert r == n * ( n + 1 ) / 2 ;
        => .K
       </k>
       <store>
         0 |-> ( V1:Int, const )
         1 |-> ( V10:Int, var)
         2 |-> ( V11:Int, var)
        => _
       </store>
       <env>
         i |-> 2
         n |-> 0
         r |-> 1
        => _
       </env>
       <nextLoc>
         3
        => _
       </nextLoc>
       <stack>   _ </stack>
       <methods>
         Main |-> method Main ( n : int , .ArgDecls ) returns ( r : int , .ArgDecls ) requires n >= 0 ensures r == n * ( n + 1 ) / 2 { var i : int ;  r := 0 ;  i := n ;  while ( i > 0 ) invariant r + i * ( i + 1 ) / 2 == n * ( n + 1 ) / 2 && i >= 0 && n >= 0 && r >= 0 { r := r + i ;  i := i - 1 ;  .Statements }  .Statements }
      => _
       </methods>
    requires V10 +Int V11 *Int ( V11 +Int 1 ) /Int 2 ==Int V1 *Int ( V1 +Int 1 ) /Int 2
//    andBool V2 >=Int 0
    andBool V1 >=Int 0
    andBool V10 >=Int 0
    andBool V11 >=Int 0
endmodule
