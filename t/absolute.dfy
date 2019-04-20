method Main(n : int)
  returns (r: int)
  requires true
  ensures r >= 0
{
  if (n <= 0) { r := 0 - n ; }
  if (n >= 0) { r := n ; }
}
