load "tools/search/web_search_code/createBlocks.m";
SetAutoColumns(false);
SetColumns(0);

convertStarters:=function(infile);
  outfile:="tools/search/web_search_code/geometry.h";
  cmd:=Read(infile);
  starters:=eval cmd;
  
  /*Set up C data structures for geometry*/
  pointcircleint:=[0:i in [1..(q^2+1)]];
  circlepointint:=[0:i in [1..#circles]];
  for i in [1..#circles] do
    for j in circles[i] do
	  pointcircleint[j]+:=2^(i-1);
	  circlepointint[i]+:=2^(j-1);
	end for;
  end for;
  
  /*First we print the header information for the output file*/
  PrintFile(outfile,Sprintf("#define NUMPOINTS %o",q^2+1):Overwrite:=true);
  PrintFile(outfile,Sprintf("#define NUMBLOCKS %o",#circles));
  PrintFile(outfile,Sprintf("#define NUMSTARTERS %o",#starters));
  PrintFile(outfile,Sprintf("#define MAXNESTSIZE %o",2*(q-1)));
  PrintFile(outfile,"mpz_t pointblock[NUMPOINTS];");
  PrintFile(outfile,"mpz_t blockpoint[NUMBLOCKS];");
  PrintFile(outfile,"const char *circleCoordinates[NUMBLOCKS];");
  
  outfile:="tools/search/web_search_code/geometry_init.h";
  /*Print data structures.*/
  PrintFile(outfile,"/*Geometry data*/":Overwrite:=true);
  for i in [1..#circles] do
    PrintFile(outfile,Sprintf("circleCoordinates[%o]=\"%o\";",i-1,circles[i]));
    PrintFile(outfile,Sprintf("mpz_init2(blockpoint[%o],NUMPOINTS);",i-1));
    PrintFile(outfile,Sprintf("mpz_set_str(blockpoint[%o],\"%o\",10);",i-1,circlepointint[i]));
  end for;
  for i in [1..q^2+1] do
    PrintFile(outfile,Sprintf("mpz_init2(pointblock[%o],NUMBLOCKS);",i-1));
    PrintFile(outfile,Sprintf("mpz_set_str(pointblock[%o],\"%o\",10);",i-1,pointcircleint[i]));
  end for;

  outfile:="tools/search/web_search_code/starters.txt";
  /*Now include starter information.*/
  for i in [1..#starters] do
    xint:=0;
    for j in starters[i] do
	  xint+:=2^(Position(circles,j)-1);
    end for;
	PrintFile(outfile,Sprintf("%o",IntegerToString(xint,16)));
  end for;
  return "Files written.";
end function;