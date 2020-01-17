method Verify(n : int)
  returns (r: int)
  requires true
  ensures r >= 0
{
  if (n <= 0) { r := 0 - n ; }
  if (n >= 0) { r := n ; }
}

method Main()
  returns (r: int)
  requires true
  ensures  true
{
  assert(Verify(-3) == 3);
  assert(Verify(0)  == 0);
  assert(Verify(3)  == 3);
}
