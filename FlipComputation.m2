-- -*- coding: utf-8 -*-
newPackage(
    "FlipComputation",
    Version => "0.1.0",
    Date => "31 July 2026",
    Authors => {{
        Name => "Takehiko Yasuda",
        Email => "yasuda.takehiko.sci@osaka-u.ac.jp"
        }},
    Headline => "computing flips of threefolds",
    Keywords => {"Algebraic Geometry"},
    PackageImports => {
        "Divisor", "SymbolicPowers", "MinimalPrimes", "IntegralClosure",
        "Elimination", "Polyhedra"
        },
    AuxiliaryFiles => true,
    DebuggingMode => false
    )

-- This package implements Algorithm 3 (Computing a flip) of
--   T. Yasuda, An algorithm for the minimal model program in dimension three,
--   arXiv:2603.13703,
-- together with the constructions of Sections 2.2--2.4 that the algorithm
-- needs in order to present its output as a graph morphism.

export {
    -- types
    "B2MProjection",
    "GraphMorphism",
    -- Section 2
    "b2mProjection",
    "segreHilbertBasis",
    "segreProductRing",
    "b2mToGraphMorphism",
    "graphIdeal",
    "geometricDimension",
    "restrictToBase",
    -- Section 7, Steps 1--3
    "canonicalDivisorData",
    "antiCanonicalSection",
    "flipDivisorData",
    "divisorialIdeal",
    -- Section 7, Steps 4--5
    "singleDegreeIdeal",
    "uniformDegree",
    "bigradedReesIdeal",
    "bigradedReesProjection",
    "isSmallProjection",
    "isNormalSource",
    "computeFlip",
    -- options
    "Section",
    "Multipliers",
    "MaxSteps",
    "ReturnGraph",
    "UniformDegree",
    -- keys of B2MProjection and GraphMorphism
    "ambientRing",
    "definingIdeal",
    "totalRing",
    "sourceRing",
    "baseRing",
    "fiberVariables",
    "baseVariables",
    "irrelevantIdeal",
    "blownUpIdeal",
    "uniformDegreeUsed"
    }

load "FlipComputation/basics.m2"
load "FlipComputation/divisors.m2"
load "FlipComputation/rees.m2"
load "FlipComputation/segre.m2"
load "FlipComputation/flip.m2"

beginDocumentation()
load "FlipComputation/doc.m2"

-- The small resolution of the three-dimensional ordinary double point: the
-- projection is normal and small.
TEST ///
  R = QQ[x0,x1,x2,x3,x4]/ideal(x0*x1-x2*x3);
  P = bigradedReesProjection ideal(x0,x2);
  assert(geometricDimension P == 3);
  assert(isNormalSource P);
  assert(isSmallProjection P);
///

-- Blowing up a point of P^3 is divisorial, so the smallness test must fail.
TEST ///
  R = QQ[x0,x1,x2,x3];
  P = bigradedReesProjection ideal(x0,x1,x2);
  assert(geometricDimension P == 3);
  assert(not isSmallProjection P);
///

-- K_{P^3} = -4H.
TEST ///
  R = QQ[x0,x1,x2,x3];
  K = canonicalDivisorData R;
  assert(#K == 1);
  assert(K#0#1 == -4);
///

-- The Segre product of two copies of P^1 has four generators; for P^1 x P(1,2)
-- the Hilbert basis is larger.
TEST ///
  assert(#segreHilbertBasis({1,1},{1,1}) == 4);
  assert(#segreHilbertBasis({1,1},{1,2}) == 5);
///

-- Transforming the B2M projection above into a graph morphism preserves the
-- dimension of the source.
TEST ///
  R = QQ[x0,x1,x2,x3,x4]/ideal(x0*x1-x2*x3);
  G = b2mToGraphMorphism bigradedReesProjection ideal(x0,x2);
  assert(dim(G#totalRing) - 2 == 3);
  assert(dim(G#sourceRing) - 1 == 3);
///

end--
