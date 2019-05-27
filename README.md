## Building

* Build and run all tests using `./build`
* Only `kompile` a definition: `./build dafny`
* Once the definition has been kompiled, run a dafny program: `./kdafny run t/sum-to-n.dfy`

## Future work

* Classes
   * Method calls
   * global state
* `#save` is not needed; only one call to `assert`
* Invariant inference
   * Move to Haskell backend
   * Implement `#subsumed`
* foralls and arrays
 

## Possible issues with dafny:

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
