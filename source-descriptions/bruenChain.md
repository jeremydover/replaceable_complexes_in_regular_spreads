# Bruen Chains

## Reference
Bruen, A.A., Inversive geometry and some translation planes, I. Geom. Dedicata, 7:81–98, 1978.

Johnson, N.L., Jha, V. and Biliotti, M., Handbook of Finite Translation Planes, Pure and Applied Mathematics, Chapman & Hall/CRC, Boca Raton, FL, 2007.

See also:
Heden, O. and Saggese, M., Bruen chains in PG(3,p^k), k≥2. Discrete Mathematics 214:251-253, 2000.

Bamberg, J., Lansdown, J. and Van de Voorde, G., On Bruen chains, 2023, arxiv.org/html/2305.01349v1. Accessed 25 August 2026.

## Instance Data
chain
=====
Type: Integer or String
Description: Index into the table of Bruen chains as given by Johnson, et al. An integer should be between 1 and 19 inclusive; a string should be one of the following:
 "Bruen(5)", "Bruen(7)", "Korchmaros(7)", "V. Abatangelo(9)", "Heden-Saggese(9)", "Capursi(11)", "Korchmaros(11)", "Raguso(13)", "Heden(13)", "Heden(17)", "Baker-Ebert-Weida(17)", "Heden(19)1", "Heden(19)2", "Heden(23)", "Heden-Saggese(25)1", "Heden-Saggese(25)2", "Heden-Saggese(27)", "Heden(31)", "Heden(37)"

### Example
```json
{"chain":"Bruen(5)"}
```

## Implementation

### Function

bruenChainImplementation(chain);

### Input

chain: an integer or string as described above

### Output

If successful, a web representing the requested Bruen chain. In addition, a second return value gives the value of q such that the chain lives in M(q).

### Notes
Multiple typos were found in the listing of chains, and moreover, a canonical field representation is not listed and needed to be derived. In addition, we were unable to repair chain #8, and had to recreate it from scratch. The results of these changes were verified computationally, ensuring that all of the resulting chains are actually chains, that chains in the same M(q) circle geometry are not isomorphic, except for the pairs at q=9 and q=25 which are known to be isomorphic under the group of semilinear fractional transformations, but not under the group of linear fractional transformations.