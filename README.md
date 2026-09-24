# Nests and nest accessories in small order planes

## Overview

This dataset is a companion to the paper "Nests and nest accessories". It contains all the replaceable complexes found in the searches described in the paper, where a replaceable complex is a set of disjoint webs in a single spread whose covered line sets are pairwise disjoint, and thus can be independently replaced to create a new spread.

Briefly though, we use the term "web" to denote either a single regulus or a connected nest, but ultimately an atomic object about which an individual decision can be made about whether or not it is replaceable. The term "complex" refers to a set of pairwise disjoint webs, where each element may be replaced in potentially several different ways.

## Scope

Utilizing the Miquelian inversive plane M(q) as a model for the regular spread of PG(3,q), this dataset contains the following elements:
  - q = 3, 4, 8: there are no non-trivial nests, so we provide a single circle, and all sets of pairwise disjoint circles
  - q = 5, 7, 9 and 11: a single circle, all connected nests, and all replaceable complexes (sets of pairwise disjoint circles/nests)

## Repository Structure

- `webs.jsonl`
  A web is a potentially replaceable object in a regular spread, modeled using circles of the corresponding Miquelian inversive plane. Specifically, webs are currently either reguli or nests. Note that `webs.jsonl` contains all connected nests found in the search about which this dataset reports, even the non-replaceable nests. Information on replaceable disconnected nests may be found in `complexes.jsonl`.
  
  A web record contains:
    - An internal identifier representing an isomorphism class of webs
	- The order of the projective space in which the web lives
	- The multiplicity of the web, t, i.e., the number of circles in the web that must contain each covered point. Reguli are multiplicity one, nests multiplicity two
	- The number of circles in the object
	- Whether the object is replaceable as a set of lines in the regular spread:
	  - bruck - the object is replaceable using orbits under the index t subgroup of the Bruck kernel of the regular spread
	  - hemi - for nests only, the nest is replaceable using exactly (q+1)/2 lines from each opposite to the reguli in the nest, but
	    they need not be orbits under the Bruck kernel
	- A listing of the circles in lambda-S form (described below)
	
- `complexes.jsonl`
  A replaceable complex is a set of disjoint webs in a single spread whose covered line sets are pairwise disjoint, e.g., a nest with a disjoint regulus. All components must be replaceable.
  
  A complex record contains:
    - An internal identifier
	- The order of the projective space in which the complex lives
	- A sequence of component webs which comprise the complex. Each component record contains:
      -- The web ID associated with the component
	  -- The exact set of circles realizing the web within the complex

- `sources.jsonl`
  A source is a method or reference which provides a model for a nest or a replaceable complex.

  A source record contains:
    - An internal identifier
	- A link to the documentation for the source
	- A link to the implementation code for the source
	
- `web-models.jsonl`
  A model record ties webs to sources. Each record contains:
    - A web identifier, indicating which web is modeled
	- A source identifier, indicating what source technique is being used
	- Source-dependent instance data, which provides the parameters for the source needed to instantiate this specific web.

- `complex-models.jsonl`
  A model record ties complexes to sources. Each record contains:
    - A complex identifier, indicating which complex is modeled
	- A source identifier, indicating what source technique is being used
	- Source-dependent instance data, which provides the parameters for the source needed to instantiate this specific complex.

- `implementations/`
  Magma implementations of sources represented in the dataset.

- `source-descriptions/`
  Human-readable descriptions of the sources, their parameters, and references.

- `library/`
  The library contains several sets of functions that are useful across multiple sources.

- `tests/`
  Automated scripts to validate implementations.
  
- `tools/`
  Some useful tools to find abstract nests in the catalog, as well as our search code.

## Data format
In `webs.jsonl` and `complexes.jsonl`, webs and complexes are defined as sets of circles in the Miquelian plane M(q). A web has an attribute "circles" which is a sequence of sequences of integers. Each of the subsequences represents an individual circle through the "lambda-s" model; the circle sequence should be split in half, corresponding to lambda and s, respectively. Each of lambda and s is represented as a vector over the prime field GF(p), where p prime divides q, in the polynomial basis {1, x, ...}, where x is a root of the primitive polynomial given below. Once back in the field GF(q^2), the circle <lambda,s> is the set of points {lambda+s x:N(x)=1}, where N(x) = x^(q+1).

