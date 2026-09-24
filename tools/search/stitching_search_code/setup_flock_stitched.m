load "library/group-action.m";
K:=GF(q);
w:=PrimitiveElement(F);
carriers:={Position(P,V![1,0]),Position(P,V![0,1])};
flock:=[{Position(P,V![1,x]):x in F|x^(q+1) eq k}:k in K|k ne 0];
G1:=sub<G|G![Position(P,Normalize(V![P[i][1],P[i][2]*w])):i in [1..#P]]>;
H:=sub<G|G![Position(P,Normalize(V![P[i][1],P[i][2]*w^(q-1)])):i in [1..#P]]>;
H2:=sub<H|H.1^2>;
O:=Orbits(H2,CSet);

/* Find the full orbits first. Need to exclude those that contain a carrier.*/
orbitReps:=[];
for x in O do
  if #x eq Order(H2) and #(Rep(x) meet carriers) eq 0 then
    Append(~orbitReps,Rep(x));
  end if;
end for;

O2:=Orbits(H2);

outfile:="tools/search/stitchcircles.txt";
first:=true;
for x in orbitReps do
  if first then
	PrintFile(outfile,Sprintf("%o",x):Overwrite:=true);
	first:=false;
  else
    PrintFile(outfile,Sprintf("%o",x));
  end if;
end for;

outfile:="tools/search/carriedcircles.txt";
first:=true;
for x in flock do
  if first then
	PrintFile(outfile,Sprintf("%o",x):Overwrite:=true);
	first:=false;
  else
    PrintFile(outfile,Sprintf("%o",x));
  end if;
end for;

outfile:="tools/search/stitchorbits.txt";
first:=true;
for x in O2 do
  if first then
	PrintFile(outfile,Sprintf("%o",IndexedSetToSet(x)):Overwrite:=true);
	first:=false;
  else
    PrintFile(outfile,Sprintf("%o",IndexedSetToSet(x)));
  end if;
end for;
