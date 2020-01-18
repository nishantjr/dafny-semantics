method Verify(n : int) returns (r : int)
  requires true
  ensures n * 2 == r
{
  r := n * 2 ;
}

method Main()
  returns (r: int)
  requires true
  ensures  true
{
  assert(Verify(0) == 0);
  assert(Verify(10) == 20);
  assert(Verify(-10) == -20);
}
