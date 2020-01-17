method Verify(n : int) returns (r : int)
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

method Main()
  returns (r: int)
  requires true
  ensures  true
{
  assert(Verify(0)  == 0);
  assert(Verify(3) == 6);
}
