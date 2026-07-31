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

* Macaulay2 (tested with 1.24.05)
* Bundled packages: `Divisor`, `SymbolicPowers`, `ReesAlgebra`, `Polyhedra`,
  `IntegralClosure`, `MinimalPrimes`, `Elimination`

## Usage

```
M2 -e 'needsPackage("FlipComputation", FileName => "FlipComputation.m2")'
```

or, from the repository root,

```
M2 --script tests/run-tests.m2
```

## Layout

| Path | Contents |
| --- | --- |
| `FlipComputation.m2` | package header, exports, documentation stubs |
| `FlipComputation/` | implementation split by topic |
| `examples/` | worked examples |
| `tests/` | regression tests |
| `docs/` | notes relating the code to the paper, and the development plan |

See `docs/implementation-notes.md` for the correspondence with the paper and
`docs/roadmap.ja.md` for what is planned next.

## License

To be decided before the repository is made public.
