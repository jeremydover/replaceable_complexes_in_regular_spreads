load "library/convert-format.m";

ebertQPlusOneNestImplementation:=function(q,c);
	if not(IsPrimePower(q)) then print "q is not a prime power"; return 0; end if;
	if IsEven(q) then print "q must be odd"; return 0; end if;
	
	phi:=buildFieldStructures(q,2);
	K:=Domain(phi);
	F:=GF(q);
	w:=PrimitiveElement(K);
	alpha:=w^(q-1);
	
	if Type(c) eq RngIntElt then print "c must be a sequence, even if only length 1."; return 0; end if;
	if #c ne Degree(F) then print "The sequence for c is the wrong length for this field."; return 0; end if;
	
	M,chi:=VectorSpace(F,PrimeField(F));
	c:=(M!c)@@chi; /*c is in GF(q),not GF(q^2)*/
	if IsSquare(c+1) then print "c+1 must be a nonsquare"; return 0; end if;
	
	lambda,s:=convertRegulusLambdaABToLambdaS(K!1,F!1,c);
	lambdaSNest:=[<lambda*alpha^i,s*alpha^i>:i in [0..q]];
	
	return lambdaSNest;
end function;
