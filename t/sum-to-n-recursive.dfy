method Verify(n : int) returns (r : int)
  requires n >= 0
  ensures  r == n*(n + 1) / 2
{
  if (n == 0) {
    r := n;
  }
  if (n > 0) {
    var s : int;
    s := Verify(n - 1);
    r := n + s;
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
