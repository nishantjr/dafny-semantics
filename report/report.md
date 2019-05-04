---
title: A $\mathbb{K}$ Semantics for Dafny Verfication
author:
 - Andrew Miranti
 - Nishant Rodrigues
header-includes: \usepackage{xcolor}
---

\newcommand {\K} {$\mathbb{K}$ }
\newcommand {\todo}[1] {{\color{red}TODO: #1}}

Abstract
========

In this paper we will present an implementation of verification over a
fragment of the Dafny programming language in the K Framework.

Introduction
============

## What is Dafny?

The Dafny language provides a familiar programming environment to
developers new to writing automatically verified code. It borrows from
the imperative and functional styles \[Cite: Dafny website\], augmented
with loop invariants, pre/post-condition annotations, and assert/assume
statements to specify the correctness properties of a program, and
assist a mechanical prover in verifying these properties. Dafny
automatically generates proofs of a program's correctness and (usually)
termination \[Cite: Dafny tutorial\]. But the native Dafny tools have
some significant disadvantages in complexity and language dependence,
and doubts of the cross validity between Dafny execution and Dafny
verification. This may also prove a difficulty for
programmers unfamiliar with verification attempting to debug a Dafny
program. To remedy these issues, we create an proof of concept
operational semantics for Dafny using the \K Framework.

## What is \K?

The \K Framework is a tool for creating executable semantics for programming
languages, and, from these semantic specifications, generating a variety of
formal analysis tools. \K generates a parser, interpreter, and deductive
verifier automatically from a given definition. It provides facilities for both
concrete and symbolic execution, and debugging tools for validating a
definition. Generating these tools from the same ultimate source provides a
sense of confidence in their consistency and avoids unnecessary duplicate work.
Rewrite rules provide an intuitive and highly expressive language for defining
specifications, allowing people without formal logic training to create and
verify specifications. As a testimony to the readability of \K specifications,
the KEVM semantics, a formalization of the Ethereum Virtual Machine is slated to
replace the reference documentation for that virtual machine
\todo{is this public?}, while forming the basis for commercial auditing and
verification efforts. Further, \todo{Citations} complete K semantics exist for
languages such as C
\todo{98?}~\cite{ellison2012executable}~\cite{hathhorn-ellison-rosu-2015-pldi},
Java\~\cite{bogdanas-rosu-2015-popl} and
JavaScript\~\cite{park-stefanescu-rosu-2015-pldi}, witness to the scalability of
the \K framework to large semantics. The semantics of C++, x86-64 and LLVM are
also in the works \todo{is LLVM complete?}.

![The  \K approach as described in ~\cite{stefanescu-park-yuwen-li-rosu-2016-oopsla}](k-overview.png)

## Motivation

The \K approach is a semantics-first one. We prescribe to the notion that once a
formal semantics of a language is defined, little extra effort should be
expended to derive the tools mentioned above. Since all these tools are derived
from the same semantics, confidence in the correctness of one tool transfers to
the others. For example, the \K C semantics has been tested against GCC's test
suites giving a certain confedence in the correctness of the dedective verifier.
We often don't have this confidence when using other verifiers, such as VCC
\todo{Examples, citations}. The JavaScript revealed bugs and divergent behaviour
in all major JavaScript engines.

This project aims to be a first step towards adding language-agnostic static
checking of invariants and specifiations to \K's repertoire. Currently, while
\K does provide a deductive program verifier, it requires the user to have a
non-trivial understanding of both \K and the implementation details of the
language. While this in itself is useful (and has proven commercial value), it
sets a high bar for writing verified software. Dafny provides an easy-to-use,
modular and scalable approach to verified software development. It does this
through provding a mechanism for specifying invariants, pre-conditions, and
post-conditions via a syntax built in to the language. Static verification of
these invariants, is however, non-trivial. Dafny implements this via translation
of each program into another language, Boogie, built specifically for
verification. Execution of Dafny programs is handled by a completely different
code path, allowing for divergence between the two. We believe that small (and
natural) extensions to the \K framework would allow languages developers to
implement similar features in other languages, all the while using the same
implementation for both verification and execution. With that goal in mind, this
project implements a verification specific semantics for Dafny: it can take a
program written in (a subset of) Dafny, and check partial correctness.

## Implementation

### What subset of Dafny do we implement

### Explain a K definition, a few of the rules (main, if, while, assert, #abstract, assume)

The main components of a \K definition are:

1.  a configuration encapsulating all of the state and context that can impact
    the execution of a program,
2.  a set of syntactic elements of the programming language,
3.  and a set of rewrite "rules" specifying functions and transitions between
    states.

Program state is represented via a "configuration", defined using an XMLesque notation.
For our Dafny implementation, we use the following configuration:

```k
configuration <k> $PGM:Main </k>
              <store> .Map </store>
              <env> .Map </env>
              <nextLoc> 0 </nextLoc>
```

The `<k>` cell functions as a "main" cell, and is usually used for driving
computation. It usually contains a stack representing the context within which
we are executing. When a program starts execution, the `$PGM` variable is
replaced with the program. During execution, `<store>` cell contains mapping
between locations (or addresses) and values. The `<store>` cell contains a
mapping between variables declared at the current position in the program and
the locations at which their values are stored.

The following statement defines the syntax of Dafny's addition operator:

```k
  syntax Exp ::= Exp "+" Exp [seqstrict, left]
```

The `left` attribute marks `+` as left-associative, allowing the parser to resolve
ambiguities without needing parenthesis. The `seqstrict` attribute
adds additional rules, causing sub-expressions to be evaluated first, from left
to right, before evaluate the operator.

```
  rule <k> I1:Int + I2:Int => I1 +Int I2 ... </k>
```

The rule above says that for any program state that has a `<k>` cell with first
element an expression of the form `I1 + I2` where `I1` and `I2` are `Int`s,
replace that expression with their sum. Here `+Int` is a builtin operator,
distinct from `+`, that performs integer addition. Note that the `...` is
valid \K syntax and indicates that there can be addition constructs within the
`<k>` cell.

Division is defined similarly, though we make sure to add side conditions
to take care of division by zero.

```
  rule <k> I1:Int / I2:Int => I1 /Int I2 ... </k>
    requires I2 =/=Int 0                           [transition]
  rule <k> I1:Int / 0 => #error ~> I1 / 0 ... </k> [transition]
```

The following, slightly more complicated, snippet defines variable assignment:

```k
  syntax Statement ::= Id ":=" Exp ";" [strict(2)]
  rule <k> X := V:Int ; => .K ... </k>
       <env> ... X |-> LOC ... </env>
       <store> ... LOC |-> (_ => V) ... </store>
```

The update statement is defined strict in it's second argument: the `Exp` passed to
it must be fully evaluated before proceeding. The rule states that whenever
an update statement is encountered at the top of the `<k>` cell, replace it.

Assert statements are defined via strictness: the the expression evaluates to
`true`, then it is a no op, otherwise, the program terminates with an error.

```k
  syntax Statement ::= "assert" Exp ";" [strict]
  syntax KItem ::= "#error"
  rule assert(true); => .K          [transition]
  rule assert(false); => #error     [transition]
```

Assume statements are more subtle: if the expresssion evaluates to `true`, then it is
a no op. If it evaluates to `false`, the program verification terminates successfully.

```k
  syntax Statement ::= "assume" Exp ";" [strict]
  rule assume(true); => .K                  [transition]
  rule <k> assume(false); ~> S => .K </k>   [transition]
```

\todo{explain how we take advantage of symbolic execution}

Verification of the `Main` method occurs as follows: parameters (both input and output)
are initialized to fresh symbolic values, via the `#declareArgs` construct.
We then `assume` that the precondition, defined in the `requires` clause, holds,
execute the body, and finally assert that the postcondition holds.

```k
  syntax Main ::= "method" "Main" "(" ArgDecls ")"
                  "returns" "(" ArgDecls ")"
                  "requires" Exp
                  "ensures" Exp
                  "{" Statements "}"
  rule method Main (ARGS) returns (RETS)
          requires REQS
          ensures ENSURES { STMTS }
    => #declareArgs(ARGS)
    ~> #declareArgs(RETS)
    ~> assume(REQS);
    ~> STMTS
    ~> assert(ENSURES);
```

For while loops, we first assert that the invariant holds initially. Next, the
`#abstract(INV);` replaces the current state with a fresh symbolic state, such
that `INV` holds. It then executes `BODY` and asserts that `INV` still holds if
expression `B` holds. Otherwise, it continues with the rest of the program.

```k
  syntax Statement ::= "while" "(" Exp ")" "invariant" Exp "{" Statements "}"
  rule <k> while (B) invariant INV { BODY:Statements }
        => assert(INV) ;
           #abstract(INV) ;
           if (B) { BODY ++Statements (assert (INV) ; assume(false) ; .Statements) }
           ...
       </k>
```

## Future work

### Expanding the subset of Dafny we implement

The obvious direction forward is to extend the fragment of dafny programs that
we can prove partial correctness. A first step in this direction would be to
support verification of top-level methods and method calls, additional types
such as `nat`s and arrays. Verification of invariants involving arrays pose a
challenge that may need aditional insight, since it often requires
quantification over array indices. In the long run, we'd like to support the
plethora of dafny paradigms including algebraic and co-algebraic data types,
classes, ghost variables and heap reasoning.

### Termination

Another important avenue to persue is to extend verification to prove termination
via Dafny's `decreases` sepecifications.

### Sharing a definition for both execution and verification
### Making this language agnostic
### Inferring invariants

Our current definition specifies an operational semantics for Dafny's
verification. It does this by giving a verification-specific semantics to
constructs, such as loops, who's execution semantics would involve fixed-points.
In an ideal world, this verification semantics should be derivable from the
execution semantics.

```k
syntax Statement ::= "while" "(" Exp ")" "invariant" Exp "{" Statements "}"
rule <k> while (B) invariant INV { S }
      => assert(INV) ;
         #abstract ;
         #assume(INV);
         #save
         if (B) { S ; assert (INV) ;
                  #subsumed? ;
                  while (B) invariant INV { S }
                }
         ...
     </k>
```

Here, the semantics of `#abstract` is that it is *any* monotonic function that
replaces the configuration $C$ with another (symbolic) configuration $C'$ such
that $C -> C'$. The original configuration $C$ is saved as an "abstraction
point". `#subsume?` will check if the current configuration implies the
saved abstraction point. If it does, then we prune that trace. This
is sound for partial correctness. Otherwise, it will replace the abstraction point
with `#abstract(C \/ C')` where $C$ is the configuration at the abstraction
point and $C'$ is the current configuration and continue exectution.

In the case of concrete exectution, we can instantiate `#abstract` to the
identity function. The previous implementation for while loops can be thought of
as instantiating `#abstract` with a function replacing the configuration cells
(besides the `k` cell) with a fresh symbolic configuration that satisfies the
invariant.

We can also have `#abstract` replace each variable's value with the weakest
pattern that holds from a set of patterns that form a complete partial order of
finite height (e.g. isInteger, isPositive, isNonNegative... isZero, false; or
odd/even/top.) Since the partial order of finite height we must eventually
converge at some fixed point. This fixed point is in fact an invariant of the
loop.

So, from the same semantics, we can get concrete execution, invariant checking
as well as infer new invariants.

## Conclusion
