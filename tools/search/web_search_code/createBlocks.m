K:=GF(q);
F<w>:=GF(q^2);
V:=VectorSpace(F,2);
G,P:=PGammaL(V);
circ:={Position(P,V![0,1])} join {Position(P,V![1,x]):x in K};
circleset:=Orbit(G,circ);
CSet:=GSet(G,circleset);
circles:=[x:x in circleset];