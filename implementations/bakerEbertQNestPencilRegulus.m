load "implementations/bakerEbertQNest.m";

bakerEbertQNestPencilRegulusImplementation:=function(q,a);
	lambdaSNest:=bakerEbertQNestImplementation(q);
	if Type(lambdaSNest) eq RngIntElt then return 0; end if;
	
	phi:=buildFieldStructures(q,2);
	K:=Domain(phi);
	F:=GF(q);
	w:=PrimitiveElement(K);
	epsilon:=w^((q+1) div 2);
	
	if Type(a) eq RngIntElt then print "a must be a sequence, even if only length 1."; return 0; end if;
	if #a ne Degree(F) then print "The sequence for a is the wrong length for this field."; return 0; end if;
	U,chi:=VectorSpace(F,PrimeField(F));
	a:=(U!a)@@chi;
	
	M:=MatrixAlgebra(K,2);
	C:=a eq 0 select M![1,0,0,-1] else M![a,1,0,-a];
	D:=(q mod 4) eq 3 select M![epsilon,epsilon^2-1,1,epsilon] else M![epsilon,0,1,epsilon];
	disc:=F!(1/4*(Determinant(C+D)-Determinant(C)-Determinant(D))^2 - Determinant(C)*Determinant(D));
	if not(IsSquare(disc)) then print "a does not determine a circle disjoint from the nest"; return 0; end if;
	
	aCircle:={x:x in K|C[1][1]*x^q+C[1][2] eq x*(C[2][1]*x^q+C[2][2])}; /*This circle also contains infinity*/
	
	nest:=pivotFromInfinity(phi,lambdaSNest,[aCircle]);
	return nest;
end function;
