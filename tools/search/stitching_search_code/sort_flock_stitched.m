load "library/group-action.m";
load "library/Utils.m";
w:=PrimitiveElement(F);
H:=sub<G|G![Position(P,Normalize(V![P[i][1],P[i][2]*w^(q-1)])):i in [1..#P]]>;
H2:=sub<H|H.1^2>;
M,chi:=VectorSpace(F,PrimeField(F));

expandStitchNest:=function(N);
  return &join {IndexedSetToSet(Orbit(H2,CSet,n)):n in N};
end function;

convertCirclesToLambdaS:=function(N);
  return [circleReps[Position(circlePoints,x)]:x in N];
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
	fCircles:=[PrimeField(F)| ];
	for c in x do
	  lS:=circleReps[Position(circlePoints,c)];
	  if #(Orbit(H2,CSet,c)) eq 1 then
	    fCircles cat:= ElementToSequence(chi(lS[2]));
	  else
	    oCircles cat:= ElementToSequence(chi(lS[1])) cat ElementToSequence(chi(lS[2]));
	  end if;
	end for;
	Append(~sources,<oCircles,fCircles>);
  end if;
end for;
  
load "library/web-discovery.m";
for i in [1..#exemplars] do
  flag,nest:=IdentifyWeb(convertCirclesToLambdaS(exemplars[i]));
  str:="{\"web\":\"";
  str cat:= Sprintf("%o\",\"source\":\"flockStitchedNest\",\"instance\":{\"q\":%o,",nest,q);
  str cat:= Sprintf("\"orbit_circles\":%o,\"flock_circles\":%o}}",sources[i][1],sources[i][2]);
  print str;
end for;