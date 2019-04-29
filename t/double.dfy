method Main(n : int) returns (r : int)
  requires true
  ensures n * 2 == r
{
  r := n * 2 ;
}
