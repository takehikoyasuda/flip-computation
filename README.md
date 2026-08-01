# FlipComputation

A Macaulay2 implementation of the algorithm for computing flips described in
Section 7 of

> T. Yasuda, *An algorithm for the minimal model program in dimension three*,
> [arXiv:2603.13703](https://arxiv.org/abs/2603.13703).

The package implements Algorithm 3 (Computing a flip) of that paper, together
with the auxiliary constructions from Sections 2.2--2.4 (Segre products, B2M
projections and graph morphisms) that the algorithm needs in order to return
its output as a graph morphism of monograded varieties.

## Status

Early development. The API is unstable.

## Requirements

* Macaulay2 (tested with 1.24.05 and 1.24.11)
* Bundled packages: `Divisor`, `SymbolicPowers`, `Polyhedra`,
  `IntegralClosure`, `MinimalPrimes`, `Elimination`

## Usage

From the repository root, install the package and its documentation once,

```
M2 -e 'installPackage "FlipComputation"'
```

after which it is available from anywhere:

```
M2 -e 'needsPackage "FlipComputation"'
M2 -e 'viewHelp FlipComputation'
```

The tests and the examples run against the sources in place and need no
installation:

```
M2 --script tests/run-tests.m2
M2 --script examples/toric-flip.m2
M2 --script examples/toric-flip-index-two.m2
```

`examples/toric-flip.m2` computes a genuine three-dimensional flip: the toric
threefold given by the cone on `(1,0,0)`, `(0,1,0)`, `(0,0,1)`, `(1,1,-2)`, which
is not Q-Gorenstein. `examples/toric-flip-index-two.m2` replaces the last ray by
`(1,3,-2)`, which makes the flip singular of index two and needs `m = 2`.
`examples/toric-flip-projective.m2` redoes the first one in the projective
setting of the paper and checks that it restricts to the affine answer.

Besides the paper's projective setting the package also accepts an affine base
(`BaseIsProjective => false`), which is what makes such local computations
cheap.

## Layout

| Path | Contents |
| --- | --- |
| `FlipComputation.m2` | package header, exports, documentation stubs |
| `FlipComputation/` | implementation split by topic |
| `examples/` | worked examples |
| `tests/` | regression tests |
| `IMPLEMENTATION.tex`, `.pdf` | technical note: the construction, the examples, and what they verify |
| `docs/` | notes relating the code to the paper, and the development plan |

The technical note [IMPLEMENTATION.pdf](IMPLEMENTATION.pdf) describes the
mathematics, the worked examples with their actual Macaulay2 output, and the
independent checks that the answers are compared against.  It is written in
LaTeX rather than markdown because GitHub's markdown renderer refuses
`\newcommand`, `\operatorname`, `\mathbb`, `\mathcal` and `\tag`, and eats the
backslash in `\,` and `\\`, which between them rule out macros, multi-line
formulas and equation numbers.  Rebuild it with

```
make
```

The Makefile pins `SOURCE_DATE_EPOCH`, so pdflatex does not stamp the build time
into the file and rebuilding an unedited source leaves the PDF byte-identical --
without it every rebuild would show up as a git change, and since a PDF is
already compressed, git cannot delta it and each such non-change would cost a
full copy in the history.  Bump the date in the Makefile when the note is
substantively revised.

`docs/implementation-notes.md` gives the line-by-line correspondence with the
paper and the measurements, and `docs/roadmap.ja.md` records what is planned
next.

## Use of AI

The code, the tests, and the technical note were written essentially by an AI
system (Claude), with edits by the author.  The author has read them and believes
them to be correct, but has not checked every detail.  The algorithm is the one
in the paper above and nothing conceptually difficult is attempted here, and each
example is checked automatically against independently known geometry — the
triangulations of a circuit, the sign of `K.C` on the wall curve, determinants of
cones, canonical classes of `P^3` and of a quadric threefold — so large errors are
unlikely.  It is a research prototype, not verified software.  One error that had
survived every existing test was in fact caught this way; see
[IMPLEMENTATION.pdf](IMPLEMENTATION.pdf).

## License

CC0 1.0 Universal (public domain dedication). See [LICENSE](LICENSE).
