-- Sections 2.2 and 2.6: Segre products and the passage from a B2M projection to a
-- graph morphism of monograded varieties.

-- Hilbert basis of the monoid
--   A = {(b,a) in N^(n+1) x N^(m+1) : sum d_j b_j = sum c_i a_i}
-- of Lemma 2.3, whose elements give the monomial generators of the Segre product
-- k[y] # k[x].
segreHilbertBasis = method()
segreHilbertBasis (List, List) := (ds, cs) -> (
    N := #ds + #cs;
    eqs := matrix {ds | apply(cs, c -> -c)};
    C := coneFromHData(id_(ZZ^N), eqs);
    apply(hilbertBasis C, v -> flatten entries v)
    )

-- The Segre product of two graded polynomial rings with weights ds and cs,
-- returned as a polynomial ring k[z_1..z_s] mapping onto it, together with the
-- exponent vectors of the corresponding monomials.
segreProductRing = method()
segreProductRing (Ring, List, List) := (kk, ds, cs) -> (
    HB := segreHilbertBasis(ds, cs);
    zdegs := apply(HB, v -> sum apply(#ds, j -> ds#j * v#j));
    zz := getSymbol "z";
    T := kk(monoid [zz_1 .. zz_(#HB), Degrees => zdegs]);
    (T, HB, zdegs)
    )

-- Lemma 2.6.  Given a strict B2M projection Z --> X with Z contained in Y x X,
-- we present Z as a monograded variety W (via the Segre isomorphism) and compute
-- the graph of the induced morphism W --> X as a bigraded variety in W x X.
--
-- Concretely, if the Segre generators are the monomials u^b x^a, then the graph
-- is cut out by the kernel of
--     k[z, x] --> k[u,x]/p,   z_k |--> u^(b_k) x^(a_k),  x_i |--> x_i,
-- which is the ideal xi^(-1)(p) of the proof of Lemma 2.6.
b2mToGraphMorphism = method(Options => {Verbose => false})
b2mToGraphMorphism B2MProjection := o -> P -> (
    A := P#ambientRing;
    U := P#totalRing;
    R := P#baseRing;
    us := P#fiberVariables;
    xs := P#baseVariables;
    ds := apply(us, v -> (degree v)#0);
    cs := apply(xs, v -> (degree v)#1);
    kk := coefficientRing A;
    (T, HB, zdegs) := segreProductRing(kk, ds, cs);
    if o.Verbose then << "-- Segre product has " << #HB << " generators" << endl;
    uU := apply(us, v -> sub(v, U));
    xU := apply(xs, v -> sub(v, U));
    mons := apply(HB, v -> (
        product apply(#us, j -> uU#j ^ (v#j)) * product apply(#xs, i -> xU#i ^ (v#(#us + i)))));
    -- the monograded coordinate ring of Z
    sigma := map(U, T, mons);
    q := ker sigma;
    W := T/q;
    if o.Verbose then << "-- monograded model computed" << endl;
    -- the graph inside W x X
    zz := getSymbol "z";
    AR := ambient R;
    G := kk(monoid [zz_1 .. zz_(#HB), gens AR,
            Degrees => apply(zdegs, d -> {d, 0}) | apply(cs, c -> {0, c}),
            Heft => {1, 1}]);
    xi := map(U, G, mons | xU);
    gI := ker xi;
    zs := take(gens G, #HB);
    ys := take(gens G, {#HB, #HB + numgens AR - 1});
    new GraphMorphism from {
        ambientRing => G,
        definingIdeal => gI,
        totalRing => G/gI,
        sourceRing => W,
        baseRing => R,
        fiberVariables => zs,
        baseVariables => ys,
        irrelevantIdeal => bigradedIrrelevantIdeal(zs, ys)
        }
    )

-- The bihomogeneous ideal defining the graph.
graphIdeal = method()
graphIdeal GraphMorphism := G -> G#definingIdeal
