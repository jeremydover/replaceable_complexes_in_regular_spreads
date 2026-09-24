load "library/convert-format.m";
load "implementations/bruenChain.m";

for i in [1..19] do
  n,q:=bruenChainImplementation(i);
  phi:=buildFieldStructures(q,2);
  assert checkLambdaSNest(phi,n);
  assert #n eq (q+3) div 2;
end for;
print "PASS: all 19 Bruen chains validated.";