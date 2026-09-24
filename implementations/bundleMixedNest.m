load "library/convert-format.m";

bundleMixedNestImplementation:=function(q,b);
	if not(IsPrimePower(q)) then print "q is not a prime power"; return 0; end if;
	if IsEven(q) then print "q must be odd"; return 0; end if;
	
	phi:=buildFieldStructures(q,2);
	V:=Image(phi);
	K:=Domain(phi);
	F:=GF(q);
	w:=PrimitiveElement(K);
	alpha:=w^(q+1);
	
	if Type(b) eq RngIntElt then print "b must be a sequence, even if only length 1."; return 0; end if;
	if #b ne Degree(F) then print "The sequence for b is the wrong length for this field."; return 0; end if;
	
	M,chi:=VectorSpace(F,PrimeField(F));
	b:=(M!b)@@chi; /*b is in GF(q),not GF(q^2)*/
	if b eq F!0 or b eq F!(-1) or not(IsSquare(b*(b+1))) then print "b(b+1) must be a nonzero square"; return 0; end if;
	lambda,s:=convertRegulusLambdaABToLambdaS(K!1,F!1,b);
	lambdaSNest:=[<lambda*alpha^(2*i),s*alpha^(2*i)>:i in [0..(q-3) div 2]]; /*Circles in the bundle orbit*/
	nestCircles:=[{ls[1]+ls[2]*x:x in K|x^(q+1) eq 1}:ls in lambdaSNest];
	infinityCircles:={{x*f:f in F}:x in K|#{n:n in nestCircles|x in n} eq 1};
	if #infinityCircles ne 2 then print "Construction requires too many bundle circles to form a nest."; return 0; end if;
	return pivotFromInfinity(phi,lambdaSNest,infinityCircles);
end function;
