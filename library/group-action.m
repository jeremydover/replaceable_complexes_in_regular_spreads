load "library/convert-format.m";
F<w>:=GF(q^2);
V:=VectorSpace(F,2);
G,P:=PGammaL(V);
baseCircle:={Position(P,V![1,f]):f in F|f^(q+1) eq 1};
circles:=Orbit(G,baseCircle);
CSet:=GSet(G,circles);
U,chi:=VectorSpace(F,PrimeField(F));

lambdaSToCircle:=function(lambda,s)
    return {Position(P,V![1,(F!lambda)+(F!s)*x]):x in F|x^(q+1) eq 1};
end function;

serializedCircleToCircle:=function(seq)
    lambda,s:=convertRegulusSerializedToLambdaS(chi,seq);
    if Type(lambda) eq RngIntElt then
        return 0;
    end if;
    return lambdaSToCircle(lambda,s);
end function;
