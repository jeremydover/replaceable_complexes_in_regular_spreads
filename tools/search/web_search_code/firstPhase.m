load "tools/search/web_search_code/createBlocks.m";

initializeSearch:=function(outfile);
  OUT:=Open(outfile,"w");
  fprintf OUT,"[{%o}]",circles[1];
  delete OUT;
  return 1;
end function;

extendSearch:=function(infile,outfile);
  cmd:=Read(infile);
  starters:=eval cmd;
  
  new:=[];
  for x in starters do
	H1:=Stabilizer(G,CSet,x);
	covered:=&join x;
	/* Since no point in covered should ever be in more that 2 circles, we can calculate covered1 pretty easily. */
	covered1:={};
	for y in x do
		if #covered1 eq 0 then covered1:=y;
		else covered1 sdiff:= y;
		end if;
	end for;
	covered2:=covered diff covered1;
	minReps:=circles;
	for y in covered1 do
		myReps:=[];
		H2:=Stabilizer(H1,y);
		O:=Orbits(H2,CSet);
		for z1 in O do
			z:=Rep(z1);
			if y in z and z notin x and #(z meet covered2) eq 0 then
				Append(~myReps,z);
			end if;
		end for;
		if #myReps lt #minReps then
			minReps:=myReps;
		end if;
	end for;
	for y in minReps do
		Append(~new,x join {y});
	end for;
  end for;
  OUT:=Open(outfile,"w");
  fprintf OUT,"%o",new;
  delete OUT;
  return #new;
end function;