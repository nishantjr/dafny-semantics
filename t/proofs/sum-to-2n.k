module TEST [all-path]
  imports DAFNY

  rule <k> method Main(n : int) returns (r : int)
             requires n >= 0
             ensures  r == 2 * ( n*(n + 1) / 2)
           {
             var i : int ;
             r := 0;
             i := n;
           
             while (i > 0)
               invariant r + i * ( i + 1) / 2 == n * (n + 1 ) / 2
                      && i >= 0 && n >= 0
             {
               r := r + i;
               i := i - 1;
             }
           
             i := n;
           
             while (i > 0)
               invariant r + i * ( i + 1) / 2 ==  2 * ( n * (n + 1) / 2)
                      && i >= 0 && n >= 0
             {
               r := r + i;
               i := i - 1;
             }
           }
       </k>
       <store> .Map => ?_ </store>
       <env>   .Map => ?_ </env>
       <nextLoc> 0 => ?_ </nextLoc>
       <methods> .Map => ?_ </methods>

  rule  <k> while ( i > 0 )
              invariant r + i * ( i + 1 ) / 2 == n * ( n + 1 ) / 2
                     && i >= 0 && n >= 0
            { r := r + i ;  i := i - 1 ;  .Statements }
            i := n ;
            while ( i > 0 )
              invariant r + i * ( i + 1 ) / 2 == 2 * ( n * ( n + 1 ) / 2 ) && i >= 0 && n >= 0
            { r := r + i ;  i := i - 1 ;  .Statements }
            .Statements
         ~> assert r == 2 * ( n * ( n + 1 ) / 2 ) ;
        </k>
          <store>
            0 |-> V1:Int
            1 |-> V10:Int
            2 |-> V11:Int
            => ?_
          </store>
          <env>
            i |-> 2
            n |-> 0
            r |-> 1
            => ?_
          </env>
          <nextLoc>
            3 => ?_
          </nextLoc>
  requires (      V10 +Int V11 *Int ( V11 +Int 1 ) /Int 2 ==Int V1 *Int ( V1 +Int 1 ) /Int 2 ) 
  // andBool(V0 >=Int 0 )
  andBool(V1 >=Int 0 )
  andBool(V11 >=Int 0 ) 

  rule  <k>
            while ( i > 0 ) invariant r + i * ( i + 1 ) / 2 == 2 * ( n * ( n + 1 ) / 2 ) && i >= 0 && n >= 0 { r := r + i ;  i := i - 1 ;  .Statements }  .Statements ~> assert r == 2 * ( n * ( n + 1 ) / 2 ) ;
          => .K
          </k>
          <store>
            0 |-> V12:Int
            1 |-> V13:Int
            2 |-> V14:Int
            => ?_
          </store>
          <env>
            i |-> 2
            n |-> 0
            r |-> 1
            => ?_
          </env>
          <nextLoc>
            3
            => ?_
          </nextLoc>
          <methods> .Map => ?_ </methods>
  requires true // ( V10 +Int V11 *Int ( V11 +Int 1 ) /Int 2 ==Int V1 *Int ( V1 +Int 1 ) /Int 2 )
  andBool( V13 +Int V14 *Int ( V14 +Int 1 ) /Int 2 ==Int 2 *Int ( V12 *Int ( V12 +Int 1 ) /Int 2 ) )
  // andBool( notBool V11 >Int 0 )
  // andBool(V0 >=Int 0 )
  // andBool(V1 >=Int 0 )
  // andBool(V11 >=Int 0 )
  andBool(V12 >=Int 0 )
  andBool(V14 >=Int 0) 
endmodule
