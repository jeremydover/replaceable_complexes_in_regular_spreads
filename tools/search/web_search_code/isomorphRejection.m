load "tools/search/web_search_code/createBlocks.m";
SetAutoColumns(false);
SetColumns(0);

exemplars:=AssociativeArray();

dtsTypes:=function(N);
  dts:=[[0,0,0]:x in N];
  for i in [1..#N] do
    for j in [(i+1)..#N] do
      m:=#(N[i] meet N[j]);
      dts[i][m+1]+:=1;
      dts[j][m+1]+:=1;
    end for;
  end for;
  return dts;
end function;

dtsNeighbors:=function(N,dts);
  dtsN:=[[[],[],[]]:x in N];
  for i in [1..#N] do
    for j in [(i+1)..#N] do
      m:=#(N[i] meet N[j]);
      dtsN[i][m+1]:=Append(dtsN[i][m+1],dts[j]);
      dtsN[j][m+1]:=Append(dtsN[j][m+1],dts[i]);
    end for;
    for j in [1..3] do
      Sort(~dtsN[i][j]);
    end for;
  end for;
  return dtsN;
end function;
 
calculateInvariantSignature:=function(nest);
  N:=SetToSequence(nest);
  dts:=dtsTypes(N);
  dtsN:=dtsNeighbors(N,dts);
  fingerprint:={**};
  for i in [1..#N] do
    Include(~fingerprint,<dts[i],dtsN[i]>);
  end for;
  return <#N,fingerprint>;
end function;

nestCount:=0;
conjCount:=0;

F:=Open("nests.out","r");
line:=Gets(F);
while not IsEof(line) do
  x:=eval line;
  nestCount +:= 1;
  invar:=calculateInvariantSignature(x);
  if IsDefined(exemplars,invar) then
    flag:=false;
    for y in exemplars[invar] do
      flag:=IsConjugate(G,CSet,x,y);
	  conjCount +:= 1;
      if flag then break; end if;
    end for;
    if not flag then
      Append(~exemplars[invar],x);
    end if;
  else
    exemplars[invar]:=[x];
  end if;
  line:=Gets(F);
end while;

delete F;

printf "Processed %o nests.\n",nestCount;
printf "Executed %o conjugations.\n",conjCount;

allNests:=&cat [exemplars[x]:x in Keys(exemplars)];
printf "Found %o isomorphism classes.\n",#allNests;
Sort(~allNests,func<x,y|#x-#y>);
/* Write nests in Magma loadable format. */
outfile:="tools/search/web_search_code/nests.m";
PrintFile(outfile,"nests:=[":Overwrite:=true);
first:=true;
for i in [1..#allNests] do
  str:="";
  if first then
    first:=false;
  else
    str cat:= ",";
  end if;
  str cat:= Sprintf("%o",allNests[i]);
  PrintFile(outfile,str);
end for;
PrintFile(outfile,"];");

load "library/Utils.m";
infinity:=Position(P,V![0,1]);
U,chi:=VectorSpace(F,PrimeField(F));
c1:={f:f in F|f^(q+1) eq 1};
circlePoints:=[];
circleSeqs:=[];
for lambda in F do
  for s in [w^i:i in [0..q-2]] do
    Append(~circlePoints,{Position(P,V![1,lambda+s*x]):x in c1});
    Append(~circleSeqs,ElementToSequence(chi(lambda)) cat ElementToSequence(chi(s)));
  end for;
end for;

outfile:="input4webs.jsonl";

/* Write out nest records for web.jsonl. */
for i in [1..#allNests] do
  str:=Sprintf("{\"id\":\"web-%o-2-%o%o\",\"q\":%o,\"invariants\":{",q,"0"^(4-#IntegerToString(i)),i,q);
  H:=Stabilizer(G,CSet,allNests[i]);
  Op:=Orbits(H);
  covered:=&join allNests[i];
  pF:=Sort([#x:x in Op|Rep(x) in covered]);
  Oc:=Orbits(H,CSet);
  cF:=Sort([#x:x in Oc|Rep(x) in allNests[i]]);
  str cat:= Sprintf("\"t\":2,\"circleCount\":%o,\"stabilizerGroupSize\":%o,\"pointOrbits\":%o,\"circleOrbits\":%o},",#allNests[i],Order(H),pF,cF);
  bruckReplaceable:=pg3BruckReplaceable(allNests[i]);
  str cat:= Sprintf("\"replaceability\":{\"bruck\":%o,\"hemi\":",bruckReplaceable);
  hemiReplaceable:=bruckReplaceable select true else pg3HemiReplaceable(allNests[i]);
  str cat:= Sprintf("%o},",hemiReplaceable);
  str cat:= "\"circles\":[";
  if infinity in covered then
    uncovered:=Rep({1..q^2+1} diff covered);
    flag,theta:=IsConjugate(G,uncovered,infinity);
	assert flag;
    N:=Image(theta,CSet,allNests[i]);
  else
    N:=allNests[i];
  end if;
  first:=true;
  for c in N do
    p:=Position(circlePoints,c);
    if first then
      first:=false;
    else
      str cat:=",";
    end if;
    str cat:= Sprintf("%o",circleSeqs[p]);
  end for;
  str cat:="]}";
  PrintFile(outfile,str);
end for;
