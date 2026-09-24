SetAutoColumns(false);
SetColumns(0);
load "library/group-action.m";
load "library/Utils.m";
w:=PrimitiveElement(F);
K:=GF(q);
H:=sub<G|G![Position(P,Normalize(V![P[i][1],P[i][2]*w^(q+1)])):i in [1..#P]]>;
H2:=sub<H|H.1^2>;
M,chi:=VectorSpace(F,PrimeField(F));
bundle:=[{Position(P,V![0,1])} join {Position(P,V![1,k*w^i]):k in K}:i in [0..q]];

expandStitchNest:=function(N);
  return &join {IndexedSetToSet(Orbit(H2,CSet,n)):n in N};
end function;

convertCirclesToLambdaS:=function(N);
  infinity:=Position(P,V![0,1]);
  lsCircles:=[];
  infinityCircles:=[];
  for x in N do
    if infinity in x then
	  Append(~infinityCircles,{P[y][2]:y in x|y ne infinity});
	else
	  Append(~lsCircles,circleReps[Position(circlePoints,x)]);
	end if;
  end for;
  phi:=buildFieldStructures(q,2);
  if #infinityCircles gt 0 then
    return pivotFromInfinity(phi,lsCircles,infinityCircles);
  else
    return lsCircles;
  end if;
end function;

load "tools/search/stitch.out";

exemplars:=[];
sources:=[];
for x in N do
  n:=expandStitchNest(x);
  flag:=true;
  for e in exemplars do
    if IsConjugate(G,CSet,e,n) then flag:=false; break; end if;
  end for;
  if flag then
    Append(~exemplars,n);
	oCircles:=[];
	bCircles:=[PrimeField(F)| ];
	for c in x do
	  if #(Orbit(H2,CSet,c)) eq 1 then
	    bPos:=Position(bundle,c);
	    bCircles cat:= ElementToSequence(chi(w^(bPos-1)));
	  else
	    lS:=circleReps[Position(circlePoints,c)];
	    oCircles cat:= ElementToSequence(chi(lS[1])) cat ElementToSequence(chi(lS[2]));
	  end if;
	end for;
	Append(~sources,<oCircles,bCircles>);
  end if;
end for;
  
load "library/web-discovery.m";
for i in [1..#exemplars] do
  flag,nest:=IdentifyWeb(convertCirclesToLambdaS(exemplars[i]));
  str:="{\"web\":\"";
  str cat:= Sprintf("%o\",\"source\":\"bundleStitchedNest\",\"instance\":{\"q\":%o,",nest,q);
  str cat:= Sprintf("\"orbit_circles\":%o,\"bundle_circles\":%o}}",sources[i][1],sources[i][2]);
  print str;
end for;