Primitive Polynomials
GF(2^2): x^2 + x + 1
GF(2^3): x^3 + x + 1
GF(2^4): x^4 + x + 1
GF(2^5): x^5 + x^2 + 1
GF(2^6): x^6 + x^4 + x^3 + x + 1
GF(2^7): x^7 + x + 1
GF(2^8): x^8 + x^4 + x^3 + x^2 + 1
GF(2^9): x^9 + x^4 + 1
GF(2^10): x^10 + x^6 + x^5 + x^3 + x^2 + x + 1
GF(2^11): x^11 + x^2 + 1
GF(2^12): x^12 + x^7 + x^6 + x^5 + x^3 + x + 1
GF(2^13): x^13 + x^4 + x^3 + x + 1
GF(2^14): x^14 + x^7 + x^5 + x^3 + 1

GF(3^2): x^2 + 2*x + 2
GF(3^3): x^3 + 2*x + 1
GF(3^4): x^4 + 2*x^3 + 2
GF(3^5): x^5 + 2*x + 1
GF(3^6): x^6 + 2*x^4 + x^2 + 2*x + 2
GF(3^7): x^7 + 2*x^2 + 1
GF(3^8): x^8 + 2*x^5 + x^4 + 2*x^2 + 2*x + 2

GF(5^2): x^2 + 4*x + 2
GF(5^3): x^3 + 3*x + 3
GF(5^4): x^4 + 4*x^2 + 4*x + 2
GF(5^5): x^5 + 4*x + 3
GF(5^6): x^6 + x^4 + 4*x^3 + x^2 + 2

GF(7^2): x^2 + 6*x + 3
GF(7^3): x^3 + 6*x^2 + 4
GF(7^4): x^4 + 5*x^2 + 4*x + 3

GF(11^2): x^2 + 7*x + 2
GF(11^3): x^3 + 2*x + 9
GF(11^4): x^4 + 8*x^2 + 10*x + 2

## Constructions and Provenance

Ultimately, the goal of this dataset is to provide a complete census of replaceable complexes in the regular spreads within its scope. While there is a natural step thereafter to ask about which projective planes can be created from these replaceable complexes, that question is not in scope for this dataset. However, because there are multiple techniques which can be used to create nests and replaceable complexes, in the interest of helping the user understand what is known and what is not, we have included provenance information for these webs and complexes where appropriate. Especially for smaller q, there may well be collapsing between constructions, and a web may have several provenance records. This is intentional; our goal is not to privilege one construction over another, or to assert discovery, but rather to maximize information.

## A Note on Replaceability

We underwent several iterations of how we wished to define "replaceable" for a nest, before landing on the schema as defined above. We readily acknowledge that our definition of replaceability regrettably excludes Prince's replaceable nests for q=7 and 11. An example illustrates the problem: any 2(q-1)-nest covers all but two lines of the regular spread. Due to the transitivity on pairs of disjoint lines in PG(3,q), any spread can be mapped so that it contains those remaining two lines, so a 2(q-1)-nest can literally be replaced in more ways than there are isomorphism classes of spreads. For this reason, we've chosen to force the definition of replaceability *in this dataset* to include only those nests that are hemi-replaceable, which includes Bruck-replaceability. 

## Magma Implementations

Implementation code was developed and tested on Magma V2.17-5. Yes, that's super old, but it should work on any more modern version. Each source exposes a function named `<sourceName>Implementation`, which can be used to instantiate the construction of a particular model, and returns the constructed nest (the bruenChainImplementation also returns the order of the inversive plane in which it sits as a second argument). Arguments to this function are formatted exactly as they are provided in the model record; note particularly the importance of double quotes around strings. It is possible for constructions to fail; we have attempted to create as many defensive checks to validate the mathematics as possible, and in those cases the Implementation functions will return 0s for all return values; otherwise they return a web/complex object as a set of <lambda,s> circles in Magma.

