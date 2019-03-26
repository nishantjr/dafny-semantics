method main()
  returns (r: int)
  requires true
  ensures true
{
  var x : int;
  x := straightLine(5);
}

method straightLine(x: int)
  returns (r: int)
  requires x > 0
  ensures r > 0
{
  x := 0 ;
  r := 2 * x ;
  r := r + 3 ;
  r := r - 2 ;
}

