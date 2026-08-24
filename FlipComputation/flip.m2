-- Algorithm 4: computing the relative canonical model.
--
-- Input: the homogeneous coordinate ring R of the target X of a projective
-- birational contraction f : Y --> X with f_* O_Y = O_X and -K_Y f-ample.
-- f is not assumed small.
-- Output: the relative canonical model g : Z --> X, as a B2M projection or
-- as a graph morphism.
--
-- Steps 1-3 are carried out by antiCanonicalDivisorData (see divisors.m2).
-- Steps 4-5 loop over m = 1, 2, 3, ..., computing the Rees algebra R[I^(m)t]
-- and testing the two conditions of Lemmas 6.6 and 6.7.
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
computeRelativeCanonicalModel = method(Options => {
        AntiCanonicalSection => null,
        Multipliers => null,
        MaxMultiplier => 24,
        ReturnGraph => false,
        BaseIsProjective => true,
        Verbose => true
        })
computeRelativeCanonicalModel Ring := o -> R -> (
    -- Validated before any work, so that a bad bound is reported even on the
    -- inputs that never reach the loop (K_X linearly trivial, below).
    if o.Multipliers === null
        and (not instance(o.MaxMultiplier,ZZ) or o.MaxMultiplier < 1) then
        error "computeRelativeCanonicalModel: MaxMultiplier must be a positive integer";
    (s, Edata) := antiCanonicalDivisorData(R,
        AntiCanonicalSection => o.AntiCanonicalSection,
        BaseIsProjective => o.BaseIsProjective);
    if o.Verbose then (
        if s === null
        then << "-- I = omega_X, embedded in R by a map of least degree" << endl
        else << "-- s = " << s << endl;
        << "-- E has " << #Edata << " component(s) with multiplicities "
           << toString apply(Edata, pe -> pe#1) << endl;
        );
    -- Step 3 of Algorithm 4 stops with the identity as soon as I^(m) has a
    -- single minimal generator.  E = 0 is that case at m = 1: K_X is linearly
    -- trivial, every I^(m) is the unit ideal, and the relative canonical model
    -- is the identity of X.  (This is a flop, so there is no flip; the relative
    -- canonical model exists all the same and is what is returned.)  For m > 1
    -- no special case is needed: a principal I^(m) -- K_X torsion of order m --
    -- makes the Rees algebra R[u], whose projection is already an isomorphism,
    -- so the small and S_2 tests below accept it and the loop returns it.
    if #Edata == 0 then (
        if o.Verbose then << "-- K_X is linearly trivial, so the relative "
            << "canonical model is the identity of X" << endl;
        Pid := bigradedReesProjection(ideal 1_R,
            BaseIsProjective => o.BaseIsProjective);
        return if o.ReturnGraph
            then b2mToGraphMorphism(Pid, Verbose => o.Verbose) else Pid;
        );
    ms := if o.Multipliers =!= null then toList o.Multipliers
        else toList (1..o.MaxMultiplier);
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
        if o.Verbose then << "-- the relative canonical model is obtained for "
            << "m = " << m << endl;
        return if o.ReturnGraph then b2mToGraphMorphism(P, Verbose => o.Verbose) else P;
        );
    error("computeRelativeCanonicalModel: none of the multipliers " | toString ms
        | " produced the relative canonical model; increase MaxMultiplier or "
        | "supply Multipliers")
    )
