-- Steps 1--3 of Algorithm 3: the canonical divisor of X, a homogeneous element s
-- with -K_X + div(s) effective, and the ideal sheaf O_X(K_X - div(s)) together
-- with its symbolic powers.
--
-- The option BaseIsProjective distinguishes X = Proj R (the paper) from
-- X = Spec R; it only controls whether the WeilDivisors package is asked to work
-- with graded or with arbitrary data.

-- Step 1.  K_X = sum n_i D_i, returned as a list of pairs {p_i, n_i} where p_i is
-- the height-one prime of R defining D_i.  The canonical module is computed by
-- the WeilDivisors package as Ext^t(R, omega) (Section 3).
canonicalDivisorData = method(Options => {BaseIsProjective => true})
canonicalDivisorData Ring := o -> R -> (
    K := canonicalDivisor(R, IsGraded => o.BaseIsProjective);
    select(apply(primes K, p -> {p, coefficient(p, K)}), pn -> pn#1 != 0)
    )

-- Step 2.  An element s of prod_i p_i^max(0,n_i), so that -K_X + div(s) is
-- effective.  Among the generators of that product we take one of least degree.
antiCanonicalSection = method(Options => {BaseIsProjective => true})
antiCanonicalSection Ring := o -> R ->
    antiCanonicalSection(R, canonicalDivisorData(R, BaseIsProjective => o.BaseIsProjective))
antiCanonicalSection (Ring, List) := o -> (R, Kdata) -> (
    pos := select(Kdata, pn -> pn#1 > 0);
    M := if #pos == 0 then ideal 1_R else product apply(pos, pn -> (pn#0)^(pn#1));
    cands := select(first entries gens trim M, g -> g != 0);
    if #cands == 0 then error "antiCanonicalSection: no nonzero element found";
    cands#(minPosition apply(cands, g -> (degree g)#0))
    )

-- Steps 2 and 3 together amount to embedding omega_X into R as an ideal: the
-- ideal I = O_X(K_X - div(s)) of Step 3 is isomorphic to omega_X, and every
-- ideal isomorphic to omega_X arises this way.  So instead of choosing s and
-- then forming the ideal, look directly for the embedding of least degree, that
-- is for a nonzero homomorphism omega_X --> R of least degree.
--
-- This matters a great deal.  The element s produced by antiCanonicalSection is
-- at the mercy of which representative of the canonical class the WeilDivisors
-- package happens to return, and that depends on the grading: on the threefold
-- of examples/toric-flip-projective.m2 the representative has a coefficient of
-- 11 once the ring is graded by (2,2,1), the least s in prod p_i^n_i then has
-- degree 22, and I^(1) lands in degree 30.  The embedding of least degree gives
-- generators of degree 2 instead, and the whole computation drops from
-- "unfinished after seventeen minutes" to a twentieth of a second.
canonicalIdeal = method()
canonicalIdeal Ring := R -> (
    S := ambient R;
    dl := apply(first entries vars S, q -> (degree q)#0);
    om := (Ext^(dim S - dim R)(S^1/(ideal R), S^{-(sum dl)})) ** R;
    H := Hom(om, R^1);
    if numgens H == 0 then error(
        "canonicalIdeal: the canonical module does not embed into R");
    ds := apply(numgens H, i -> (degrees H)#i#0);
    trim ideal matrix homomorphism H_{minPosition ds}
    )

-- Step 3.  E is the divisor with I = O_X(-E); it is effective because I is an
-- ideal of R, and -E is linearly equivalent to K_X because I is isomorphic to
-- omega_X.  Returns the pair (s, {{p_i, e_i}, ...}) describing E, where s is the
-- section used if one was, and null when the embedding route was taken.
flipDivisorData = method(Options => {
        AntiCanonicalSection => null, BaseIsProjective => true})
flipDivisorData Ring := o -> R -> (
    local E;
    s := o.AntiCanonicalSection;
    if s === null then (
        I := canonicalIdeal R;
        if I == ideal 1_R then error(
            "flipDivisorData: omega_X is free, so K_X is linearly trivial and "
            | "there is no flip to compute (this is a flop)");
        E = divisor I;
        ) else (
        K := canonicalDivisor(R, IsGraded => o.BaseIsProjective);
        E = if s == 1_R then -K else divisor(s) - K;
        );
    Edata := select(apply(primes E, p -> {p, coefficient(p, E)}), pe -> pe#1 != 0);
    if #Edata == 0 then error(
        "flipDivisorData: E is zero, so there is no flip to compute");
    if any(Edata, pe -> pe#1 < 0) then error(
        "flipDivisorData: div(s) - K_X is not effective; "
        | "supply a different AntiCanonicalSection");
    (s, Edata)
    )

-- The divisorial ideal O_X(-mE), which is the symbolic power I^(m) of Step 5.
--
-- Mathematically this is intersect_i p_i^(m e_i), but computing it that way
-- through SymbolicPowers is ruinous: the saturations blow up with m, taking 3.2
-- seconds at m = 8 on the threefold of examples/toric-flip.m2 and far worse
-- beyond.  The WeilDivisors package builds O_X(-D) from products of ordinary powers
-- and a reflexive hull instead, which on the same example is about 0.006
-- seconds and essentially flat in m.  The two agree.
divisorialIdeal = method()
divisorialIdeal (List, ZZ) := (Edata, m) -> (
    if #Edata == 0 then error "divisorialIdeal: empty divisor data";
    R := ring first first Edata;
    parts := select(apply(Edata, pe -> {pe#0, m * pe#1}), pe -> pe#1 > 0);
    if #parts == 0 then ideal 1_R
    else trim ideal divisor(apply(parts, pe -> pe#1), apply(parts, pe -> pe#0))
    )
