-- A flip that needs m > 1.
--
-- This is the companion to examples/toric-flip.m2, which see for the general
-- setup; here only what is different is spelled out.  Take the cone on
--
--     v1 = (1,0,0),  v2 = (0,1,0),  v3 = (0,0,1),  v4 = (1,3,-2),
--
-- whose circuit relation is
--
--     v1 + 3 v2 = 2 v3 + v4.
--
-- Again m = (1,1,1) is forced by v1, v2, v3 and gives m.v4 = 2, so
-- X = Spec k[sigma^v cap M] is not Q-Gorenstein.  The two triangulations are
--
--     T_+ : {v2,v3,v4}, {v1,v3,v4}   wall <v3,v4>,  K.C = -(1+3-2-1) = -1 < 0
--     T_- : {v1,v2,v3}, {v1,v2,v4}   wall <v1,v2>,  K.C = -(2+1-1-3) = +1 > 0
--
-- so this time it is T_- that carries the pi-ample canonical class: Y = T_+ is
-- the flipping contraction and Z = T_- is the flip.  The difference that matters
-- is that Z is now singular: <v1,v2,v4> has determinant -2, and no m in M has
-- m.v1 = m.v2 = m.v4 = 1 (that would need m = (1,1,3/2)), so K_Z is 2-Cartier
-- but not Cartier.  Its index is 2, and correspondingly m = 1 does not produce
-- the flip -- the blowup of I itself has a divisorial exceptional component --
-- while m = 2 does.  In examples/toric-flip.m2 the flip was smooth and m = 1
-- was already enough.
--
-- Run from the repository root:  M2 --script examples/toric-flip-index-two.m2

loadPackage("FlipComputation", FileName => "FlipComputation.m2", Reload => true);
needsPackage "Polyhedra";

rayList = {{1,0,0}, {0,1,0}, {0,0,1}, {1,3,-2}};
sigma = coneFromVData transpose matrix rayList;
HB = apply(hilbertBasis dualCone sigma, v -> flatten entries v);
L = QQ[t1,t2,t3];
S = QQ[y_1 .. y_(#HB)];
mono = h -> t1^(h#0) * t2^(h#1) * t3^(h#2);
R = S/ker map(L, S, apply(HB, mono));
<< "X = Spec R,  dim R = " << dim R << ",  R normal: " << isNormal R << endl;
<< "K_X = " << toString apply(canonicalDivisorData(R, BaseIsProjective => false),
    pn -> (pn#1, first entries gens pn#0)) << endl;

-- The loop over m actually runs here: m = 1 is rejected, m = 2 succeeds.
P = computeFlip(R, BaseIsProjective => false, Multipliers => {1,2});
<< endl << P << endl;
<< "I^(2) = " << P#blownUpIdeal << endl;

A = P#ambientRing;
u = P#fiberVariables;
r = #u;
fibre = trim (P#definingIdeal + ideal P#baseVariables);
<< "fibre over the fixed point has dimension " << dim(A/fibre) - 1 << endl;

-- The generators of I^(2) as lattice points, read off through R --> k[t].
toLattice = map(L, A, apply(r, i -> 1_L) | apply(HB, mono));
gexp = apply(first entries gens P#blownUpIdeal, g -> first exponents toLattice g);
<< "generators of I^(2) as lattice points: " << gexp << endl;

-- The fan of Z: the chart D_+(u_i) is Spec R[f_j/f_i], with cone
--     tau_i = {v in sigma : v.(m_j - m_i) >= 0 for all j}.
taus = apply(#gexp, i -> intersection(sigma, coneFromHData matrix apply(
        select(toList(0 .. #gexp-1), j -> j != i),
        j -> apply(3, k -> gexp#j#k - gexp#i#k))));
rayset = C -> entries transpose rays C;
<< endl << "the fan of Z has maximal cones" << endl;
scan(taus, T -> << "  " << rayset T << endl);
expected = {{0,1,2}, {0,1,3}} / (ix ->
    coneFromVData transpose matrix apply(ix, j -> rayList#j));
sameFan = (F, G) -> #F == #G and all(F, T -> any(G, U -> T == U));
<< "equals the expected triangulation {v1,v2,v3}, {v1,v2,v4}:  "
   << sameFan(taus, expected) << endl;

-- One chart is A^3, the other is the quotient singularity of index two.
scan(r, i -> (
    Q := A/(P#definingIdeal + ideal(u#i - 1));
    << "chart u_" << i+1 << " = 1:  dim " << dim Q
       << ",  smooth: " << (dim singularLocus Q == -1) << endl;
    ));

-- K.C > 0 on the wall curve, so K_Z is pi-ample.
wallRays = rayset intersection(taus#0, taus#1);
outside = apply(taus, T -> first select(rayset T, v -> not member(v, wallRays)));
rel = flatten entries gens ker transpose matrix (outside | wallRays);
if rel#0 < 0 then rel = apply(rel, c -> -c);
<< endl << "wall " << wallRays << ", relation " << rel
   << " on " << (outside | wallRays) << ",  K.C ~ " << -(sum rel) << endl;
