method sum(n : nat) returns ( r : nat)
  ensures r == n * (n + 1) / 2
{
  r := partialsum(n, 0);
//  print(r);
}

method partialsum(n: nat, p: nat) returns (r : nat)
  ensures r == p + n * (n + 1) / 2
{
  if (n != 0) {
    r := partialsum(n - 1, p + n);
  } else {
    r := p;
  }
}

method Main() returns ()
  ensures true
{
  var r : nat;
  r := sum(5);
}
