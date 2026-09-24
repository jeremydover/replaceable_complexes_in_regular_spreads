/*This library file contains Magma functions that implement conversion formats for regulus representations.*/

/*A note on data representation. Theoretically, it is typical to model the regular spread of PG(2n-1,q) as the field GF(q^n) plus the symbol infinity, using the inversive plane/circle geometry model of Bruck. However, representing field elements is problematic. For this dataset, we are choosing to use Magma's canonical field representation, taking a polynomial basis in its canonical primitive element. A table of minimal polynomials for these representations appears here:

GF(2^2): x^2 + x + 1
GF(2^3): x^3 + x + 1
GF(2^4): x^4 + x + 1
GF(2^5): x^5 + x^2 + 1
GF(2^6): x^6 + x^4 + x^3 + x + 1
GF(2^7): x^7 + x + 1
GF(2^8): x^8 + x^4 + x^3 + x^2 + 1
GF(2^9): x^9 + x^4 + 1
GF(2^10): x^10 + x^6 + x^5 + x^3 + x^2 + x + 1
GF(2^11): x^11 + x^2 + 1
GF(2^12): x^12 + x^7 + x^6 + x^5 + x^3 + x + 1
GF(2^13): x^13 + x^4 + x^3 + x + 1
GF(2^14): x^14 + x^7 + x^5 + x^3 + 1

GF(3^2): x^2 + 2*x + 2
GF(3^3): x^3 + 2*x + 1
GF(3^4): x^4 + 2*x^3 + 2
GF(3^5): x^5 + 2*x + 1
GF(3^6): x^6 + 2*x^4 + x^2 + 2*x + 2
GF(3^7): x^7 + 2*x^2 + 1
GF(3^8): x^8 + 2*x^5 + x^4 + 2*x^2 + 2*x + 2

GF(5^2): x^2 + 4*x + 2
GF(5^3): x^3 + 3*x + 3
GF(5^4): x^4 + 4*x^2 + 4*x + 2
GF(5^5): x^5 + 4*x + 3
GF(5^6): x^6 + x^4 + 4*x^3 + x^2 + 2

GF(7^2): x^2 + 6*x + 3
GF(7^3): x^3 + 6*x^2 + 4
GF(7^4): x^4 + 5*x^2 + 4*x + 3

GF(11^2): x^2 + 7*x + 2
GF(11^3): x^3 + 2*x + 9
GF(11^4): x^4 + 8*x^2 + 10*x + 2

GF(13^2): x^2 + 12*x + 2
GF(13^3): x^3 + 2*x + 11
GF(13^4): x^4 + 3*x^2 + 12*x + 2
*/

/*This function builds the basic field structures, and returns the mapping phi. The other structures can be easily recovered from phi via: K:=Domain(phi); V:=Image(phi); F:=PrimeField(K); */
buildFieldStructures:=function(q,d);
	K:=GF(q^d);
	F:=PrimeField(K);
	V,phi:=VectorSpace(K,F);
	return phi;
end function;

convertRegulusLambdaABToLambdaS:=function(lambda,a,b);
	K:=Parent(lambda);
	w:=PrimitiveElement(K);
	q:=Characteristic(K)^(Degree(K) div 2);
	V,phi:=VectorSpace(K,PrimeField(K));
	norms:=[Norm(w^i,GF(q)):i in [0..q-2]];
	if b eq K!0 then print "Circles containing infinity are not supported."; return 0,0; end if;
	if lambda^(q+1)+a*b eq 0 then print "The given lambda, a and b do not represent a circle inversion."; return 0,0; end if;
	l1:=lambda/b;
	ns:=Norm(l1,GF(q))+a/b;
	sPos:=Position(norms,ns)-1;
	s:=w^sPos;
	return l1,s;
end function;

convertRegulusLambdaSToSerialized:=function(lambda,s);
	K:=Parent(lambda);
	V,phi:=VectorSpace(K,PrimeField(K));
	return ElementToSequence(phi(lambda)) cat ElementToSequence(phi(s));
