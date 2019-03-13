Loosly based on https://ece.uwaterloo.ca/~agurfink/ece653/2018/03/05/dafny-ref

```k
module DAFNY-SYNTAX
  syntax Pgm ::= TopDeclList
  syntax TopDeclList ::= List{TopDecl, ""}
  syntax TopDecl ::= MethodDecl
  
  syntax RequiresClause ::= "requires" Expression
  syntax EnsuresClause ::= "ensures" Expression
  syntax MethodSpec ::= RequiresClause
                      | EnsuresClause
  
  syntax MethodDecl ::= "method" MethodName Formals "returns" Formals
                            MethodSpec
                            BlockStmt
  syntax BlockStmt ::= "{" StmtList "}"
endmodule

module DAFNY
endmodule
```
