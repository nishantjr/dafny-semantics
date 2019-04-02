method Main()
  returns (r: int)
  requires true
  ensures true
{
  assert(straightLine(5) == 11);
  assert(straightLine(0) == 1);
}

method straightLine(x: int)
  returns (r: int)
  requires x > 0
  ensures r > 0
{
  r := 2 * x ;
  r := r + 3 ;
  r := r - 2 ;
}

