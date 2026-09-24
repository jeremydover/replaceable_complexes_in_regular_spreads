load "implementations/bakerEbertQMinusOneNest.m";

bakerEbertQMinusOneNestCompanionRegulusImplementation:=function(q,b);
	lambdaSNest:=bakerEbertQMinusOneNestImplementation(q,b);
	if Type(lambdaSNest) eq RngIntElt then return 0; end if;

	phi:=buildFieldStructures(q,2);	
	K:=Domain(phi);
	V:=Image(phi);
	F:=GF(q);
	w:=PrimitiveElement(K);
	epsilon:=w^((q+1) div 2);
	M,chi:=VectorSpace(F,PrimeField(F));
	b:=(M!b)@@chi;
	ll,s:=convertRegulusLambdaABToLambdaS(epsilon,epsilon^2*(1+b),1);
	return lambdaSNest cat [<ll,s>];

end function;
