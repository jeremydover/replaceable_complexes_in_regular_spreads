load "implementations/bakerEbertMixedNest.m";

bakerEbertMixedNestFlockReguliImplementation:=function(q,c,reguli);
	lambdaSNest:=bakerEbertMixedNestImplementation(q,c);
	if Type(lambdaSNest) eq RngIntElt then return 0; end if;
	if Type(reguli) ne SeqEnum then print "reguli must be a sequence."; return 0; end if;

	phi:=buildFieldStructures(q,2);
	K:=Domain(phi);
	F:=GF(q);
	M,chi:=VectorSpace(F,PrimeField(F));
	
	p:=PrimeDivisors(q)[1];
	if exists{x:x in reguli|x lt 0 or x ge p} then print "Every entry in reguli must be in the prime field of GF(q)."; return 0; end if;
	e:=Valuation(q,p);
	if (#reguli mod e) ne 0 then print "The regulus sequence must have length divisible by e, where q=p^e for prime p"; return 0; end if;
	
	vectors:=Partition(reguli,Dimension(M));
	c:=(M!c)@@chi;
	lambdaSReguli:=[];
	for x in vectors do
		a:=(M!x)@@chi;
		if a eq F!0 or not(IsSquare((a*c-1)^2-4*a)) then print "a does not represent a regulus disjoint from the nest."; return 0; end if;
		lambda,s:=convertRegulusLambdaABToLambdaS(K!0,a,1);
		Append(~lambdaSReguli,<lambda,s>);
	end for;
	return lambdaSNest cat lambdaSReguli;
end function;