## Code Execution
All code is meant to be executed from the top-level directory of the dataset.

## Validation

The repository includes an automated test harness which, for each record in `web-models.jsonl` and `complex-models.jsonl`:

1. loads the corresponding construction implementation;
2. constructs the web/complex from the stored parameters;
3. verifies the result against the version given in `webs.jsonl` or `complexes.jsonl` using Magma's `IsConjugate`.

Prior to running, make sure the appropriate `library/web-catalog.m` and `library/complex-catalog.m` files are created by executing `python3 tools/build_web_catalog.py` and `python3 tools/build_complex_catalog.py`. A successful test `python3 tests/test_web_models.py` and/or `python3 tests/test_complex_models.py` verifies that the stored implementation and instance data produce a web/complex equivalent to the one identified by the model record.

In addition, a small test script to validate the transcription of Bruen chains is provided; a successful run will print a PASS message.

## Search Code
We used different search code to compile all of the data in this catalog. All of this code is available in `tools/search`. Note that this search code does depend on C's OpenMP and GMP libraries, as well as Python's OR-Tools module.
1. Disjoint circles: Easily accomplished in pure Magma, and allows us to tailor the more general complex search to start with a fixed replaceable nest.
2. Web search: The core search to find all nests. The search begins in Magma: set the order q, load "tools/search/web_search_code/firstPhase.m", run the function initializeSearch("step1"), and then subsequent applications of extendSearch("step1","step2"), extendSearch("step2","step3"), etc. to increase the depth. Our search used depth 3 for q=5, depth 4 for q=7, and depth 5 for q=9,11. Finally load "tools/search/web_search_code/setupSearch.m", and run convertStarters("stepx") to create files required to compile and execute the C-based search. Back in the shell, compile and execute search.c, which runs the depth-first search to complete the starters. Back in Magma, ensure the order q is set again, and load "tools/search/web_search_code/isomorphRejection.m". This latter sorts the discovered nests up to isomorphism, and also performs the final metadata enrichment and formatting.
3. Complex search: Once all nests of a given order have been found, this code finishes the complex search in four steps. Step 1 is a python script that extracts the replaceable nests of the correct order from the jsonl created by the web search into a Magma-readable format. Step 2 is a Magma module that determines the candidate circles disjoint from the set of points covered by each replaceable nest, and encodes these candidates in a Python-readable form. Step 3 is a Python script that utilizes OR Tools to perform the actual complex search, and step 4 is a Magma script that does isomorph rejection and final formatting.
4. Stitched nest search: We've included the code we use to search for flock- and bundle-stitched nests. In Magma, load the appropriate "tools/search/stitching_search_code/setup_(bundle|flock)_stitched.m" to create the basic structures. Then run the search with python3 tools/search/stitching_search_code/stitch.py. Finally back in Magma, isomorph rejection and pretty printing the output can be done by loading the appropriate "tools/search/stitching_search_code/sort_(bundle|flock)_stitched.m".

## References

Each source comes with one or more references describing the bibliographic source for the construction technique. These are documented in the source description files.

## AI Usage

Generative AI tools, and specifically ChatGPT, were used in the development of this dataset. Specifically, AI was used to:
1. Assist with literature search;
2. Design and templating of data formatting;
3. Develop data manipulation code and test harness;
4. Create code and perform analysis to assist in verification of external sources;
5. Optimize search code;
6. Debug mathematical code;
7. Review documentation; and
8. Validate dataset packaging.

AI was NOT used:
1. As a mathematical authority;
2. To develop any source implementation code, other than assisted correction of external sources;
3. To select source techniques; 
4. To create, verify or interpret any model record; or
5. As the final authority for any mathematical or computational verification.

Specifically, no AI-generated claims are reflected in this research without having been independently researched and verified. The contents are the responsibility of the author.

## Contributing / Corrections

Questions, corrections, and contributions are welcome through the GitHub issue tracker at https://github.com/jeremydover/replaceable_complexes_in_regular_spreads/issues.

## License

Except where otherwise noted, the contents of this repository are dedicated to the public domain under the Creative Commons CC0 1.0 Universal Public Domain Dedication.