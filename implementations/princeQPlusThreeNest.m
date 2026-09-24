load "library/convert-format.m";

princeQPlusThreeNestImplementation:=function(q,a);
	if not(IsPrimePower(q)) then print "q is not a prime power"; return 0; end if;
	if IsEven(q) then print "q must be odd"; return 0; end if;
	
	phi:=buildFieldStructures(q,2);
	F:=Domain(phi);
	theta:=PrimitiveElement(F);
	delta:=theta^(q-1);
	H:={delta^i:i in [0..q]};
	
	if Type(a) eq RngIntElt then print "a must be a sequence, even if only length 1."; return 0; end if;
	if #a ne Degree(F) then print "The sequence for a is the wrong length for this field."; return 0; end if;
	
	M,chi:=VectorSpace(F,PrimeField(F));
	a:=(M!a)@@chi;
	if a^(q+1) in {F!0,F!1} or not(IsSquare(a)) then print "a must be a non-zero square with a^(q+1) not 1"; return 0; end if;
	
	targetCircle:={1+a*h:h in H};
	B:={theta^i:i in [0..q-2]|#(targetCircle meet {h*theta^i:h in H}) eq 1};
	lambdaSNest:=[<h,a>:h in H] cat [<0,b>:b in B];
	return lambdaSNest;
end function;
