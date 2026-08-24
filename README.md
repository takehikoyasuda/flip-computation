# FlipComputation

A Macaulay2 implementation of the algorithm for computing relative canonical
models described in Section 6 of

> T. Yasuda, *An algorithm for the minimal model program in dimension three*,
> [arXiv:2603.13703](https://arxiv.org/abs/2603.13703).

### 📖 [Read the manual](https://takehikoyasuda.github.io/flip-computation/)

Every function, type and field is documented with a worked example, run by
Macaulay2 with its real output shown, so what the package computes can be read
without installing anything.

The package implements Algorithm 4 (Computing the relative canonical model) of
that paper, together with the auxiliary constructions from Sections 2.4--2.5
(the `w`-diagonal, bi-to-mono projections and graph morphisms) that the
algorithm needs in order to return its output as a graph morphism of
monograded varieties.

When the contraction it is applied to is small, the relative canonical model is
the flip of that contraction, which is the case the worked examples below
exhibit.  "Flip" here is meant in the sense of Fujino, *Foundations of the
minimal model program*, Definition 4.8.2 and Lemma 4.8.3, which Remark 6.5 of
the paper cites precisely because neither makes any hypothesis on the relative
Picard number. It is **not** the narrower sense in which a flip is elementary,
or extremal, of relative Picard number one: the contractions this program
produces can belong to extremal faces of any dimension, and nothing here
computes a Picard number or a Mori cone. The entry point is therefore
`computeRelativeCanonicalModel`, not `computeFlip`.

The package and the repository keep the name they were published under: the
paper's Remark 6.12 gives this repository's URL, so renaming it would break
that citation. What the paper calls this implementation there is "one for
relative canonical models", which is what the API now says too.

Numbered results are cited by their v3 numbering throughout; earlier versions
number some of them differently, and v2 places this material in Section 7.

## Status

Early development. The API is unstable.

## Requirements

* Macaulay2 (tested with 1.24.05, 1.24.11 and 1.26.06)
* Bundled packages: `WeilDivisors`, `SymbolicPowers`, `Polyhedra`,
  `IntegralClosure`, `MinimalPrimes`, `Elimination`.  `WeilDivisors` was
  called `Divisor` through 1.24.

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
| `docs/` | notes relating the code to the paper, and the development plan |

The worked examples and their actual Macaulay2 output are documented in the
package manual.  Its front page groups the functions the way this README's
sections do, and every function, type and field has a runnable example.  Read
it with `viewHelp FlipComputation` once the package is installed, or build the
html without installing and open the printed `file://` link:

```
make docs
```

`make docs` reruns only the examples whose input changed; `make docs-all`
rebuilds everything.  Both fail if an example stops working.

It is also published, rebuilt from source on every push to `main`:

**<https://takehikoyasuda.github.io/flip-computation/>**

The generated html cannot simply be uploaded.  Macaulay2 writes these pages for
a local installation, with the stylesheet, the KaTeX scripts that render the
mathematics, and every link to a core Macaulay2 node given as absolute paths
into the M2 installation directory; served from anywhere else they come out
unstyled with dead links.  [`.github/make-site.sh`](.github/make-site.sh)
repairs that and adds a banner to every page saying this package is not part of
the Macaulay2 distribution, which is how a package's documentation would
otherwise come to be online.

`docs/implementation-notes.md` gives the line-by-line correspondence with the
paper and the measurements, and `docs/roadmap.ja.md` records what is planned
next.

## Use of AI

The code and the tests were written essentially by an AI system (Claude), with
edits by the author.  ChatGPT was also used during development, mainly for
design and algorithm discussion.  The author has read the AI-written material
and believes them to be correct, but has not checked every detail.  The
algorithm is the one in the paper above and nothing conceptually difficult is
attempted here, and each example is checked automatically against
independently known geometry — the triangulations of a circuit, the sign of
`K.C` on the wall curve, determinants of cones, canonical classes of `P^3` and
of a quadric threefold — so large errors are unlikely.  It is a research
prototype, not verified software.

## License

CC0 1.0 Universal (public domain dedication). See [LICENSE](LICENSE).
