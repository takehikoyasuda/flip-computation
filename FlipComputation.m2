-- -*- coding: utf-8 -*-
newPackage(
    "FlipComputation",
    Version => "0.1.0",
    Date => "31 July 2026",
    Authors => {{
        Name => "Takehiko Yasuda",
        Email => "yasuda.takehiko.sci@osaka-u.ac.jp"
        }},
    Headline => "computing flips of threefolds",
    Keywords => {"Algebraic Geometry"},
    PackageImports => {
        "Divisor", "SymbolicPowers", "MinimalPrimes", "IntegralClosure",
        "Elimination", "Polyhedra"
        },
    AuxiliaryFiles => true,
    DebuggingMode => false
    )

-- This package implements Algorithm 3 (Computing a flip) of
--   T. Yasuda, An algorithm for the minimal model program in dimension three,
--   arXiv:2603.13703,
-- together with the constructions of Sections 2.2--2.4 that the algorithm
-- needs in order to present its output as a graph morphism.

export {
    -- types
    "B2MProjection",
    "GraphMorphism",
    -- Section 2
    "b2mProjection",
    "segreHilbertBasis",
    "segreProductRing",
    "b2mToGraphMorphism",
    "graphIdeal",
    "geometricDimension",
    "isProjectiveBase",
    "restrictToBase",
    -- Section 7, Steps 1--3
    "canonicalDivisorData",
    "antiCanonicalSection",
    "flipDivisorData",
    "divisorialIdeal",
    -- Section 7, Steps 4--5
    "singleDegreeIdeal",
    "uniformDegree",
    "bigradedReesIdeal",
    "bigradedReesProjection",
    "isSmallProjection",
    "isNormalSource",
    "isS2Source",
    "computeFlip",
    -- options
    "Section",
    "Multipliers",
    "MaxSteps",
    "ReturnGraph",
    "UniformDegree",
    "BaseIsProjective",
    -- keys of B2MProjection and GraphMorphism
    "ambientRing",
    "definingIdeal",
    "totalRing",
    "sourceRing",
    "baseRing",
    "fiberVariables",
    "baseVariables",
    "baseIsProjective",
    "irrelevantIdeal",
    "blownUpIdeal",
    "uniformDegreeUsed"
    }

-- Resolve the auxiliary files relative to this file, not to the directory M2 was
-- started in: check runs some tests in a scratch directory.
loadPart = f -> load(currentFileDirectory | "FlipComputation/" | f);
loadPart "basics.m2"
loadPart "divisors.m2"
loadPart "rees.m2"
loadPart "segre.m2"
loadPart "flip.m2"

beginDocumentation()
loadPart "doc.m2"

-- The small resolution of the three-dimensional ordinary double point: the
-- projection is normal and small.
TEST ///
  R = QQ[x0,x1,x2,x3,x4]/ideal(x0*x1-x2*x3);
  P = bigradedReesProjection ideal(x0,x2);
  assert(geometricDimension P == 3);
  assert(isNormalSource P);
  assert(isSmallProjection P);
///

-- Blowing up a point of P^3 is divisorial, so the smallness test must fail.
TEST ///
  R = QQ[x0,x1,x2,x3];
  P = bigradedReesProjection ideal(x0,x1,x2);
  assert(geometricDimension P == 3);
  assert(not isSmallProjection P);
///

