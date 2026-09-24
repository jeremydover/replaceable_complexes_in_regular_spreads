load "implementations/bakerEbertQMinusOneNest.m";

bakerEbertTwoQMinusOneNestImplementation:=function(q,b);
	if not(IsPrimePower(q)) then print "q is not a prime power"; return 0; end if;
	if IsEven(q) then print "q must be odd"; return 0; end if;
	
	lambdaSNest1:=bakerEbertQMinusOneNestImplementation(q,b);
	if Type(lambdaSNest1) eq RngIntElt then return 0; end if;
	lambdaSNest2:=bakerEbertQMinusOneNestImplementation(q,b:alt:=true);
	if Type(lambdaSNest2) eq RngIntElt then return 0; end if;
	
	return lambdaSNest1 cat lambdaSNest2;
end function;
