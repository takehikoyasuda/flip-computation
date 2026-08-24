-- Sections 2.4 and 2.5: the w-diagonal and the passage from a bi-to-mono projection to a
-- graph morphism of monograded varieties.

-- Hilbert basis of the monoid
--   A = {(b,a) in N^(n+1) x N^(m+1) : sum d_j b_j = sum c_i a_i}
-- of Lemma 2.7, whose elements give the monomial generators of the Segre product
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

-- Choose an integral diagonal strictly inside the grading chamber of a
-- projective bi-to-mono projection.  If deg(u_j)=(p_j,e_j), deg(x_i)=(0,c_i), and
-- D>max(e_j/p_j), then a monomial u^b*x^a lies on the diagonal (n,Dn) exactly
-- when
--
--     sum_j (D*p_j-e_j)b_j = sum_i c_i*a_i,   n=sum_j p_j*b_j.
--
-- Thus the usual affine-semigroup/Hilbert-basis construction applies with the
-- positive transformed weights D*p_j-e_j, even when the fibre block is skew.
b2mDiagonalData = method()
b2mDiagonalData B2MProjection := P -> (
    if not isProjectiveBase P then error(
        "b2mDiagonalData: expected a projective base");
    us := P#fiberVariables;
    xs := P#baseVariables;
    firstWeights := apply(us,u -> (degree u)#0);
    shifts := apply(us,u -> (degree u)#1);
    if any(firstWeights,p -> p <= 0) then error(
        "b2mDiagonalData: fibre first weights must be positive");
    slope := max(1,1+max apply(#us,j -> ceiling(shifts#j/firstWeights#j)));
    transformedWeights := apply(#us,j ->
        slope*firstWeights#j-shifts#j);
    baseWeights := apply(xs,x -> (degree x)#1);
    if any(baseWeights,c -> c <= 0) then error(
        "b2mDiagonalData: base weights must be positive");
    HB := segreHilbertBasis(transformedWeights,baseWeights);
    coordinateDegrees := apply(HB,v ->
        sum apply(#us,j -> firstWeights#j*v#j));
    kk := coefficientRing P#ambientRing;
    zz := getSymbol "z";
    coordinateRing := kk(monoid [zz_1 .. zz_(#HB),
        Degrees => coordinateDegrees]);
    new HashTable from {
        "coordinateRing" => coordinateRing,
        "hilbertBasis" => HB,
        "coordinateDegrees" => coordinateDegrees,
        "diagonalSlope" => slope,
        "fiberFirstWeights" => firstWeights,
        "fiberShifts" => shifts,
        "transformedFiberWeights" => transformedWeights,
        "baseWeights" => baseWeights
        }
    )

-- Lemma 2.10.  Given a strict bi-to-mono projection Z --> X with Z contained in Y x X,
-- we present Z as a monograded variety W (via the Segre isomorphism) and compute
-- the graph of the induced morphism W --> X as a bigraded variety in W x X.
--
-- Concretely, if the Segre generators are the monomials u^b x^a, then the graph
-- is cut out by the kernel of
--     k[z, x] --> k[u,x]/p,   z_k |--> u^(b_k) x^(a_k),  x_i |--> x_i,
-- which is the ideal xi^(-1)(p) of the proof of Lemma 2.10.
b2mToGraphMorphism = method(Options => {Verbose => false})
b2mToGraphMorphism B2MProjection := o -> P -> (
    if not isProjectiveBase P then error(
        "b2mToGraphMorphism: the base must be projective; "
        | "a graph morphism of monograded varieties has no affine analogue here");
    A := P#ambientRing;
    U := P#totalRing;
    R := P#baseCoordinateRing;
    us := P#fiberVariables;
    xs := P#baseVariables;
    cs := apply(xs, v -> (degree v)#1);
    kk := coefficientRing A;
    diagonalData := b2mDiagonalData P;
    T := diagonalData#"coordinateRing";
    HB := diagonalData#"hilbertBasis";
    zdegs := diagonalData#"coordinateDegrees";
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
        baseCoordinateRing => R,
        fiberVariables => zs,
        baseVariables => ys,
        irrelevantIdeal => bigradedIrrelevantIdeal(zs, ys)
        }
    )

-- The bihomogeneous ideal defining the graph.
graphMorphismIdeal = method()
graphMorphismIdeal GraphMorphism := G -> G#definingIdeal
