\newcommand {\K} {{$\mathbb{K}}}

A (mostly) Language Agnositc Approach to Language-Specific Verifiers
====================================================================

Motivation
----------

Programming languages are typically given only an informal semantics before
being implemented. A formal semantics is written later, if ever. Invariably,
this means that there are inconsistencies between the formal semantics, the
implementation and the informal semantics. Verification tools, even if they
adhere faithfully to the formal semantics, thus, do not unnecessarily reflect
the behaviour the implementation. For example, for the C language, VCC
implements verification as a translation to Boogie. There is little assurance
that this translation conforms with the ISO C standard, an informal natural
language document, and even less that any particular compiler has the same
behaviour. Similarly, Dafny, a language designed for static verification,
implements verification via translation to Boogie, and execution via an
independent translation to C\#.

To mitigate this, \K takes a semantics-first approach. We prescribe to the
notion that once a formal semantics of a language is defined, little extra
effort should be needed to derive the tools such as parsers, compilers,
interpreters, deductive verifiers, etc. Since all these tools are derived from
the same semantics, confidence in the correctness of one tool transfers to the
others. For example, the formal C semantics written in \K has been tested
against GCC's test suites giving a certain confidence in the correctness of the
deductive verifier. The \K JavaScript semantics revealed bugs and divergent
behaviour in all major JavaScript engines.

While \K does provide a deductive program verifier, it requires the user to have
a non-trivial understanding of the subtilities of \K, Matching and Reachability
Logic, and the implementation details of the language-specification. While this
in itself is useful (and has proven commercial value), it makes writing verified
software expensive. This paper talks about first steps towards adding
language-agnostic and easy to use verification tools to \K's repertoire.

We take two approaches towards this:

(1) *A simple property-based-testing like approach:* We must only extend the
    language with a construct `symbolic_int` for creating symbolic values,
    `require` statements for specifying constraints over these symbolic values,
    and an `assert` statement. While we do not currently support specifying loop
    invariants in this framework, this method is simple and often suffices for
    programs written for the blockchain that often only employ straight-line
    code.

(2) *A static program verifier*: Annotating programs in imperative programs with
    pre- and post-conditions, loop- and class-invariants as in Dafny and VCC
    provides a powerful, yet easy-to-use, modular and scalable approach to
    verified software development. Dafny and VCC implement this via translation
    of each program into another language, Boogie, built specifically for
    verification. Execution of programs is handled by a completely different
    code path, allowing for divergence between the two.

    We implement a prototype in an IMP-like language with the addition of
    functions. The only changes to the language semantics were the addition
    of a construct `#abstract` that replaces the program state with a more
    general symbolic state, and `assume` which adds constraints to that state.

Background
----------

KFramework

Implementation
--------------

- Solidity

  - Example tests

- Dafny
 
  - Side by side comparisons of code for exection vs verification semantics

Evaluation
----------

Dafny:

-   Tests from rise4fun

Solidity

-   ???

Future Work
-----------

-   Same specification can be used for fuzz testing when verification is insufficient

-   Invariant inference
-   Work with "forall quantification"
-   Extend to work with heaps
-   Prove correctness of verification engine / derive verification engine
    directly from semantics

Conclusion
----------