-- K_{P^3} = -4H.
TEST ///
  R = QQ[x0,x1,x2,x3];
  K = canonicalDivisorData R;
  assert(#K == 1);
  assert(K#0#1 == -4);
///

-- The Segre product of two copies of P^1 has four generators; for P^1 x P(1,2)
-- the Hilbert basis is larger.
TEST ///
  assert(#segreHilbertBasis({1,1},{1,1}) == 4);
  assert(#segreHilbertBasis({1,1},{1,2}) == 5);
///

-- Transforming the B2M projection above into a graph morphism preserves the
-- dimension of the source.
TEST ///
  R = QQ[x0,x1,x2,x3,x4]/ideal(x0*x1-x2*x3);
  G = b2mToGraphMorphism bigradedReesProjection ideal(x0,x2);
  assert(dim(G#totalRing) - 2 == 3);
  assert(dim(G#sourceRing) - 1 == 3);
///

-- The same two projections over an affine base: the small resolution of the
-- affine ODP is normal and small, blowing up the origin of A^3 is not.
TEST ///
  R = QQ[x0,x1,x2,x3]/ideal(x0*x1-x2*x3);
  P = bigradedReesProjection(ideal(x0,x2), BaseIsProjective => false);
  assert(not isProjectiveBase P);
  assert(geometricDimension P == 3);
  assert(isNormalSource P);
  assert(isSmallProjection P);

  S = QQ[y0,y1,y2];
  Q = bigradedReesProjection(ideal(y0,y1,y2), BaseIsProjective => false);
  assert(geometricDimension Q == 3);
  assert(not isSmallProjection Q);
///

-- On a small projection R1 comes for free, so normality reduces to S2.  Check
-- the cheap test against the full one where the full one is still affordable.
TEST ///
  R = QQ[x0,x1,x2,x3]/ideal(x0*x1-x2*x3);
  P = bigradedReesProjection(ideal(x0,x2), BaseIsProjective => false);
  assert(isSmallProjection P);
  assert(isS2Source P);
  assert(isS2Source P == isNormalSource P);

  S = QQ[x0,x1,x2,x3,x4]/ideal(x0*x1-x2*x3);
  Q = bigradedReesProjection ideal(x0,x2);
  assert(isSmallProjection Q);
  assert(isS2Source Q == isNormalSource Q);

  -- a weighted projective base takes the same code path; there the test is
  -- sufficient rather than exact, but it is still implied by isNormalSource
  W = QQ[w0,w1,w2,w3, Degrees => {1,1,1,2}];
  V = bigradedReesProjection ideal(w0,w1);
  assert(isS2Source V);
  assert(not isNormalSource V or isS2Source V);
///

-- A genuine flip: the non-Q-Gorenstein toric threefold given by the cone on
-- v1 = (1,0,0), v2 = (0,1,0), v3 = (0,0,1), v4 = (1,1,-2), whose circuit
-- relation is v1 + v2 = 2 v3 + v4.  See examples/toric-flip.m2.
TEST ///
  rayList = {{1,0,0}, {0,1,0}, {0,0,1}, {1,1,-2}};
  sigma = coneFromVData transpose matrix rayList;
  HB = apply(hilbertBasis dualCone sigma, v -> flatten entries v);
  L = QQ[t1,t2,t3];
  S = QQ[y_1 .. y_(#HB)];
  R = S/ker map(L, S, apply(HB, h -> t1^(h#0) * t2^(h#1) * t3^(h#2)));
  assert(dim R == 3);

  -- K_X comes out as -D_1 - D_3 in terms of the torus-invariant divisors; that
  -- is -sum D_i up to the principal divisor div(y_1) = D_2 + D_4, which
  -- examples/toric-flip.m2 checks with the Divisor package.
  pairing = (h, v) -> sum apply(3, k -> h#k * v#k);
  Ds = apply(rayList, v -> trim ideal apply(
          select(toList(0 .. #HB-1), j -> pairing(HB#j, v) > 0), j -> R_j));
  K = canonicalDivisorData(R, BaseIsProjective => false);
  assert(#K == 2);
  assert(all(K, pn -> pn#1 == -1));
  assert(all(K, pn -> pn#0 == Ds#0 or pn#0 == Ds#2));
  assert(K#0#0 != K#1#0);

  -- Algorithm 3 succeeds already for m = 1 and gives a threefold in P^1 x X.
  P = computeFlip(R, BaseIsProjective => false, Multipliers => {1}, Verbose => false);
  assert(geometricDimension P == 3);
  assert(#(P#fiberVariables) == 2);

  -- The fibre over the torus fixed point is a curve, so pi is small.
  A = P#ambientRing;
  assert(dim(A/(P#definingIdeal + ideal P#baseVariables)) - 1 == 1);

  -- Both charts of Z are smooth of dimension three.
  assert(all(P#fiberVariables, v -> (
      Q := A/(P#definingIdeal + ideal(v - 1));
      dim Q == 3 and dim singularLocus Q == -1)));

  -- The fan of Z is the triangulation {v1,v3,v4}, {v2,v3,v4}, whose wall
  -- <v3,v4> carries the exceptional curve.
  r = #(P#fiberVariables);
  fexp = apply(first entries gens P#blownUpIdeal, f -> HB#(index f - r));
  taus = apply(#fexp, i -> intersection(sigma, coneFromHData matrix apply(
          select(toList(0 .. #fexp-1), j -> j != i),
          j -> apply(3, k -> fexp#j#k - fexp#i#k))));
  expected = {{0,2,3}, {1,2,3}} / (ix ->
      coneFromVData transpose matrix apply(ix, j -> rayList#j));
  assert(#taus == 2 and all(taus, T -> any(expected, U -> T == U)));

  -- K.C > 0 on the wall curve, so K_Z is pi-ample: this is the flip, not the
  -- flipping contraction it came from.
  rayset = C -> entries transpose rays C;
  wallRays = rayset intersection(taus#0, taus#1);
  outside = apply(taus, T -> first select(rayset T, v -> not member(v, wallRays)));
  rel = flatten entries gens ker transpose matrix (outside | wallRays);
  if rel#0 < 0 then rel = apply(rel, c -> -c);
  assert(-(sum rel) > 0);
///

-- A flip that needs m > 1: the cone on v1 = (1,0,0), v2 = (0,1,0), v3 = (0,0,1),
-- v4 = (1,3,-2), with circuit relation v1 + 3 v2 = 2 v3 + v4.  Here it is the
-- triangulation {v1,v2,v3}, {v1,v2,v4} that carries the pi-ample canonical
-- class, and it is singular: K_Z has index two, and m = 1 does not suffice.
-- See examples/toric-flip-index-two.m2.
TEST ///
  rayList = {{1,0,0}, {0,1,0}, {0,0,1}, {1,3,-2}};
  sigma = coneFromVData transpose matrix rayList;
  HB = apply(hilbertBasis dualCone sigma, v -> flatten entries v);
  L = QQ[t1,t2,t3];
  S = QQ[y_1 .. y_(#HB)];
  mono = h -> t1^(h#0) * t2^(h#1) * t3^(h#2);
  R = S/ker map(L, S, apply(HB, mono));
  assert(dim R == 3);

  -- m = 1 is rejected: the exceptional locus contains a divisor.
  (s, Edata) = flipDivisorData(R, BaseIsProjective => false);
  P1 = bigradedReesProjection(divisorialIdeal(Edata, 1), BaseIsProjective => false);
  assert(#(P1#fiberVariables) == 3);
  assert(not isSmallProjection P1);

  -- m = 2 gives the flip.
  P = computeFlip(R, BaseIsProjective => false, Multipliers => {1,2}, Verbose => false);
  assert(geometricDimension P == 3);
  assert(#(P#fiberVariables) == 2);
  assert(dim((P#ambientRing)/(P#definingIdeal + ideal P#baseVariables)) - 1 == 1);

  -- The fan of Z is {v1,v2,v3}, {v1,v2,v4}; one chart is A^3 and the other is
  -- the quotient singularity of index two.
  A = P#ambientRing;
  r = #(P#fiberVariables);
  toLattice = map(L, A, apply(r, i -> 1_L) | apply(HB, mono));
  gexp = apply(first entries gens P#blownUpIdeal, g -> first exponents toLattice g);
  taus = apply(#gexp, i -> intersection(sigma, coneFromHData matrix apply(
          select(toList(0 .. #gexp-1), j -> j != i),
          j -> apply(3, k -> gexp#j#k - gexp#i#k))));
  expected = {{0,1,2}, {0,1,3}} / (ix ->
      coneFromVData transpose matrix apply(ix, j -> rayList#j));
  assert(#taus == 2 and all(taus, T -> any(expected, U -> T == U)));
  charts = apply(P#fiberVariables, v -> (
      Q := A/(P#definingIdeal + ideal(v - 1));
      {dim Q, dim singularLocus Q == -1}));
  assert(all(charts, c -> c#0 == 3));
  assert(#select(charts, c -> c#1) == 1);

  -- K.C > 0 on the wall curve, so K_Z is pi-ample.
  rayset = C -> entries transpose rays C;
  wallRays = rayset intersection(taus#0, taus#1);
  outside = apply(taus, T -> first select(rayset T, v -> not member(v, wallRays)));
  rel = flatten entries gens ker transpose matrix (outside | wallRays);
  if rel#0 < 0 then rel = apply(rel, c -> -c);
  assert(-(sum rel) > 0);
///

end--
