

Possible issues with dafny:

* The following fails to verify:

  ```
  var a : int ;
  assert a == 0 ;
  ```

  but the following prints 0:

  ```
  var a : int ;
  print a ;
  ```
