load "implementations/bakerEbertQMinusOneNest.m";

bakerEbertQMinusOneNestBundleRegulusImplementation:=function(q,b,mu);
	lambdaSNest:=bakerEbertQMinusOneNestImplementation(q,b);
	if Type(lambdaSNest) eq RngIntElt then return 0; end if;
	
	phi:=buildFieldStructures(q,2);	
	V:=Image(phi);
	K:=Domain(phi);
	w:=PrimitiveElement(K);
	F:=GF(q);
	M,chi:=VectorSpace(F,PrimeField(F));

	if Type(mu) eq RngIntElt then print "mu must be a sequence, even if only length 1."; return 0; end if;
	if #mu ne Degree(K) then print "The sequence for mu is the wrong length for this field."; return 0; end if;
	mu:=(V!mu)@@phi;	
	b:=(M!b)@@chi;
	disc:=F!(1/4*Trace(mu,F)^2-(Norm(mu,F)*(1+b)));
	if (disc eq 0) or not(IsSquare(disc)) then print "mu does not represent a regulus disjoint from the nest"; return 0; end if;
	
	muCircle:={x:x in K|mu*x^q eq -(mu^q)*x}; /*This circle also contains infinity*/
	
	nest:=pivotFromInfinity(phi,lambdaSNest,[muCircle]);
	return nest;
end function;
