-- The small resolution of the three-dimensional ordinary double point.
--
-- X = V(x0 x1 - x2 x3) in P^4 is a threefold with a single singular point, at
-- which it is not Q-factorial.  Blowing up the divisorial ideal (x0, x2) of one
-- of the two planes through the singular point gives a small resolution.  This
-- is a flop rather than a flip -- K_X is Cartier here -- but it exercises the
-- same machinery: the Rees algebra, the normality test and the test for the
-- codimension of the exceptional locus.
--
-- Run from the repository root:  M2 --script examples/ordinary-double-point.m2

loadPackage("FlipComputation", FileName => "FlipComputation.m2", Reload => true);

R = QQ[x0,x1,x2,x3,x4]/ideal(x0*x1 - x2*x3);

<< "K_X = " << toString canonicalDivisorData R << endl;

P = bigradedReesProjection ideal(x0, x2);
<< P << endl;
<< "defining ideal of Z in P^1 x X:" << endl;
<< toString flatten entries gens P#definingIdeal << endl;
<< "Z is normal:      " << isNormalSource P << endl;
<< "pi is small:      " << isSmallProjection(P, Verbose => true) << endl;

G = b2mToGraphMorphism(P, Verbose => true);
<< G << endl;
<< "the monograded model of Z is Proj of" << endl;
<< toString describe G#sourceRing << endl;