end function;

convertRegulusLambdaABToSerialized:=function(lambda,a,b);
	lambda,s:=convertRegulusLambdaABToLambdaS(lambda,a,b);
	return convertRegulusLambdaSToSerialized(lambda,s);
end function;

convertRegulusLambdaSToLambdaAB:=function(lambda,s);
	K:=Parent(lambda);
	q:=Characteristic(K)^(Degree(K) div 2);
	return lambda,s^(q+1)-lambda^(q+1),1;
end function;

convertRegulusSerializedToLambdaS:=function(phi,seq);
	if not(IsEven(#seq)) then print "Input regulus sequence is invalid...must have even length."; return 0,0; end if;
	seqLen:=#seq div 2;
	V:=Image(phi);
	K:=Domain(phi);
	w:=PrimitiveElement(K);
	q:=Characteristic(K)^(Degree(K) div 2);
	F:=GF(q);
	norms:=[Norm(w^i,F):i in [0..q-2]];
	lambda:=(V!seq[1..seqLen])@@phi;
	sRaw:=(V!seq[seqLen+1..#seq])@@phi;
	if sRaw eq K!0 then print "Value for s cannot be 0."; return 0,0; end if;
	sPos:=Position(norms,Norm(sRaw,F))-1;
	s:=w^sPos;
	return lambda,s;
end function;

convertRegulusSerializedToLambdaAB:=function(phi,seq);
	lambda,s:=convertRegulusSerializedToLambdaS(phi,seq);
	lambda,a,b:=convertRegulusLambdaSToLambdaAB(lambda,s);
	return lambda,a,b;
end function;

convertReguliSerializedToLambdaS:=function(phi,reguli);
	K:=Domain(phi);
	q:=Characteristic(K)^(Degree(K) div 2);
	F:=GF(q);
	V:=Image(phi);
	w:=PrimitiveElement(K);
	norms:=[Norm(w^i,F):i in [0..q-2]];
	vectors:=Partition(reguli,2*Dimension(V));
	
	lambdaSSeq:=[];
	for seq in vectors do
		lambda,s:=convertRegulusSerializedToLambdaS(phi,seq);
		Append(~lambdaSSeq,<lambda,s>);
	end for;
	return lambdaSSeq;
end function;

pivotFromInfinity:=function(phi,finiteCircles,infinityCircles);
	/*Map circles somewhere where infinity is not covered by the nest. Finite circles are given in lambda-S format. Infinite circles are the set of q field elements in the circle other than infinity.*/
	
	K:=Domain(phi);
	w:=PrimitiveElement(K);
	flag,q:=IsSquare(#K);
	
	nestCircles:=[{x[1]+x[2]*y:y in K|y^(q+1) eq 1}:x in finiteCircles];
	covered:=&join nestCircles join &join infinityCircles;
	ok:=Rep(Set(K) diff covered);
	f:=pmap<K->K|x:->ok*x/(x-ok)>;	/*Map sends ok to infinity, and infinity to ok*/
	newCircles:=[{f(x):x in circ}:circ in nestCircles] cat [{f(x):x in circ} join {ok}:circ in infinityCircles];
	nest:=[];
	findLS:=AssociativeArray();
	for lambda in K do
		for s in {w^i:i in {0..q-2}} do
			findLS[{lambda+s*x:x in K|x^(q+1) eq 1}]:=<lambda,s>;
		end for;
	end for;
	return [findLS[x]:x in newCircles];
end function;

checkLambdaSNest:=function(phi,N);
  K:=Domain(phi);
  q:=Characteristic(K)^(Degree(K) div 2);
  fN:=[{lS[1]+lS[2]*x:x in K|x^(q+1) eq 1}:lS in N];
  if #(SequenceToSet(fN)) ne #fN then
    print "Circle set has duplicate circle";
	return false;
  end if;
  covered:=&join fN;
  return forall{x:x in covered|#{y:y in fN|x in y} eq 2};
end function;