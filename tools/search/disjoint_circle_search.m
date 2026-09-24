F<w>:=GF(q^2);
V:=VectorSpace(F,2);
G,psi:=PGammaL(V);
C:={Position(psi,V![1,f]):f in F|f^(q+1) eq 1};
circles:=Orbit(G,C);
Y:=GSet(G,circles);
circleReps:=[<lambda,w^i>:lambda in F,i in {0..q-2}];
circlePoints:=[{Position(psi,V![1,circleReps[i][1]+f*circleReps[i][2]]):f in F|f^(q+1) eq 1}:i in [1..#circleReps]];

disjoint:=[[{C}]];
for j in [2..q-1] do
	sizeC:=[];
	for x in disjoint[#disjoint] do
		covered:=&join x;
		K:=Stabilizer(G,Y,x);
		O:=Orbits(K,Y);
		for o in O do
			z:=Rep(o);
			if #(z meet covered) eq 0 then
				cand:=Include(x,z);
				flag:=false;
				for w in sizeC do
					if IsConjugate(G,Y,cand,w) then
						flag:=true;
						break;
					end if;
				end for;
				if not flag then
					Append(~sizeC,cand);
				end if;
			end if;
		end for;
	end for;
	Append(~disjoint,sizeC);
end for;

infinity:=Position(psi,V![0,1]);
H:=Stabilizer(G,Y,C);
U,chi:=VectorSpace(F,PrimeField(F));
id:=1;
for i in {1..#disjoint} do
	for x in disjoint[i] do
		covered:=&join x;
		if infinity in covered then
			uncovered:=Rep({1..#psi} diff covered);
			flag,phi:=IsConjugate(H,uncovered,infinity);
		else
			phi:=H!1;
		end if;
		outString:="{\"id\":\"complex-";
		outString cat:= Sprintf("%o-%o%o\",\"q\":%o",q,"0"^(5-#IntegerToString(id)),id,q);
		outString cat:= ",\"components\":[";
		first:=true;
		for c in x do
			indexC:=Position(circlePoints,Image(phi,c));
			if first then
				first:=false;
			else
				outString cat:= ",";
			end if;
			outString cat:= "{\"webID\":\"web-";
			outString cat:= Sprintf("%o-1-0001\",\"circles\":[%o]",q,ElementToSequence(chi(circleReps[indexC][1])) cat ElementToSequence(chi(circleReps[indexC][2])));
			outString cat:= "}";
		end for;
		print outString cat "]}";
		id +:=1;
	end for;
end for;