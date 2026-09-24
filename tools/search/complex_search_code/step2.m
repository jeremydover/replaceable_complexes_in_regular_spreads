load "tools/search/complex_search_code/step1.out";
load "library/group-action.m";
out:="tools/search/complex_search_code/step2.py";
PrintFile(out,"circles = {");
for i in [1..#WebCircles] do
  str:=Sprintf("    \"%o\": ",WebIDs[i]);
  nest:=[serializedCircleToCircle(x):x in WebCircles[i]];
  covered:=&join nest;
  str cat:=Sprintf("%o,",[x:x in circles|#(x meet covered) eq 0]);
  PrintFile(out,str);
end for;
PrintFile(out,"}");

