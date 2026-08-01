-- Algorithm 3: computing a flip.
--
-- Input: the homogeneous coordinate ring R of the target X of a flipping
-- contraction f : Y --> X.
-- Output: the flip g : Z --> X, as a B2M projection or as a graph morphism.
--
-- Steps 1-3 are carried out by flipDivisorData (see divisors.m2).  Steps 4-5
-- loop over m = 1!, 2!, 3!, ..., computing the Rees algebra R[I^(m)t] and testing
-- the two conditions of Lemma 7.2.

-- The schedule of multipliers for Step 4.
--
-- The paper runs over m = 1!, 2!, 3!, ..., and one m that works is as good as
-- another, so what matters is finding a small one: the cost of an iteration
-- grows very steeply in m, because the number of generators of I^(m) -- and
-- with it the number of variables of the Rees algebra -- grows with m.  On the
-- threefold of examples/toric-flip.m2 one iteration costs 0.02 s at m = 1,
-- 0.9 s at m = 6, 7 s at m = 8, and more than ten minutes at m = 12.
--
-- So we try every divisor of MaxSteps! in increasing order.  That still contains
-- 1!, 2!, ..., MaxSteps!, so the termination guarantee is unchanged, and filling
-- in the gaps is nearly free because the largest m tried dominates the total:
-- running all of 1, 2, 3, 4, 6, 8 above costs 8.5 seconds against more than 600
-- for m = 12 alone.
multiplierSchedule = method()
multiplierSchedule ZZ := n -> (
    if n < 1 then error "multiplierSchedule: expected a positive integer";
    ds := {1};
    scan(toList factor (n!), pe -> (
        p := pe#0;
        ds = flatten apply(ds, d -> apply(pe#1 + 1, i -> d * p^i));
        ));
    sort ds
    )

computeFlip = method(Options => {
        AntiCanonicalSection => null,
        Multipliers => null,
        MaxSteps => 4,
        ReturnGraph => false,
        BaseIsProjective => true,
        Verbose => true
        })
computeFlip Ring := o -> R -> (
    (s, Edata) := flipDivisorData(R,
        AntiCanonicalSection => o.AntiCanonicalSection,
        BaseIsProjective => o.BaseIsProjective);
    if o.Verbose then (
        if s === null
        then << "-- I = omega_X, embedded in R by a map of least degree" << endl
        else << "-- s = " << s << endl;
        << "-- E has " << #Edata << " component(s) with multiplicities "
           << toString apply(Edata, pe -> pe#1) << endl;
        );
    ms := if o.Multipliers === null then multiplierSchedule o.MaxSteps
        else toList o.Multipliers;
    for m in ms do (
        if o.Verbose then << "-- m = " << m << ":" << endl;
        Im := divisorialIdeal(Edata, m);
        P := bigradedReesProjection(Im, BaseIsProjective => o.BaseIsProjective);
        if o.Verbose then << "--   Z^m sits in P^" << #(P#fiberVariables) - 1
            << " x X, dim Z^m = " << geometricDimension P << endl;
        -- The exceptional locus is tested first, and not only because it is the
        -- cheaper of the two conditions: a small projection is automatically R1,
        -- so once it has passed, normality of Z^m reduces to S2 (see isS2Source).
        -- That turns the normality test from minutes into milliseconds.
        if not isSmallProjection(P, Verbose => o.Verbose) then (
            if o.Verbose then << "--   exceptional locus contains a divisor" << endl;
            continue;
            );
        if not isS2Source P then (
            if o.Verbose then << "--   Z^m is not S2, hence not normal" << endl;
            continue;
            );
        if o.Verbose then << "-- the flip is obtained for m = " << m << endl;
        return if o.ReturnGraph then b2mToGraphMorphism(P, Verbose => o.Verbose) else P;
        );
    error("computeFlip: none of the multipliers " | toString ms
        | " produced the flip; increase MaxSteps or supply Multipliers")
    )
