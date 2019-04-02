method double(n : nat) returns ( r : nat)
  ensures n * 2 == r
{
  r := n * 2 ;
}

method Main() returns ()
  ensures true
{
  assert(double(5) == 10);
  assert(double(3) == 6);
  assert(double(0) == 0);
}

