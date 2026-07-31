-- Steps 1--3 of Algorithm 3: the canonical divisor of X, a homogeneous element s
-- with -K_X + div(s) effective, and the ideal sheaf O_X(K_X - div(s)) together
-- with its symbolic powers.

-- Step 1.  K_X = sum n_i D_i, returned as a list of pairs {p_i, n_i} where p_i is
-- the height-one homogeneous prime of R defining D_i.  The canonical module is
-- computed by the Divisor package as Ext^t(R, omega) (Section 3).
canonicalDivisorData = method()
canonicalDivisorData Ring := R -> (
    K := canonicalDivisor(R, IsGraded => true);
    select(apply(primes K, p -> {p, coefficient(p, K)}), pn -> pn#1 != 0)
    )

-- Step 2.  A homogeneous element s of prod_i p_i^max(0,n_i), so that
-- -K_X + div(s) is effective.  Among the generators of that product we take one
-- of least degree.
antiCanonicalSection = method()
antiCanonicalSection Ring := R -> antiCanonicalSection(R, canonicalDivisorData R)
antiCanonicalSection (Ring, List) := (R, Kdata) -> (
    pos := select(Kdata, pn -> pn#1 > 0);
    M := if #pos == 0 then ideal 1_R else product apply(pos, pn -> (pn#0)^(pn#1));
    cands := select(first entries gens trim M, g -> g != 0);
    if #cands == 0 then error "antiCanonicalSection: no nonzero homogeneous element found";
    cands#(minPosition apply(cands, g -> (degree g)#0))
    )

-- Step 3.  With E := div(s) - K_X, which is effective by the choice of s, the
-- ideal sheaf O_X(K_X - div(s)) = O_X(-E) is represented by the divisorial ideal
-- of E.  Returns the pair (s, {{p_i, e_i}, ...}) describing E.
flipDivisorData = method(Options => {Section => null})
flipDivisorData Ring := o -> R -> (
    Kdata := canonicalDivisorData R;
    s := if o.Section === null then antiCanonicalSection(R, Kdata) else o.Section;
    K := canonicalDivisor(R, IsGraded => true);
    E := if s == 1_R then -K else divisor(s) - K;
    Edata := select(apply(primes E, p -> {p, coefficient(p, E)}), pe -> pe#1 != 0);
    if any(Edata, pe -> pe#1 < 0) then error(
        "flipDivisorData: div(s) - K_X is not effective; supply a different Section");
    (s, Edata)
    )

-- The divisorial ideal O_X(-mE) = intersect_i p_i^(m e_i), which is the symbolic
-- power I^(m) of Step 5.
divisorialIdeal = method()
divisorialIdeal (List, ZZ) := (Edata, m) -> (
    if #Edata == 0 then error "divisorialIdeal: empty divisor data";
    R := ring first first Edata;
    parts := select(apply(Edata, pe -> {pe#0, m * pe#1}), pe -> pe#1 > 0);
    if #parts == 0 then ideal 1_R
    else trim intersect apply(parts, pe -> (
        if pe#1 == 1 then pe#0 else symbolicPower(pe#0, pe#1)))
    )
