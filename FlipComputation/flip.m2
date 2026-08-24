-- Algorithm 4: computing the relative canonical model.
--
-- Input: the homogeneous coordinate ring R of the target X of a flipping
-- contraction f : Y --> X.
-- Output: the flip g : Z --> X, as a B2M projection or as a graph morphism.
--
-- Steps 1-3 are carried out by flipDivisorData (see divisors.m2).  Steps 4-5
-- loop over m = 1, 2, 3, ..., computing the Rees algebra R[I^(m)t] and testing
-- the two conditions of Lemmas 6.6 and 6.7.
--
-- The multipliers are tried in the order the paper's Algorithm 4 states, m = 1,
-- 2, 3, ..., up to MaxMultiplier.  Finding a small m is what matters, because
-- the cost of an iteration grows very steeply in m: the number of generators of
-- I^(m) -- and with it the number of variables of the Rees algebra -- grows with
-- m, and on the threefold of examples/toric-flip.m2 one iteration costs 0.02 s
-- at m = 1, 0.9 s at m = 6, 7 s at m = 8, and more than ten minutes at m = 12.
-- Consecutive m is exactly the order that finds the smallest working one.
--
-- Earlier releases instead tried every divisor of MaxSteps!, because v2 of the
-- paper guaranteed termination only along m = 1!, 2!, 3!, ... and the divisors
-- of n! are the small values that keep those factorials in the list.  Lemma 6.6
-- carries no divisibility condition on m, so that detour is no longer needed --
-- and it was skipping values (5, 7, 9, ...) at which a cheap answer could have
-- been found, only to pay for a much larger m afterwards.
computeFlip = method(Options => {
        AntiCanonicalSection => null,
        Multipliers => null,
        MaxMultiplier => 24,
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
    ms := if o.Multipliers =!= null then toList o.Multipliers
        else (
            if not instance(o.MaxMultiplier,ZZ) or o.MaxMultiplier < 1 then
                error "computeFlip: MaxMultiplier must be a positive integer";
            toList (1..o.MaxMultiplier)
            );
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
        | " produced the relative canonical model; increase MaxMultiplier or "
        | "supply Multipliers")
    )
