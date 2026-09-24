K:=GF(q);
omega:=PrimitiveElement(K);
F<w>:=GF(q^2);
V:=VectorSpace(F,2);
G,P:=PGammaL(V);
C:={Position(P,V![1,f]):f in F|f^(q+1) eq 1};
circles:=Orbit(G,C);
CSet:=GSet(G,circles);
circleReps:=[<lambda,w^i>:lambda in F,i in {0..q-2}];
circlePoints:=[{Position(P,V![1,circleReps[i][1]+f*circleReps[i][2]]):f in F|f
^(q+1) eq 1}:i in [1..#circleReps]];

W:=VectorSpace(GF(q),5);
X,chi:=VectorSpace(F,K);
WG:=GL(W);
z:=CompanionMatrix(MinimalPolynomial(w,GF(q)));
ker:=WG![1, 0,       0,       0,       0,
         0, z[1][1], z[1][2], 0,       0,
         0, z[2][1], z[2][2], 0,       0,
         0, 0,       0,       z[1][1], z[1][2],
         0, 0,       0,       z[2][1], z[2][2]];
pg3RegularSpread:={sub<W|W![0,0,0,1,0],W![0,0,0,0,1]>} join
                  {sub<W|W![0,chi(1)[1],chi(1)[2],chi(k)[1],chi(k)[2]],
                         W![0,chi(w)[1],chi(w)[2],chi(k*w)[1],chi(k*w)[2]]>:
                         k in F};

pg3OppositeHalves:=function(reg);
  l1:=Rep(reg);
  l2:=Rep(Exclude(reg,l1));
  l3:=Rep(reg diff {l1,l2});
  repeat
    p1:=Random(l1);
  until p1 ne W!0;

  gens:={};
  for p2 in l2 do
    if (p2 eq W!0) then continue;
    end if;
    l:=sub<W|p1,p2>;
    if Dimension(l meet l3) eq 1 then
      Include(~gens,l);
    end if;
  end for;
  halves:={};
  for x in gens do
    Include(~halves,{x*(ker^(2*i)):i in {0..(q div 2)}});
    Include(~halves,{x*(ker^(2*i+1)):i in {0..(q div 2)}});
  end for;
  return halves;
end function;

pg3BruckReplaceable:=function(nest);

  linenest:={};
  for circle in nest do
    reg:={};
    for x in circle do
      if (P[x] eq V![0,1]) then
        Include(~reg,sub<W|W![0,0,0,1,0],W![0,0,0,0,1]>);
      else
        k:=P[x][2];
        Include(~reg,sub<W|W![0,chi(1)[1],chi(1)[2],chi(k)[1],chi(k)[2]],
                           W![0,chi(w)[1],chi(w)[2],chi(k*w)[1],chi(k*w)[2]]>);
      end if;
    end for;
    Include(~linenest,reg);
  end for;
  halfset:={pg3OppositeHalves(reg):reg in linenest};
  /*Note: these steps could be done more efficiently with*/
  /*SetToSequence, but this way ensures that the two half-reguli returned*/
  /*from each call to pg3OppositeHalves are adjacent in the sequence.*/
  halves:=[];
  for reg in halfset do
    for x in reg do
      Append(~halves,x);
    end for;
  end for;

  M:=MatrixAlgebra(Integers(),#halves);
  A:=M!0;
  for i in {1..#halves} do
    for j in {(i+1)..#halves} do
      if (not(exists{<l1,l2>:l1 in halves[i], l2 in halves[j] |
                             Dimension(l1 meet l2) eq 1})) then
        A[i][j]:=1;
        A[j][i]:=1;
      end if;
    end for;
  end for;
  for i in {1..(#halves div 2)} do
    A[2*i-1][2*i]:=0;
    A[2*i][2*i-1]:=0;
  end for;
  Gr:=Graph<#halves|A>;
  repl,oppnest:=HasClique(Gr,#linenest);
  return repl;
end function;

pg3HemiReplaceable:=function(nest);
  /* First sort the nest to ensure that nest[i] always intersects some nest[j] for j < i */
  orderedNest:=[Rep(nest)];
  coveredLines:=Rep(nest);
  remainder:={x:x in nest|x ne Rep(nest)};
  while #remainder gt 0 do
    cand:={x:x in remainder|#(coveredLines meet x) gt 0};
    for x in cand do
      Append(~orderedNest,x);
      coveredLines join:= x;
      Exclude(~remainder,x);
    end for;
  end while;

  linenest:=[];
  coveredPoints:={};
  for i in [1..#orderedNest] do
    circle:=orderedNest[i];
	reg:={};
    for x in circle do
      if (P[x] eq V![0,1]) then
	    W1:=sub<W|W![0,0,0,1,0],W![0,0,0,0,1]>;
      else
        k:=P[x][2];
		W1:=sub<W|W![0,chi(1)[1],chi(1)[2],chi(k)[1],chi(k)[2]],W![0,chi(w)[1],chi(w)[2],chi(k*w)[1],chi(k*w)[2]]>;
      end if;
	  Include(~reg,W1);
      coveredPoints join:= {sub<W|y>:y in W1|y ne W!0};
    end for;
    Append(~linenest,reg);
  end for;
  coveredPoints:=SetToSequence(coveredPoints);
  
  oppregs:=[SetToSequence(&join pg3OppositeHalves(linenest[i])):i in [1..#linenest]];
  lines:=&cat oppregs;
  
  A1:=Matrix(Rationals(),#lines,#oppregs,[0:i in [1..#lines * #oppregs]]);
  for i in [0..#oppregs-1] do
    for j in [0..q] do
	  A1[(q+1)*i+j+1][i+1]:=1;
	end for;
  end for;
  W1:=Matrix(Rationals(),1,#oppregs,[(q+1) div 2:i in [1..#oppregs]]);
  
  A2:=Matrix(Rationals(),#lines,#coveredPoints,[0:i in [1..#lines * #coveredPoints]]);
  for i in [1..#coveredPoints] do
    for j in [1..#lines] do
	  if coveredPoints[i] subset lines[j] then
		A2[j][i]:=1;
	  end if;
	end for;
  end for;
  W2:=Matrix(Rationals(),1,#coveredPoints,[1:i in [1..#coveredPoints]]);
  
  A12:=HorizontalJoin(A1,A2);
  W12:=HorizontalJoin(W1,W2);
  
  flag:=false;
  for x in Subsets({2..q+1},(q-1) div 2) do
    A3:=Matrix(Rationals(),#lines,q+1,[0:i in [1..(q+1)*#lines]]);
	W3:=Matrix(Rationals(),1,q+1,[0:i in [1..q+1]]);
	for i in [1..q+1] do
	  A3[i][i]:=1;
	  if i in ({1} join x) then
	    W3[1][i]:=1;
	  end if;
	end for;
	
	myA:=HorizontalJoin(A12,A3);
	myW:=HorizontalJoin(W12,W3);
	if IsConsistent(myA,myW) then
	  flag:=true;
	  break;
	end if;
  end for;
  return flag;
end function;

makePG3Spread:=function(nest);

  /*Much like the test, this finds a set of replacement opposite reguli.*/
  linenest:={};
  for circle in nest do
    reg:={};
    for x in circle do
      if (P[x] eq V![0,1]) then
        Include(~reg,sub<W|W![0,0,0,1,0],W![0,0,0,0,1]>);
      else
        k:=P[x][2];
        Include(~reg,sub<W|W![0,chi(1)[1],chi(1)[2],chi(k)[1],chi(k)[2]],
                           W![0,chi(w)[1],chi(w)[2],chi(k*w)[1],chi(k*w)[2]]>);
      end if;
    end for;
    Include(~linenest,reg);
  end for;
  halfset:={pg3OppositeHalves(reg):reg in linenest};
  halves:=[];
  for reg in halfset do
    for x in reg do
      Append(~halves,x);
    end for;
  end for;

  M:=MatrixAlgebra(Integers(),#halves);
  A:=M!0;
  for i in {1..#halves} do
    for j in {(i+1)..#halves} do
      if (not(exists{<l1,l2>:l1 in halves[i], l2 in halves[j] |
                             Dimension(l1 meet l2) eq 1})) then
        A[i][j]:=1;
        A[j][i]:=1;
      end if;
    end for;
  end for;
  for i in {1..(#halves div 2)} do
    A[2*i-1][2*i]:=0;
    A[2*i][2*i-1]:=0;
  end for;
  Gr:=Graph<#halves|A>;
  repl,oppnest:=HasClique(Gr,#linenest);

  /*Now we create the full spread.*/
  sp:=SetToSequence((pg3RegularSpread diff (&join linenest)) join
      (&join {halves[Index(x)]:x in oppnest}));
  return sp;
end function;

createPlane:=function(spread);
  affpoints:={@Normalize(x):x in W|x[1] ne 0@};
  afflines:={};
  for i in {1..#spread} do
    temp:=affpoints;
    while not(IsEmpty(temp)) do
      apoint:=Random(temp);
      vline:=sub<W|apoint,spread[i]>;
      aline:={x:x in affpoints|x in vline};
      Include(~afflines,aline);
      temp:=temp diff aline;
    end while;
  end for;
  A:=FiniteAffinePlane<affpoints|afflines>;
  Proj:=ProjectiveEmbedding(A);
  return Proj;
end function;

/*-------------------------------------------------------------------------*/
/*This section contains general nest analysis algorithms, including
functions that determine the coordinates of circles and for
automorphisms.*/

PermToLFm:=function(perm);
  inf:=Position(P,V![0,1]);
  zer:=Position(P,V![1,0]);
  one:=Position(P,V![1,1]);
  om:=Position(P,V![1,w]);

  if (inf^perm eq inf) then
    a:=1;
    c:=0;
    d:=(P[one^perm][2]-P[zer^perm][2])^(-1);
    b:=P[zer^perm][2]*d;
  else
    a:=P[inf^perm][2];
    c:=1;
    if (zer^perm eq inf) then
      d:=0;
      b:=P[one^perm][2]-a;
    else
      if (one^perm eq inf) then
        d:=-1;
        b:=(-1)*P[zer^perm][2];
      else
        d:=(P[one^perm][2]-a)/(P[zer^perm][2]-P[one^perm][2]);
        b:=d*P[zer^perm][2];
      end if;
    end if;
  end if;
  if (om^perm eq inf) then
    sigma:=Rep({x:x in Divisors(q^2)|c*w^x+d eq 0});
  else
    sigma:=Rep({x:x in Divisors(q^2)|(a*w^x+b) eq
    P[om^perm][2]*(c*w^x+d)});
  end if;
  return a,b,c,d,sigma;
end function;

LFMToPerm:=function(a,b,c,d,sigma);
  perm:=[];
  for i in {1..#P} do
    x:=P[i];
    if (x[1] eq 0) then
      if (c eq 0) then Append(~perm,i);
      else Append(~perm,Position(P,V![1,a/c]));
      end if;
    else
      if (c*x[2]^sigma+d) eq 0 then Append(~perm,Position(P,V![0,1]));
      else Append(~perm,Position(P,V![1,(a*x[2]^sigma+b)/(c*x[2]^sigma+d)]));
      end if;
    end if;
  end for;
  return G!perm;
end function;

isNest:=function(nest);
  sd:={};
  for x in nest do
    sd:=(sd diff x) join (x diff sd);
  end for;
  return IsEmpty(sd) and (#(&join nest) eq (q+1)*#nest div 2);
end function;