method Main(x: int)
  returns (r: int)
  requires x > 0
  ensures r > 0
{
  r := 2 * x ;
  r := r * x ;
}
