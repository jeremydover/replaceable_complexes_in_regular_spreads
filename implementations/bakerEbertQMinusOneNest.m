load "library/convert-format.m";

bakerEbertQMinusOneNestImplementation:=function(q,b:alt:=false);
	if not(IsPrimePower(q)) then print "q is not a prime power"; return 0; end if;
	if IsEven(q) then print "q must be odd"; return 0; end if;
	
	phi:=buildFieldStructures(q,2);
	V:=Image(phi);
	K:=Domain(phi);
	F:=GF(q);
	w:=PrimitiveElement(K);
	epsilon:=w^((q+1) div 2);
	
	if Type(b) eq RngIntElt then print "b must be a sequence, even if only length 1."; return 0; end if;
	if #b ne Degree(F) then print "The sequence for b is the wrong length for this field."; return 0; end if;
	
	M,chi:=VectorSpace(F,PrimeField(F));
	b:=(M!b)@@chi; /*b is in GF(q),not GF(q^2)*/
	if b eq F!0 or b eq F!(-1) or not(IsSquare(b*(b+1))) then print "b(b+1) must be a nonzero square"; return 0; end if;
	if not(alt) then
		lambda,s:=convertRegulusLambdaABToLambdaS(K!1,F!1,b);
	else
		lambda,s:=convertRegulusLambdaABToLambdaS(epsilon,(b+1)*epsilon^2,1);
	end if;
	lambdaSNest:=[<lambda*x,s*x>:x in F|x ne F!0];
	return lambdaSNest;
end function;
