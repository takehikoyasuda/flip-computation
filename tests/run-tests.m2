-- Run from the repository root:  M2 --script tests/run-tests.m2
loadPackage("FlipComputation", FileName => "FlipComputation.m2", Reload => true);
check FlipComputation;
print "all tests passed";
