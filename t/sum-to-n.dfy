method sum(n : nat) returns ( r : nat)
  ensures r == n * (n + 1) / 2
{
  r := partialsum(n, 0);
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
  assert(sum(5) == 15);
  assert(sum(4) == 10);
  assert(sum(0) == 0);
}
