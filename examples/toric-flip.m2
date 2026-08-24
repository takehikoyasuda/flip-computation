-- A genuine three-dimensional flip, computed over an affine base.
--
-- Let N = Z^3 and let sigma be the cone spanned by
--
--     v1 = (1,0,0),  v2 = (0,1,0),  v3 = (0,0,1),  v4 = (1,1,-2).
--
-- The four rays satisfy the circuit relation
--
--     v1 + v2 = 2 v3 + v4,
--
-- and no m in M has m.v_i = 1 for all i (that would force m = (1,1,1), for which
-- m.v4 = 0), so X = Spec k[sigma^v cap M] is a threefold that is *not*
-- Q-Gorenstein: K_X is not Q-Cartier.  This is the situation Algorithm 4 is
-- meant for, and unlike the ordinary double point it is a flip rather than a
-- flop.
--
-- The two triangulations of the circuit give the two small modifications of X:
--
--     Y : {v1,v2,v3}, {v1,v2,v4}   wall <v1,v2>,   K.C = -(2+1-1-1) = -1 < 0
--     Z : {v1,v3,v4}, {v2,v3,v4}   wall <v3,v4>,   K.C = -(1+1-2-1) = +1 > 0
--
-- (the wall relation is the circuit relation, read with the two rays outside the
-- wall on the positive side, and K = -sum D_i).  So Y --> X is the flipping
-- contraction and Z --> X is its flip, which is what computeRelativeCanonicalModel must return.
-- Note that both cones of Z have determinant +-1, so Z is smooth, whereas
-- <v1,v2,v4> has determinant -2, so Y is singular.
--
-- Since sigma contains the three standard basis vectors, sigma^v lies in the
-- positive octant and the toric ideal can be computed as an honest kernel.
--
-- Run from the repository root:  M2 --script examples/toric-flip.m2

loadPackage("FlipComputation", FileName => "FlipComputation.m2", Reload => true);
needsPackage "Polyhedra";
needsPackage "WeilDivisors";

rayList = {{1,0,0}, {0,1,0}, {0,0,1}, {1,1,-2}};
sigma = coneFromVData transpose matrix rayList;
HB = apply(hilbertBasis dualCone sigma, v -> flatten entries v);
<< "Hilbert basis of sigma^v cap M: " << HB << endl;

L = QQ[t1,t2,t3];
S = QQ[y_1 .. y_(#HB)];
mono = h -> t1^(h#0) * t2^(h#1) * t3^(h#2);
R = S/ker map(L, S, apply(HB, mono));
<< "X = Spec R,  dim R = " << dim R << ",  R normal: " << isNormal R << endl;

-- Step 1.  Compare the canonical divisor with the torus-invariant one.
pairing = (h, v) -> sum apply(3, k -> h#k * v#k);
Ds = apply(rayList, v -> trim ideal apply(
        select(toList(0 .. #HB-1), j -> pairing(HB#j, v) > 0), j -> R_j));
K = canonicalDivisorData(R, BaseIsProjective => false);
<< "K_X = " << toString apply(K, pn -> (pn#1, first entries gens pn#0)) << endl;
<< "the torus-invariant divisors are" << endl;
scan(#rayList, i -> << "  D_" << i+1 << " = " << Ds#i
    << "   (ray " << rayList#i << ")" << endl);
<< "K_X + sum D_i = div(y_1):  "
   << (canonicalDivisor(R, IsGraded => false) + sum apply(Ds, divisor)
       == divisor(R_0)) << endl;

-- Steps 2--5.
P = computeRelativeCanonicalModel(R, BaseIsProjective => false, Multipliers => {1,2});
<< endl << P << endl;
<< "blown up ideal I = O_X(-E): " << P#blownUpIdeal << endl;

-- The fibre over the torus fixed point is a curve, so pi is small and is not an
-- isomorphism: the exceptional locus is exactly that curve.
A = P#ambientRing;
fibre = trim (P#definingIdeal + ideal P#baseVariables);
<< "fibre over the fixed point has dimension "
   << dim(A/fibre) - 1 << " (and is cut out by " << fibre << ")" << endl;

-- The two charts of Z.  Each is smooth of dimension three.
u = P#fiberVariables;
scan(#u, i -> (
    C := trim (P#definingIdeal + ideal(u#i - 1));
    Q := A/C;
    << endl << "chart u_" << i+1 << " = 1:  dim " << dim Q
       << ",  smooth: " << (dim singularLocus Q == -1) << endl;
    << "  relations: " << C << endl;
    ));

-- The fan of Z, read off from the output.  The chart D_+(u_i) of
-- Proj_X (+)_k I^k is Spec R[f_j/f_i], so with f_i = chi^(m_i) its cone is
--     tau_i = {v in sigma : v.(m_j - m_i) >= 0 for all j}.
r = #u;
fexp = apply(first entries gens P#blownUpIdeal, f -> HB#(index f - r));
taus = apply(#fexp, i -> intersection(sigma, coneFromHData matrix apply(
        select(toList(0 .. #fexp-1), j -> j != i),
        j -> apply(3, k -> fexp#j#k - fexp#i#k))));
rayset = C -> entries transpose rays C;
<< endl << "the fan of Z has maximal cones" << endl;
scan(taus, T -> << "  " << rayset T << endl);
expected = {{0,2,3}, {1,2,3}} / (ix -> coneFromVData transpose matrix apply(ix, j -> rayList#j));
-- Cone is a hash table, so compare with == rather than with sets.
sameFan = (F, G) -> #F == #G and all(F, T -> any(G, U -> T == U));
<< "equals the expected triangulation {v1,v3,v4}, {v2,v3,v4}:  "
   << sameFan(taus, expected) << endl;

-- The wall, and the sign of K.C on the wall curve.  Writing the wall relation as
-- alpha a + beta b + gamma1 w1 + gamma2 w2 = 0 with the two rays a, b outside
-- the wall on the positive side, one has D_i.C proportional to the coefficient
-- of v_i, hence K.C proportional to -(alpha + beta + gamma1 + gamma2).
wall = intersection(taus#0, taus#1);
<< endl << "the wall is " << rayset wall << " (dimension " << dim wall
   << ", so the exceptional locus is a curve)" << endl;
signedRelation = (outside, inside) -> (
    rel := flatten entries gens ker transpose matrix (outside | inside);
    if rel#0 < 0 then rel = apply(rel, c -> -c);
    rel);
wallRays = rayset wall;
outsideZ = apply(taus, T -> first select(rayset T, v -> not member(v, wallRays)));
relZ = signedRelation(outsideZ, wallRays);
<< "Z: wall relation " << relZ << " on " << (outsideZ | wallRays)
   << ",  K.C ~ " << -(sum relZ) << endl;
relY = signedRelation(wallRays, outsideZ);
<< "Y: wall relation " << relY << " on " << (wallRays | outsideZ)
   << ",  K.C ~ " << -(sum relY) << endl;
<< endl << "K_Z is pi-ample and K_Y is pi-anti-ample, so Z is the flip of Y." << endl;
