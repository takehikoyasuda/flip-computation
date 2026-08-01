-- Algorithm 3: computing a flip.
--
-- Input: the homogeneous coordinate ring R of the target X of a flipping
-- contraction f : Y --> X.
-- Output: the flip g : Z --> X, as a B2M projection or as a graph morphism.
--
-- Steps 1-3 are carried out by flipDivisorData (see divisors.m2).  Steps 4-5
-- loop over m = 1!, 2!, 3!, ..., computing the Rees algebra R[I^(m)t] and testing
-- the two conditions of Lemma 7.2.

computeFlip = method(Options => {
        Section => null,
        Multipliers => null,
        MaxSteps => 4,
        ReturnGraph => false,
        BaseIsProjective => true,
        Verbose => true
        })
computeFlip Ring := o -> R -> (
    (s, Edata) := flipDivisorData(R,
        Section => o.Section, BaseIsProjective => o.BaseIsProjective);
    if o.Verbose then (
        if s === null
        then << "-- I = omega_X, embedded in R by a map of least degree" << endl
        else << "-- s = " << s << endl;
        << "-- E has " << #Edata << " component(s) with multiplicities "
           << toString apply(Edata, pe -> pe#1) << endl;
        );
    ms := if o.Multipliers === null
        then toList apply(1 .. o.MaxSteps, e -> e!)
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
