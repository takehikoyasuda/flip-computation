-- The same flip as examples/toric-flip.m2, but in the setting of the paper:
-- X is projective, given as Proj of a graded ring, and the flip is computed
-- with the default BaseIsProjective => true.
--
-- The affine threefold X_aff = Spec k[sigma^v cap M] of examples/toric-flip.m2
-- is compactified as follows.  Every element of the Hilbert basis of
-- sigma^v cap M pairs to 1 with l = (1,1,-1), so the grading that gives each
-- y_i degree one is induced by a torus character; the toric ideal is homogeneous
-- for it, and
--
--     X_proj = Proj k[y_1,...,y_5,w]/I   in P^5,   deg w = 1,
--
-- is a threefold with D_+(w) = Spec R = X_aff.  Only one variable is added.
--
-- X_proj is again toric: writing N' = N + Z and projecting the rays of
-- tau = sigma x R_{>=0} along v = (1,1,-1,1) by (a,b,c,d) |-> (a-d, b-d, c+d)
-- gives the fan with rays
--
--     u1 = (1,0,0)  u2 = (0,1,0)  u3 = (0,0,1)  u4 = (1,1,-2)  u5 = (-1,-1,1)
--
-- and maximal cones <u1,u2,u3,u4> (which is sigma, that is D_+(w)) together
-- with <u5,F> for the four facets F of sigma.  Since -u5 = (1,1,-1) is interior
-- to sigma those four cones complete the fan, and each of them has determinant
-- +-1.  So X_proj is smooth away from the torus fixed point of sigma, and its
-- only singularity is the non-Q-Gorenstein point we want to flip.  Retriangulating
-- sigma as <u1,u3,u4>, <u2,u3,u4> leaves all six cones smooth, so the flip
-- Z_proj is a smooth projective toric threefold.
--
-- Run from the repository root:  M2 --script examples/toric-flip-projective.m2

loadPackage("FlipComputation", FileName => "FlipComputation.m2", Reload => true);
needsPackage "Polyhedra";

rayList = {{1,0,0}, {0,1,0}, {0,0,1}, {1,1,-2}};
HB = apply(hilbertBasis dualCone coneFromVData transpose matrix rayList,
    v -> flatten entries v);
<< "Hilbert basis: " << HB << endl;
<< "degrees for l = (1,1,-1): "
   << apply(HB, h -> h#0 + h#1 - h#2) << "  (so the standard grading works)" << endl;

L = QQ[t1,t2,t3];
S0 = QQ[y_1 .. y_(#HB)];
I0 = ker map(L, S0, apply(HB, h -> t1^(h#0) * t2^(h#1) * t3^(h#2)));

-- X_proj in P^5, and X_aff for comparison
S = QQ[y_1 .. y_(#HB), w];
R = S/sub(I0, S);
Raff = S0/I0;
<< "X_proj = Proj R,  dim = " << dim R - 1 << ",  R normal: " << isNormal R << endl;

-- the only singularity is the vertex [0:...:0:1]
sl = ideal singularLocus R;
<< "singular locus is the vertex [0:...:0:1]: "
   << (radical sl == ideal take(gens S, #HB)) << endl;

<< endl << "-- the flip, over the projective base --" << endl;
P = computeFlip R;
<< endl << P << endl;
<< "I = " << P#blownUpIdeal << ",  uniform degree used = "
   << P#uniformDegreeUsed << endl;

-- the affine computation of examples/toric-flip.m2
Paff = computeFlip(Raff, BaseIsProjective => false, Verbose => false);
<< "affine I was " << Paff#blownUpIdeal << endl;
<< "the two differ by the principal factor y_1^2, which does not change the"
   << endl << "blowup: Bl_{fJ} X = Bl_J X for f a nonzerodivisor." << endl;

A = P#ambientRing;
us = P#fiberVariables;
xs = P#baseVariables;

-- the exceptional locus is a curve over the vertex
fib = trim (P#definingIdeal + ideal take(xs, #HB));
<< endl << "fibre over the vertex has dimension " << dim(A/fib) - 2 << endl;

-- Z_proj is smooth, as the fan predicts
charts = select(flatten apply(us, u -> apply(xs, x -> (
    Q := A/(P#definingIdeal + ideal(u - 1, x - 1));
    if dim Q < 0 then null else {dim Q, dim singularLocus Q == -1}))), c -> c =!= null);
<< "Z_proj: " << #charts << " nonempty charts, dimensions "
   << unique apply(charts, c -> c#0)
   << ", all smooth: " << all(charts, c -> c#1) << endl;

-- the local check: on D_+(w) this is exactly the affine flip
Zw = trim (P#definingIdeal + ideal(last xs - 1));
phi = map(A, Paff#ambientRing, us | take(xs, #HB));
Zaff = trim (phi(Paff#definingIdeal) + ideal(last xs - 1));
<< endl << "Z_proj restricted to D_+(w) equals the affine flip: "
   << (Zw == Zaff) << endl;
