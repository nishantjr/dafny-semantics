\newcommand {\K} {{$\mathbb{K}}}

A (mostly) Language Agnositc Approach to Language-Specific Verifiers
=======================================================================

Motivation
----------

The current approach to implementing languages in production takes an ad-hoc
approach with only an informal design natural language specification, if any.
Compilers and interepreters are then hand-written based on this. Implementation
of verifition engines must again be hand-written often leading to divergances in
their internal models. For example, VCC (a verifier for the C programming
language) and Dafny's verifier are implemented via a translation to Boogie,
whereas in normal usage, programs are compiled via an alternate implementation
(C, by compilers such as Visual Studio Compiler(???), gcc... ; Dafny via
translation to C\#). This approach allows the verifier and the
interpreter/compiler for these languages to diverge significantly.

The semantic-first approach to language development attempts to mitigate this
issue. Here, a formal specification of the language is written first. This
formal semantics is then used to derive a parser, interpreter, compiler,
deductive verifier etc in a mechanical, language-agnostic fashion. This approach
has been used, successfully, with the \K framework:

-   as the reference implementation/specification of a programming language
    (KEVM)
-   to implement highly non-trivial languages (C, Java script, Python)
-   to iteratively design a new programming language (IELE)
-   for commercial verification of programs (KEVM)

However, verification of programs using this automatically derived verifier
tends to requires a non-trivial knowledge of Matching Logic and Reachablity
Locic. Moreover, the specification is tied to intimate implementation details of
the small step specification of the language. This makes verification a
non-trivial and expensive endevour.

In this paper, we extend this approach:

-   programming languages tend to be implemented in ad-hoc fashion
-   verifiers tend compilers/interepreters are derived from different
    implementations leading to inconsistencies
-   semantics-first approach described in \[semantics-based-appraoch...\]
    attempts to solve this
-   however, these specifications are not user friendly. in particular, they
    require non-trivial experience with reachability logic, and tied to the the
    implementation details of the small-step semantics.
-   Here, we show that with mimimal modifications to existing small step
    semantic specification we can instantiate a static program verifier.
-   This instantiation is both easy to use by programmers and easy to implement
    by language designers
-   We instantiate these verifier with two languages -- an IMP-like language
    with functions and while loops and syntax a la Microsoft Research's Dafny,
    and with Solidity, a high-level language for writing smart contracts for the
    Ethereum Virtual Machine.

Future Work
-----------

-   Work with "forall quantification"
-   Extend to work with heaps


