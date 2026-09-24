/*
  Web discovery / web-model generation helper.

  Intended workflow:
      q := 7;
      load "library/web-discovery.m";
      load "implementations/bakerEbertMixedNest.m";

      webs := [... constructed lambda-s webs ...];
      instances := [
          Sprintf("{\"q\":%o,\"c\":%o}", q, [2]),
          ...
      ];

      IdentifyWebModels(webs, "bakerEbertMixedNest", instances);

  Requires an enriched webs.jsonl compiled by tools/build_web_catalog.py
  into library/web-catalog.m.
*/

load "library/Utils.m";
load "library/convert-format.m";
load "library/web-catalog.m";

/* Rebuild the same field-vector decoder used by the enrichment tool. */
webDiscoverySerialV, webDiscoverySerialPhi := VectorSpace(F, PrimeField(F));

webDiscoverySerializedCircle := function(seq)
    lambda, s := convertRegulusSerializedToLambdaS(webDiscoverySerialPhi, seq);
    if Type(lambda) eq RngIntElt then
        error "Could not deserialize catalog circle";
    end if;
    circle := { Position(P, V![1, lambda + s*x]) : x in F | x^(q+1) eq 1 };
    if not circle in circles then
        error "Catalog circle is not a member of CSet";
    end if;
    return circle;
end function;

/* Convert a construction's lambda-s output into the literal CSet representation. */
WebToCSet := function(lambdaSWeb)
    result := {};
    for ls in lambdaSWeb do
        lambda := F!ls[1];
        s := F!ls[2];
        circle := { Position(P, V![1, lambda + s*x]) : x in F | x^(q+1) eq 1 };
        if not circle in circles then
            error "Constructed object contains something that is not a circle in CSet";
        end if;
        Include(~result, circle);
    end for;
    if #result ne #lambdaSWeb then
        error "Duplicate circles occurred while converting constructed web";
    end if;
    return result;
end function;

/* Return <t,circleCount,stabilizerSize,pointOrbitSizes,circleOrbitSizes>.
   t is derived from the actual web, not trusted from the catalog. */
WebInvariantSignature := function(web)
    if #web eq 0 then error "Cannot identify an empty web"; end if;

    H := Stabilizer(G, CSet, web);
    circleOrbitSizes := [ #O : O in Orbits(H, CSet) | Rep(O) in web ];
    Sort(~circleOrbitSizes);

    coveredPoints := &join web;
    pointOrbitSizes := [ #O : O in Orbits(H) | Rep(O) in coveredPoints ];
    Sort(~pointOrbitSizes);

    multiplicities := { #[c : c in web | p in c] : p in coveredPoints };
    if #multiplicities ne 1 then
        error "Constructed object does not have constant point multiplicity";
    end if;
    t := Rep(multiplicities);

    return <t,#web,#H,pointOrbitSizes,circleOrbitSizes>;
end function;

webDiscoverySameSignature := function(entry, sig)
    return entry`q eq q and
           entry`t eq sig[1] and
           entry`circleCount eq sig[2] and
           entry`stabilizerGroupSize eq sig[3] and
           entry`pointOrbits eq sig[4] and
           entry`circleOrbits eq sig[5];
end function;

/* Identify one CSet web. Returns:
     true, webID, conjugatingElement, candidateCount
   or
     false, "", Identity(G), candidateCount
*/
IdentifyCSetWeb := function(web)
    sig := WebInvariantSignature(web);
    candidates := [ entry : entry in webCatalog | webDiscoverySameSignature(entry,sig) ];

    for entry in candidates do
        refWeb := { webDiscoverySerializedCircle(seq) : seq in entry`serializedCircles };
        flag, g := IsConjugate(G, CSet, web, refWeb);
        if flag then
            return true, entry`id, g, #candidates;
        end if;
    end for;

    return false, "", G!1, #candidates;
end function;

/* Convenience wrapper for a construction's lambda-s output. */
IdentifyWeb := function(lambdaSWeb)
    return IdentifyCSetWeb(WebToCSet(lambdaSWeb));
end function;

/* JSON string escaping written using only primitive string operations so it
   works on old Magma releases (including V2.17, which has no ReplaceString). */
webDiscoveryEscapeJSONString := function(s)
    out := "";
    for i in [1..#s] do
        c := s[i];
        if c eq "\\" then
            out := out cat "\\\\";
        elif c eq "\"" then
            out := out cat "\\\"";
        elif c eq "\n" then
            out := out cat "\\n";
        elif c eq "\r" then
            out := out cat "\\r";
        elif c eq "\t" then
            out := out cat "\\t";
        else
            out := out cat c;
        end if;
    end for;
    return out;
end function;

webDiscoveryValidateInstanceJSON := procedure(s)
    if #s lt 2 or s[1] ne "{" or s[#s] ne "}" then
        error "instanceJSON must be a compact JSON object string, e.g. {\"q\":5,\"b\":[2]}";
    end if;
end procedure;

/* Write a single already-identified model row. */
WriteWebModel := procedure(webID, sourceID, instanceJSON, fileName : append := true)
    webDiscoveryValidateInstanceJSON(instanceJSON);
    mode := append select "a" else "w";
    fh := Open(fileName, mode);
    fprintf fh, "{\"web\":\"%o\",\"source\":\"%o\",\"instance\":%o}\n",
        webDiscoveryEscapeJSONString(webID),
        webDiscoveryEscapeJSONString(sourceID),
        instanceJSON;
    delete fh;
end procedure;

/* Identify one construction result and append its model row. */
IdentifyAndWriteWebModel := procedure(lambdaSWeb, sourceID, instanceJSON :
                                      outputFile := "web-models.generated.jsonl",
                                      append := true,
                                      verbose := true)
    flag, webID, g, candidateCount := IdentifyWeb(lambdaSWeb);
    if not flag then
        error Sprintf("No catalog web matched source %o instance %o after %o invariant candidates",
                      sourceID, instanceJSON, candidateCount);
    end if;
    WriteWebModel(webID, sourceID, instanceJSON, outputFile : append := append);
    if verbose then
        printf "MATCH %o  source=%o  candidates=%o\n", webID, sourceID, candidateCount;
    end if;
end procedure;

/* Batch form. `constructedWebs[i]` corresponds to `instanceJSONs[i]`.
   By default the output file is overwritten once at the beginning, then rows
   are appended. This prevents accidental duplication from repeated sessions.
*/
IdentifyWebModels := procedure(constructedWebs, sourceID, instanceJSONs :
                               outputFile := "web-models.generated.jsonl",
                               append := false,
                               verbose := true)
    if #constructedWebs ne #instanceJSONs then
        error "constructedWebs and instanceJSONs must have the same length";
    end if;

    first := true;
    for i in [1..#constructedWebs] do
        thisAppend := append or not first;
        IdentifyAndWriteWebModel(constructedWebs[i], sourceID, instanceJSONs[i] :
                                 outputFile := outputFile,
                                 append := thisAppend,
                                 verbose := verbose);
        first := false;
    end for;
end procedure;
