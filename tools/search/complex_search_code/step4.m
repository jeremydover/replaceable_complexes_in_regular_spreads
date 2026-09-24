load "library/Utils.m";
load "tools/search/complex_search_code/step1.out";
load "tools/search/complex_search_code/step3.out";
load "library/group-action.m";
SetAutoColumns(false);
SetColumns(0);

nests:=[{serializedCircleToCircle(x):x in WebCircles[i]}:i in [1..#WebCircles]];

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

calculateNestInvariantSignature:=function(nest);
  N:=SetToSequence(nest);
  dts:=dtsTypes(N);
  dtsN:=dtsNeighbors(N,dts);
  fingerprint:={**};
  for i in [1..#N] do
    Include(~fingerprint,<dts[i],dtsN[i]>);
  end for;
  return <#N,fingerprint>;
end function;

nestList:=AssociativeArray();
nestSort:=AssociativeArray();
for i in [1..#nests] do
  nestList[WebIDs[i]]:=nests[i];
  sig:=calculateNestInvariantSignature(nests[i]);
  if IsDefined(nestSort,sig) then
    nestSort[sig][WebIDs[i]]:=nests[i];
  else
    nestSort[sig]:=AssociativeArray();
	nestSort[sig][WebIDs[i]]:=nests[i];
  end if;
end for;

connectedComponents:=function(complex);
  covered:=&join complex;
  components:=[];
  while #covered gt 0 do
    thisComp:={};
	p:=Rep(covered);
	pencil:={x:x in complex|p in x};
	if #pencil eq 1 then
	  thisComp:=pencil;
	else
	  nest:=pencil;
	  covered1:=(&join nest) diff (&meet nest);
	  while #covered1 gt 0 do
	    p:=Rep(covered1);
		thisPencil:={x:x in complex|p in x and x notin nest};
		for y in thisPencil do
		  covered1:=covered1 sdiff y;
		  Include(~nest,y);
		end for;
	  end while;
	  thisComp:=nest;
	end if;
	covered diff:= &join thisComp;
	Append(~components,thisComp);
  end while;
  return components;
end function;

findID:=function(component);
  if #component eq 1 then return Sprintf("web-%o-1-0001",q);
  else
    m:=calculateNestInvariantSignature(component);
	myID:="";
	if IsDefined(nestSort,m) then
	  for thisID in Keys(nestSort[m]) do
	    if IsConjugate(G,CSet,component,nestSort[m][thisID]) then
		  myID:=thisID;
		  break;
		end if;
	  end for;
	end if;
	if #myID eq 0 then print "Could not find nest, likely not replaceable."; end if;
	return myID;
  end if;
end function;

exemplars:=AssociativeArray();
for id in Keys(C) do
  p:=Position(WebIDs,id);
  nest:={serializedCircleToCircle(x):x in WebCircles[p]};
  for x in C[id] do
    complex:=nest join SequenceToSet(x);
	comp:=connectedComponents(complex);
	compType:=[findID(comp[i]):i in [1..#comp]];
	sig:={* x:x in compType *};
	flag:=false;
	if IsDefined(exemplars,sig) then
	  for y in exemplars[sig] do
	    if IsConjugate(G,CSet,complex,&join y[1]) then 
		  flag:=true;
		  break;
		end if;
	  end for;
	  if not flag then
	    Append(~exemplars[sig],<comp,compType>);
	  end if;
	else
	  exemplars[sig]:=[<comp,compType>];
	end if;
  end for;
end for;

out:="tools/search/complex_search_code/step4.out";
i:=NextComplexID;
U,upsilon:=VectorSpace(F,PrimeField(F));
for k in Keys(exemplars) do
  for x in exemplars[k] do
	s:=Sprintf("{\"id\":\"complex-%o-%o%o\",\"q\":%o,\"components\":[",q,"0"^(5-#(IntegerToString(i))),i,q);

	infinity:=Position(P,V![0,1]);
	covered:= &join (&join x[1]);
	if infinity in covered then
	  uncovered:={1..q^2+1} diff covered;
	  p:=Rep(uncovered);
	  flag,psi:=IsConjugate(G,p,infinity);
	else
      psi:=G!1;
    end if;

	first:=true;
	for j in [1..#x[1]] do
	  if first then
	    first:=false;
	  else
	    s cat:= ",";
	  end if;
	  s cat:= Sprintf("{\"webID\":\"%o\",\"circles\":[",x[2][j]);
	  myCircles:=[circleReps[Position(circlePoints,Image(psi,y))]:y in x[1][j]];
	  thisFirst:=true;
	  for y in myCircles do
	    if thisFirst then
		  thisFirst:=false;
		else
		  s cat:= ",";
		end if;
		s cat:=Sprintf("%o",ElementToSequence(upsilon(y[1])) cat ElementToSequence(upsilon(y[2])));
	  end for;
	  s cat:= "]}";
    end for;
	s cat:= "]}";
	PrintFile(out,s);
	i+:=1;
  end for;
end for;
  
  