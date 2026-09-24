load "library/convert-format.m";

bundleStitchedNestImplementation:=function(q,orbit_circles,bundle_circles);
	if not(IsPrimePower(q)) then print "q is not a prime power"; return 0; end if;
	if IsEven(q) then print "q must be odd"; return 0; end if;
	phi:=buildFieldStructures(q,2);
	K:=Domain(phi);
	M,chi:=VectorSpace(K,PrimeField(K));
	w:=PrimitiveElement(K);
	F:=GF(q);
	alpha:=w^(2*(q+1));
	
	if Type(orbit_circles) ne SeqEnum then print "orbit_circles must be a sequence."; return 0; end if;
	if #orbit_circles eq 0 then print "There must be at least one circle in orbit_circles."; return 0; end if;
	p:=PrimeDivisors(q)[1];
	if exists{x:x in orbit_circles|x lt 0 or x ge p} then print "Every entry in orbit_circles must be in the prime field of GF(q)."; return 0; end if;
	e:=Valuation(q,p);
	if (#orbit_circles mod 4*e) ne 0 then print "The orbit_circles sequence must have length divisible by 4e, where q=p^e for prime p"; return 0; end if;
	
	lambdaSOrbitCircles:=convertReguliSerializedToLambdaS(phi,orbit_circles);
	lambdaSPartial:=[<x[1]*alpha^i,x[2]*alpha^i>:i in [0..(q-3) div 2],x in lambdaSOrbitCircles];
	
	if Type(bundle_circles) ne SeqEnum then print "bundle_circles must be a sequence."; return 0; end if;
	if exists{x:x in bundle_circles|x lt 0 or x ge p} then print "Every entry in bundle_circles must be in the prime field of GF(q)."; return 0; end if;
	if (#bundle_circles mod 2*e) ne 0 then print "The bundle_circles sequence must have length divisible by 2e, where q=p^e for prime p"; return 0; end if;
	
	if #bundle_circles ne 0 then
	  infinity_circles:=[];
	  vectors:=Partition(bundle_circles,2*e);
	  for seq in vectors do
		d:=(M!seq)@@chi;
		if d eq K!0 then
		  print "A bundle circle parameter is 0. Failing construction.";
		  return 0;
		end if;
		Append(~infinity_circles,{f*d:f in F});
	  end for;
	  lambdaSNest:=pivotFromInfinity(phi,lambdaSPartial,infinity_circles);
	else
	  lambdaSNest:=lambdaSPartial;
	end if;
	
	if #lambdaSNest gt 0 and checkLambdaSNest(phi,lambdaSNest) then
      return lambdaSNest;
	else
	  print "Construction did not yield a nest.";
	  return 0;
	end if;
end function;
