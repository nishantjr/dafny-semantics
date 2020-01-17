method Verify(x: int)
  returns (r: int)
  requires x > 0
  ensures r > 0
{
  r := 2 * x ;
  r := r * x ;
}

method Main()
  returns (r: int)
  requires true
  ensures  true
{
  assert(Verify(0) == 0);
  assert(Verify(3) == 18);
}
